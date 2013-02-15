
void initDatabase ()
{
    String dbYamlConfig = PM_ROOT + "/config/database.yml";
    org.yaml.snakeyaml.Yaml dbYaml = new org.yaml.snakeyaml.Yaml();
    Map dbConfig = (Map) dbYaml.load( join( loadStrings(dbYamlConfig), "\n" ) );
    Map dbDevelopment = (Map) dbConfig.get("development");
    db = new MySQL( this, 
                    "localhost", 
                    dbDevelopment.get("database").toString(), 
                    dbDevelopment.get("username").toString(), 
                    dbDevelopment.get("password").toString() );
    if ( !db.connect() ) {
        System.err.println( "Unable to connect to database " + dbDevelopment );
        exit();
    }
    
    db.setDebug(false);
}

//void initAll ()
//{
//    loadData();
//    currentSequence = sequences.get( currentSequenceIndex );
//    sequenceWidth = width / sequences.size();
//}

void loadData ()
{
    String pieceIds = "";
    pieces = new ArrayList();
    db.query( "SELECT * FROM pieces WHERE is_active = 1" );
    while ( db.next() )
    {
        Piece p = new Piece();
        db.setFromRow(p);
        pieces.add(p);
        pieceIds += (pieceIds.equals("")?"":",")+p.getId();
    }
    
//    println( "Piece IDs to load " + pieceIds );
    
    ArrayList<String> videoDates = new ArrayList();
    java.text.SimpleDateFormat mysqlDateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    ArrayList<Video> videos = new ArrayList();
    db.query(
        "SELECT * FROM videos AS v JOIN video_recordings AS r ON r.video_id = v.id AND r.piece_id IN (%s) WHERE NOT v.title LIKE %s ORDER BY v.recorded_at",
        pieceIds,
        "\"%discussion%\""
    );
    //db.setDebug( true );
    while ( db.next() )
    {
        Video v = new Video();
        db.setFromRow(v);
        videos.add( v );
        
        if (    v.title.toLowerCase().indexOf("trio") == -1 
             && v.title.toLowerCase().indexOf("ahsg") == -1 )
        {
            videoDates.add(String.format(
                " ( e.happened_at >= \"%s\" AND e.happened_at <= \"%s\" ) ",
                v.getHappenedAt().getTime() / 1000L,
                v.getFinishedAt().getTime() / 1000L
            ));
        }
        
        for ( Piece p : pieces ) {
            if ( p.getId() == v.getPieceId() ) {
                v.setPiece( p );
                p.addVideo( v );
                break;
            }
        }
    }
    
//    println( "Videos loaded " + videos.size() );
//    println( videoDates );
    
    events = new ArrayList();
    db.query( 
        "SELECT * FROM events AS e WHERE piece_id IN (%s) AND created_by = %s AND ( event_type = %s ) AND ( %s ) ORDER BY e.happened_at", 
        pieceIds, "\"FlorianJenett2\"", "\"scene\"",
        join( videoDates.toArray(new String[0]), " OR " )
    );
    while ( db.next() )
    {
        org.piecemaker.models.Event e = new org.piecemaker.models.Event();
        db.setFromRow(e);
        events.add( e );
    }
    
//    println( "Events " + events.size() );
}

