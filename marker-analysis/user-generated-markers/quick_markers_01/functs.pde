void initData ()
{
    db = new MySQL( this, "localhost", "piecemaker_april", "pm", "pm" );
    if ( !db.connect() )
    {
        System.err.println("Unable to connect to database.");
        exit();
    }
    
    events = new Event[0];
    users = new User[0];
    pieces = new Piece[0];
    
    HashMap<String,User> usersByName = new HashMap<String,User>();
    HashMap<Integer,Piece> piecesById = new HashMap<Integer,Piece>();
    HashMap<Integer,Video> videosById = new HashMap<Integer,Video>();
    
    String[][] eventsToLoad = new String[0][2];
    db.query("SELECT piece_id, video_id FROM events WHERE title = \"start\" AND created_by =\"FlorianJenett\"");
    while ( db.next() )
    {
        eventsToLoad = (String[][])append(eventsToLoad, new String[]{db.getString("video_id"),db.getString("piece_id")});
    }
    
    for ( String[] vp : eventsToLoad )
    {
        db.query("SELECT * FROM events WHERE event_type = \"marker\" AND piece_id = \""+vp[1]+"\" AND video_id = \""+vp[0]+"\"");
        while ( db.next() )
        {
            String userName = db.getString("created_by");
            User u = usersByName.get(userName);
            if ( u == null )
            {
                u = new User(userName);
                users = (User[])append(users,u);
                usersByName.put(userName, u);
            }
            events = (Event[])append(events, new Event(
                db.getInt("id"), 
                db.getString("title"), 
                db.getTimestamp("happened_at"),
                db.getInt("video_id"),
                db.getInt("piece_id"),
                u
            ));
        }
    }
    
    for ( Event e : events )
    {
        Video v = videosById.get(e.videoId);
        if ( v == null )
        {
            db.query("SELECT * FROM videos WHERE id = "+e.videoId);
            db.next();
            v = new Video(e.videoId, db.getString("title"), db.getInt("duration"), db.getDate("created_at"));
            videosById.put(e.videoId, v);
        }
        
        Piece p = piecesById.get(e.pieceId);
        if ( p == null )
        {
            db.query("SELECT * FROM pieces WHERE id = "+e.pieceId);
            db.next();
            p = new Piece( e.pieceId, db.getDate("created_at"), db.getString("title") );
            pieces = (Piece[])append(pieces,p);
            piecesById.put(e.pieceId, p);
        }
        p.addEvent(e);
        p.addVideo(v);
        p.addUser(e.user);
        e.piece = p;
    }
    
    currentPiece = pieces[currentPieceIndex];
}

void initScene ()
{
    textFont( createFont("Lucida Grande", 11) );
}
