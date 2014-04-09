final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker-dh";

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

void initAll ()
{
    loadData();
    currentSequence = sequences.get( currentSequenceIndex );
}

void loadData ()
{
    String pieceIds = "";
    pieces = new ArrayList();
    db.query( "SELECT * FROM pieces WHERE is_active = 1 AND id = 3" );
    while ( db.next() )
    {
        Piece p = new Piece();
        db.setFromRow(p);
        pieces.add(p);
        pieceIds += (pieceIds.equals("")?"":",")+p.getId();
    }
    
    println( String.format( "\t… pieces loaded: %s", pieces.size() ) );
    
    ArrayList<String> videoDates = new ArrayList();
    java.text.SimpleDateFormat mysqlDateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    videos = new ArrayList();
    db.query(
        "SELECT * FROM videos AS v JOIN video_recordings AS r ON r.video_id = v.id AND r.piece_id IN (%s) WHERE v.title LIKE %s OR v.title LIKE %s AND NOT v.title LIKE %s ORDER BY v.recorded_at",
        pieceIds,
        "\"%AJA%\"",
        "\"%Center%\"",
        "\"%discussion%\""
    );
    while ( db.next() )
    {
        Video v = new Video();
        db.setFromRow(v);
        videos.add( v );
        
        videoDates.add(String.format(
            " ( e.happened_at >= %d AND e.happened_at <= %d ) ",
            v.getRecordedAt().getTime()/1000L,
            v.getFinishedAt().getTime()/1000L
        ));
        
        for ( Piece p : pieces ) {
            if ( p.getId() == v.getPieceId() ) {
                v.setPiece( p );
                p.addVideo( v );
                break;
            }
        }
    }
    
    println( String.format("\t… videos loaded: %s", videos.size() ) );
    
//    events = new ArrayList();
//    db.query( "SELECT * FROM events AS e WHERE piece_id IN (%s) ORDER BY e.happened_at", pieceIds );
//    while ( db.next() )
//    {
//        Event e = new Event();
//        db.setFromRow(e);
//        events.add( e );
//    }
    
    eventsFiltered = new ArrayList();
    db.query( 
        "SELECT * FROM events AS e WHERE piece_id IN (%s) AND ( event_type = %s ) AND ( %s ) ORDER BY e.happened_at", 
        pieceIds, "\"scene\"",
        join( videoDates.toArray(new String[0]), " OR " )
    );
    while ( db.next() )
    {
        org.piecemaker.models.Event e = new org.piecemaker.models.Event();
        db.setFromRow(e);
        makeTitleColor( e.title );
        eventsFiltered.add( e );
    }
    
    println( String.format("\t… events loaded: %s", eventsFiltered.size() ) );
    
    sequences = new ArrayList();
    EventSequence es = null;
    boolean ended = true;
    for ( org.piecemaker.models.Event e : eventsFiltered )
    {
        //ended = ended || e.title.indexOf("fred") > -1;
        if ( ended )
        {
            if ( es != null ) sequences.add( es );
            es = new EventSequence();
        }
        es.addEvent( e );
        ended = e.title.equals("end");
    }
    if ( es != null && es != sequences.get(sequences.size()-1) ) sequences.add( es );
}

ArrayList<Video> getVideosForEvent ( org.piecemaker.models.Event e )
{
    ArrayList<Video> tmp = new ArrayList();
    for ( Video v : videos )
    {        
        if ( e.getFinishedAt().compareTo( v.getHappenedAt() ) > 0 && // event end > video start
             v.getFinishedAt().compareTo( e.getHappenedAt() ) > 0 )  // video end > event start
        {
            tmp.add( v );
        }
    }
    return tmp;
}

void makeTitleColor ( String t )
{
    colorMode( HSB );
    Integer c = titleColors.get( t );
    if ( c == null )
    {
        int cc = (int)round( (360/60.0) * titleColors.size() );
        c = new Integer( color( cc, 250, 150 ) );
        titleColors.put( t, c );
    }
    colorMode( RGB );
}
