
void initDatabase ()
{
    String dbYamlConfig = "/Users/fjenett/Repos/piecemaker/config/database.yml";
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
    
    //db.setDebug(false);
}

void initData ()
{
    String user = esq( "FlorianJenett2" );
    String type = esq( "scene" );
    DateFormat mysqlDateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    
    // find pieces that have events by "FlorianJenett2"
    
    ArrayList<Integer> pieceIds = new ArrayList();
    
    db.query( 
        "SELECT * FROM events WHERE event_type = %s AND  created_by = %s GROUP BY piece_id ORDER BY happened_at",
        type,
        user
    );
    
    while ( db.next() )
    {
        int p = db.getInt("piece_id");
        if ( p >= 5 && p < 10 )
            pieceIds.add( p );
    }
    
    // load pieces
    
    pieces = new HashMap<Integer, Piece>();
    
    db.query( "SELECT * FROM pieces WHERE id IN (%s)", join( str( pieceIds ), "," ) );
    
    while ( db.next() )
    {
        Piece p = new Piece();
        db.setFromRow( p );
        pieces.put( p.getId(), p );
    }
    
    // find videos for pieces
    
    ArrayList<Integer> videoIds = new ArrayList<Integer>();
    
    db.query(
        "SELECT * FROM video_recordings WHERE piece_id IN (%s)",
        join( str( pieceIds ), "," )
    );
    
    while ( db.next() )
    {
        videoIds.add( db.getInt("video_id") );
    }
    
    // load videos
    
    videos = new ArrayList<Video>();
    
    db.query( "SELECT * FROM videos AS v " + 
              "JOIN video_recordings AS vr ON v.id = vr.video_id " + 
              "WHERE v.id IN (%s) AND vr.piece_id IN (%s) AND v.title LIKE %s " +
              "ORDER BY v.title", 
        join(str(videoIds), ","),
        join(str(pieceIds), ","),
        esq( "%Center_Small%" )
    );
    
    while ( db.next() )
    {
        Video v = new Video();
        db.setFromRow(v);
        println( v.getHappenedAt() + " " + v.getFinishedAt() );
        videos.add( v );
        Piece p = pieces.get( db.getInt( "piece_id" ) );
        p.addVideo( v );
    }
//    Collections.sort( videos, new Comparator<Video>(){
//        public int compare ( Video v1, Video v2 ) {
//            return v1.getRecordedAt().compareTo(v2.getRecordedAt());
//        }
//    });
    
    ArrayList<Integer> eventIds = new ArrayList<Integer>();
    events = new HashMap();
    
    // now let's load the events
    for ( Map.Entry entry : pieces.entrySet() )
    {
        Piece piece = (Piece)entry.getValue();
        for ( Video video : piece.getVideos() )
        {
            String sql = String.format(
                "SELECT * FROM events WHERE " + 
                "piece_id = %d AND happened_at >= %s AND happened_at <= %s AND event_type = %s AND created_by = %s "+
                "ORDER BY happened_at",
                piece.getId(), 
                esq(mysqlDateFormat.format(video.getRecordedAt())), 
                esq(mysqlDateFormat.format(video.getFinishedAt())), 
                type, 
                user
            );
            println( sql );
            db.query(sql);
            while ( db.next() ) {
                int eid = db.getInt("id");
                if ( !eventIds.contains( eid ) )
                {
                    Event e = new Event();
                    db.setFromRow( e );
                    events.put( e.getId(), e );
                    piece.addEvent( e );
                    eventIds.add( eid );
                }
                video.addEvent( events.get( eid ) );
            }
        }
    }
}

void initStyles ()
{
    textFont( createFont( "Arial", 16 ) );
    
    style = new Style(this);
    
    style.storeFontFamily( "Lato", new int[]{ 11, 13, 16, 20 } );
    
    noStroke();
    fill( 255 );
    textFont( style.getFont("Lato-Bold-16") );
    
    style.store( "interface-text" );
    
    stroke( 255 );
    strokeWeight( 1 );
    noFill();
    
    style.store( "interface" );
    
    stroke( 200 );
    
    style.store( "interface-selected" );
    
    fill( 200 );
    noStroke();
    
    style.store( "interface-selected-text" );
}