void buildChains ()
{
    // lists
    chains = new ArrayList();
    nodes = new HashMap();
    links = new ArrayList();
    
    Chain chain = null;
    ChainNode ln = null;
    
    HashMap<String,Integer> titles = null;
    boolean ended = true;
    
    boolean joySorrowPassed = false;
    
    // build complex data from raw data
    for ( org.piecemaker.models.Event e : events )
    {
        //ended = ended || e.title.indexOf( "fred" ) > -1;
        
        if ( ended )
        {
            if ( chain != null && chain.nodes.size() > 25 )
            {
                chains.add( chain );
            }
            chain = new Chain();
            ln = null;
            joySorrowPassed = false;
        }
        
        String t = e.title;
        
        ChainNode cl = nodes.get( t );
        if ( cl == null ) cl = new ChainNode( t );
        cl.inc();
        
        nodes.put( t, cl );
        chain.add( cl );
        
        if ( ln != null )
        {
            ChainLink lk = new ChainLink( ln, cl );
            if ( ! links.contains(lk) )
            {
                links.add( lk );
            }
            else
            {
                lk = links.get( links.indexOf( lk ) );
                lk.inc();
            }
        }
        ln = cl;
        
        ended = e.title.equals("end");
    }
    
    // build each nodes order: at which position in the sequence it is
    for ( Chain c : chains )
    {
        int i = 0;
        
        for ( ChainNode n : c.nodes )
        {
            n.orderSum += i;
            i++;
        }
    }
    
    // build a rank-map
    ranks = new HashMap();
    for ( ChainNode n : nodes.values() )
    {
        int i = n.getOrder(); // on average order
        ArrayList<ChainNode> r = ranks.get( i );
        if ( r == null ) r = new ArrayList();
        if ( !r.contains(n) )
            r.add( n );
        ranks.put( i, r );
    }
    
    // set beginnings to 0, ends to size-1
    for ( Chain c : chains )
    {
        ChainNode n = c.nodes.get(0);
        int i = n.getOrder();
//        if ( i > 0 )
//        {
//            ranks.get(i).remove( n );
//            ranks.get(0).add( n );
//            n.setOrder(0);
//        }
        
        n = c.nodes.get(c.nodes.size()-1);
        i = n.getOrder();
//        if ( i < ranks.size()-1 )
//        {
//            ranks.get(i).remove( n );
//            ranks.get(ranks.size()-1).add( n );
//            n.setOrder(ranks.size()-1);
//        }
    }
    
    // remove backwards movement
    for ( int i = 0, k = links.size(); i < k; i++ )
    {
        ChainLink l1 = links.get( i );
        
        if ( i < k-1 )
        {
            // set cross links on same level
            for ( int n = i+1; n < k; n++ )
            {
                ChainLink l2 = links.get( n );
                
                if ( l1.isInverseOf( l2 ) )
                {
                    l1.inverse = l2;
                    l2.inverse = l1;
                    
                    int i1 = l1.from.getOrder();
                    int i2 = l1.to.getOrder();
                    if ( i1 != i2 )
                    {
                        int im = i1 > i2 ? i1 : i2;
                        if ( im == i1 )
                        {
                            ranks.get(i2).remove( l1.to );
                            ranks.get(im).add( l1.to );
                            l1.to.setOrder( im );
                        } else {
                            ranks.get(i1).remove( l1.from );
                            ranks.get(im).add( l1.from );
                            l1.from.setOrder( im );
                        }
                    }
                }
            }
        }

        int i1 = l1.from.getOrder();
        int i1b = l1.to.getOrder();
        
        // long chain links to back to shorter one
//        if ( i1 >= i1b && l1.inverse == null )
//        {
//            ranks.get( i1b ).remove( l1.to );
//            ArrayList ll = ranks.get( i1+1 );
//            if ( ll == null ) ll = new ArrayList();
//            ll.add( l1.to );
//            ranks.put( i1+1, ll );
//            l1.to.setOrder( i1+1 );
//        }
    }
    
    // sort rank-map keys
    Set<Integer> s = ranks.keySet();
    ArrayList<Integer> sl = new ArrayList();
    sl.addAll( s );
    Collections.sort(sl);
    
    float yStep = height / (sl.size() + 5);
    
    // set x, y for each node
    for ( Integer i : sl )
    {
        ArrayList<ChainNode> al = ranks.get( i );
        
        Collections.sort( al, new Comparator<ChainNode>(){
            public int compare ( ChainNode n1, ChainNode n2 ) 
            {
                if ( n1.linksIn == null && n2.linksIn == null ) return 0;
                float i1 = 0, x1 = 0, i2 = 0, x2 = 0;
                if ( n1.linksIn != null )
                {
                    for ( ChainLink lk : n1.linksIn )
                    {
                        x1 += lk.from.x * lk.from.total;
                    }
                }
                if ( n2.linksIn != null )
                {
                    for ( ChainLink lk : n2.linksIn )
                    {
                        x2 += lk.from.x * lk.from.total;
                    }
                }
                return (int)round(x2) - (int)round(x1);
            }
        });
        
        float xStep = width / (al.size() + 1);
        float x = xStep;
        
        for ( ChainNode n : al )
        {
            float xi = x, ii = 1;
//            if ( n.linksIn != null )
//            {
//                for ( ChainLink l : n.linksIn )
//                {
//                    xi += l.from.x;
//                    ii++;
//                }
//            }
            n.x = xi/ii;
            n.y = yStep * (i+1);
            x += xStep;
        }
    }
    
    // minimize crossings
//    for ( int i = 0, k = links.size(); i < k-1; i++ )
//    {
//        ChainLink l1 = links.get( i );
//        for ( int n = i+1; n < k; n++ )
//        {
//            ChainLink l2 = links.get( n );
//            if ( l1.intersectsWith( l2 ) )
//            {
//                if ( l1.from.getOrder()  == l2.from.getOrder()
//                     /*&& l1.to.getOrder() == l2.to.getOrder()*/ )
//                {
//                    float x = l1.from.x;
//                    l1.from.x = l2.from.x;
//                    l2.from.x = x;
//                }
//            }
//        }
//    }

    // downward align nodes in chain
    for ( Chain c : chains )
    {
        for ( int i = 0, k = c.nodes.size(); i < k-1; i++ )
        {
            ChainNode n = c.nodes.get(i);
            ChainNode m = c.nodes.get(i+1);
            if ( n.y >= m.y )
            {
                m.y = n.y + yStep;
            }
            if ( n.linksOut != null && n.linksOut.size() == 1 && m.linksIn != null && m.linksIn.size() == 1 )
            {
                m.x = n.x;
            }
        }
    }
}
