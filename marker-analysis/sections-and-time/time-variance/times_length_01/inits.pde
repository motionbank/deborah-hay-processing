
void initDatabase ()
{
    String dbYamlConfig = PM_ROOT + "/config/database.yml";
    Yaml dbYaml = new Yaml();
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
    
    db.setDebug( false );
}

void loadMarkers ()
{
    // load piece
    
    piece = new Piece();
    
    db.query( "SELECT * FROM pieces WHERE id = %s", PIECE_ID );
    db.next();
    db.setFromRow( piece );
    
    println( piece );
    
    // load videos for piece
    
    ArrayList<Video> videos = new ArrayList();
    mysqlDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    db.query(
        "SELECT * FROM videos AS v JOIN video_recordings AS r ON r.video_id = v.id AND r.piece_id IN (%s) "+
        "WHERE NOT v.vid_type LIKE %s "+
            "AND recorded_at > '2011-03-01 0:0:0' AND recorded_at < '2011-11-01 0:0:0'"+
        "ORDER BY v.recorded_at",
        piece.getId(),
        "\"%other%\""
    );
    while ( db.next() )
    {
        Video v = new Video();
        db.setFromRow(v);
        videos.add( v );
        
        v.setPiece( piece );
        piece.addVideo( v );
    }
    
    println( videos.size() + " videos loaded" );
    
    // build clusters
    
    clusters = new ArrayList();
    ArrayList<VideoTimeCluster> tmpClust = new ArrayList();
    
    for ( Video v : videos ) 
    {
        boolean hasCluster = false;
        for ( VideoTimeCluster c : tmpClust )
        {
            if ( c.overlapsWith( v ) )
            {
                c.addVideo( v );
                hasCluster = true;
            }
        }
        if ( !hasCluster )
        {
            VideoTimeCluster cc = new VideoTimeCluster( v );
            tmpClust.add( cc );
        }
    }
    
    //println( clusters.size() + " clusters" );
    //println( clusters );
    
//    titleClusters = new ArrayList();
    
    for ( VideoTimeCluster c : tmpClust )
    {
        
        db.query( "SELECT * FROM events "+
                  // ( dur IS NULL OR ADDTIME(happened_at,SEC_TO_TIME(dur)) < %s )
                  "WHERE happened_at > %s AND happened_at < %s AND created_by LIKE %s AND event_type LIKE %s "+
                  "ORDER BY happened_at", 
                  "'"+mysqlDateFormat.format(c.from)+"'",
                  "'"+mysqlDateFormat.format(c.to)+"'",
                  "'FlorianJenett2'",
                  "'scene'" );
        while ( db.next() )
        {
            Event e = new Event();
            db.setFromRow( e );
            c.addEvent( e );
        }
        
        println( c.events.size() + " events added" );
        
        if ( timeMin == null ) timeMin = c.from;
        else if ( timeMin.compareTo( c.from ) > 0 ) timeMin = c.from;
        if ( timeMax == null ) timeMax = c.to;
        else if ( timeMax.compareTo( c.to ) < 0 ) timeMax = c.to;
    }
    
    println( mysqlDateFormat.format(timeMin) + " - " + mysqlDateFormat.format(timeMax) );
    
    int column = 0;
    for ( int ic = 0; ic < tmpClust.size(); ic++ )
    {
        VideoTimeCluster c = tmpClust.get(ic);
        
        ArrayList<String> eventTitles = new ArrayList();
        
        Event originEvent = null;
        
        for ( Event e : c.events )
        {
            if ( e.title.equals( "link to portal" ) )
            {
                originEvent = e;
                break;
            }
        }
        
        if ( originEvent == null )
        {
            continue;
        }
        
        clusters.add( c );
    }
    
    Collections.sort( clusters, new Comparator<VideoTimeCluster>(){
        public int compare ( VideoTimeCluster a, VideoTimeCluster b ) 
        {
            if ( a.performer.equals( b.performer ) )
                return a.from.compareTo( b.from );
            else
                return a.performer.compareTo( b.performer );
        }
    });
    
    for ( VideoTimeCluster c : clusters )
    {
        ArrayList<String> eventTitles = new ArrayList();
        
        Event originEvent = null, endEvent = null;
        
        for ( Event e : c.events )
        {
            if ( e.title.equals( "link to portal" ) )
            {
                originEvent = e;
            }
            else if ( e.title.equals( "end" ) )
            {
                endEvent = e;
            }
        }
        
        if ( originEvent == null || endEvent == null )
        {
            System.err.println( "ORIGIN or END event missing!" );
            exit();
            return;
        }
        
        long o = originEvent.getHappenedAt().getTime();
        float s = endEvent.getHappenedAt().getTime() - o;
        
        ArrayList<Integer> times = new ArrayList(), 
        timesNormalized = new ArrayList();
        
        Event e1 = c.events.get(0), e2 = null;
        
        for ( Event e : c.events )
        {
            if ( e.title.indexOf("voice") >= 0 ) continue;
            
            String et = e.title;
            int i = 2;
            while( eventTitles.contains(et) ) 
            {
                et = e.title + " #" + i;
                i++;
            }
            eventTitles.add( et );
            
//            EventTitleCluster etc = null;
//            for ( EventTitleCluster tc : titleClusters )
//            {
//                if ( tc.title.equals( et ) )
//                {
//                    etc = tc;
//                    break;
//                }
//            }
//            if ( etc == null )
//            {
//                etc = new EventTitleCluster( et );
//                titleClusters.add( etc );
//            }
//            
//            int time = (int)( e.getHappenedAt().getTime() - o );
//            int timeNorm = int((time / s) * 1000);
//            
//            etc.addEvent( time, timeNorm, e, column );
            
//            minTimeNormalized = (int)min( timeNorm, minTimeNormalized );
//            minTime = (int)min( time, minTime );
//            maxTime = (int)max( time, maxTime );
        }
        
        c.times = times;
        c.timesNormalized = timesNormalized;
        
        e1 = e2;
    }
    
//    Collections.sort( titleClusters, new Comparator<EventTitleCluster>(){
//        public int compare ( EventTitleCluster a, EventTitleCluster b ) {
//            return a.minTime - b.minTime;
//        } 
//    });
}

