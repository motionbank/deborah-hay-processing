
void initBacks ()
{
    moBaBacks = new HashMap();
    
    String backBase = "/Users/fjenett/Documents/Processing/motionbank/_github/deborah_hay";
    
    for ( String p : new String[]{"roswarby","jeaninedurning","juliettemapp",null} ) {
        moBaBacks.put( p, loadImage( backBase + "/material/backgrounds/" + (p == null ? "all" : p) + ".png" ) );
    }
}

void initDatabase ()
{
    String dbYamlConfig = PM_ROOT + "/config/database-deborah.yml";
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
    
    java.text.SimpleDateFormat mysqlDateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    String sql2 = String.format(
        "SELECT * FROM videos AS v JOIN video_recordings AS r ON r.video_id = v.id AND r.piece_id IN (%s) "+
        "WHERE ( NOT v.vid_type LIKE '%s' ) AND ( v.title LIKE '%s' OR v.title LIKE '%s' ) "+
            "AND recorded_at > %d AND recorded_at < %d "+
        "ORDER BY v.recorded_at",
        piece.getId(),
        "%other%",
        "%Center%", "%AJA%",
        selTimeFrom.getTime() / 1000L, 
        selTimeTo.getTime() / 1000L );
    println( sql2 );
    db.query( sql2 );
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
    
    ArrayList<VideoTimeCluster> prelimClust = new ArrayList();
    
    for ( Video v : videos ) 
    {
        boolean hasCluster = false;
        for ( VideoTimeCluster c : prelimClust )
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
            prelimClust.add( cc );
        }
    }
    
    tracks3D = new ArrayList();
    sceneNames = new ArrayList();
    clusters = new ArrayList();
    
    for ( VideoTimeCluster c : prelimClust )
    {
        String sql = String.format(
            "SELECT * FROM events "+
                  // ( dur IS NULL OR ADDTIME(happened_at,SEC_TO_TIME(dur)) < %s )
                  "WHERE happened_at >= %d AND happened_at <= %d AND ( event_type LIKE '%s' OR event_type LIKE '%s' ) "+
                  "ORDER BY happened_at", 
                  c.from.getTime() / 1000L,
                  c.to.getTime() / 1000L,
                  "scene", "data"
        );
        db.query( sql );
        
        String prevSceneName = null;
                  
        while ( db.next() )
        {
            org.piecemaker.models.Event e = new org.piecemaker.models.Event();
            db.setFromRow( e );
            
            String p = db.getString( "performers" ).replaceAll("[^a-z]+","");
            e.performers = new String[]{p};
            
            if ( e.getEventType().equals("scene") && (selPerformer != null && !p.equals(selPerformer)) ) continue;
            
            c.addEvent( e );
            
            if ( e.getEventType().equals("data") ) 
            {
                tracks3D.add( new ThreeDPositionTrack( e ) );
            }
            else if ( !sceneNames.contains( e.title ) )
            {
                if ( prevSceneName != null && sceneNames.contains(prevSceneName) )
                    sceneNames.add( sceneNames.indexOf(prevSceneName)+1, e.title );
                else 
                    sceneNames.add( e.title );
            }
            
            prevSceneName = e.title;
        }
        
        println( c.events.size() + " events added" );
        if ( c.events.size() > 20 )
        {
            clusters.add( c );
        }
        
        if ( timeMin == null ) timeMin = c.from;
        else if ( timeMin.compareTo( c.from ) > 0 ) timeMin = c.from;
        if ( timeMax == null ) timeMax = c.to;
        else if ( timeMax.compareTo( c.to ) < 0 ) timeMax = c.to;
    }
    
    println( clusters.size() + " clusters" );
    //println( clusters );
    
    for ( String sn : sceneNames )
    {
        list1.addItem( sn );
        list2.addItem( sn );
    }
    
    println( mysqlDateFormat.format(timeMin) + " - " + mysqlDateFormat.format(timeMax) );
}
