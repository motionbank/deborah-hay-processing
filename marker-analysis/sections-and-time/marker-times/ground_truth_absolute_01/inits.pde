void initDatabase ()
{
    String dbYamlConfig = "/Users/fjenett/Repos/piecemaker/config/database.yml";
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

void loadData ()
{
    String type = db.escape( "scene" );
    String user = db.escape( "FlorianJenett2" );
    String pieceIds = "";
    
    db.query( "SELECT * FROM pieces WHERE is_active = 1" );
    while ( db.next() ) {
        pieceIds += (pieceIds.equals("") ? "" : ",") + db.getInt("id");
    }
    
    db.query(
        "SELECT piece_id FROM events WHERE event_type = %s AND created_by = %s AND piece_id IN (%s) GROUP BY piece_id ORDER BY piece_id",
        type, user, pieceIds
    );
    pieceIds = "";
    while ( db.next() ) {
        pieceIds += (pieceIds.equals("") ? "" : ",") + db.getInt("piece_id");
    }
    
    db.query( "SELECT * FROM pieces WHERE id in (%s) ORDER BY created_at", pieceIds);
    while ( db.next() ) {
        if ( pieces == null ) pieces = new ArrayList();
        Piece p = new Piece();
        db.setFromRow( p );
        pieces.add( p );
    }
    
    for ( Piece p : pieces ) {
        db.query(
            "SELECT * FROM events WHERE event_type = %s AND created_by = %s AND piece_id = %d ORDER BY happened_at",
            type, user, p.getId()
        );
        while ( db.next() ) {
            org.piecemaker.models.Event e = new org.piecemaker.models.Event();
            db.setFromRow( e );
            if ( events == null ) events = new ArrayList();
            events.add( e );
            p.addEvent( e );
        }
    }
    
    EventGroup group = null;
    for ( org.piecemaker.models.Event e : events )
    {
        if ( e.title.equals("fred + ginger") )
        {
            group = new EventGroup();
        }
        if ( group != null )
        {
            group.addEvent(e);
        }
        if ( group != null && e.title.equals( "end" ) )
        {
            if ( groups == null ) groups = new ArrayList();
            if ( group.events != null )
            {
                groups.add( group );
                eventsPerGroup = max( eventsPerGroup, group.events.size() );
            }
            group = null;
        }
    }
}
