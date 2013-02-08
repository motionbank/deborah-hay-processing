void initData ()
{
    String[] lns = loadStrings( sketchPath("database.txt") );
    db = new MySQL( this, lns[0], lns[1], lns[2], lns[3] );
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
    
    Event[] eventsToLoad = new Event[0];
    db.query( "SELECT * FROM events "+
              "WHERE title = \"start\" AND created_by =\"FlorianJenett\" "+
              "ORDER BY happened_at");
    while ( db.next() )
    {
        eventsToLoad = 
            (Event[])append( eventsToLoad, 
                             new Event(
                db.getInt("id"), 
                db.getString("title"), 
                db.getTimestamp("happened_at"),
                db.getInt("video_id"),
                db.getInt("piece_id"),
                null
            ));
    }
    
    for ( Event vp : eventsToLoad )
    {
        db.query( "SELECT happened_at "+
                  "FROM events "+
                  "WHERE title = \"end\" "+
                      "AND created_by =\"FlorianJenett\" "+
                      "AND piece_id = \""+vp.pieceId+"\" "+
                      "AND video_id = \""+vp.videoId+"\"");
        db.next();
        String end_ts = db.getString("happened_at");
        
        println( vp );
        
        db.query( "SELECT * FROM events "+
                  "WHERE event_type = \"marker\" "+
                      "AND piece_id = \""+vp.pieceId+"\" "+
                      "AND video_id = \""+vp.videoId+"\" "+
                      "AND happened_at >= \""+vp.getHappendAt()+"\" "+
                      "AND happened_at <= \""+end_ts+"\" "
        );
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
            v = new Video(e.videoId, db.getString("title"), db.getInt("duration"), db.getTimestamp("created_at"));
            videosById.put(e.videoId, v);
        }
        
        Piece p = piecesById.get(e.pieceId);
        if ( p == null )
        {
            db.query("SELECT * FROM pieces WHERE id = "+e.pieceId);
            db.next();
            p = new Piece( e.pieceId, db.getTimestamp("created_at"), db.getString("title") );
            pieces = (Piece[])append(pieces,p);
            piecesById.put(e.pieceId, p);
        }
        p.addEvent(e);
        p.addVideo(v);
        p.addUser(e.user);
        e.piece = p;
    }
    
    currentPiece = pieces[currentPieceIndex];
    loadMovie();
}

void initScene ()
{
    textFont( createFont("Lucida Grande", 11) );
}

void initGui()
{
    GuiList pieceList = new GuiList(this);
    pieceList.set(new Object(){
        PVector position = new PVector(10,10);
        PVector size = new PVector(200,20);
        String label = "Pieces";
    });
    
    GuiList videoList;
    for ( Piece p : pieces )
    {
        videoList = new GuiList(this);
        if ( currentVideoList == null ) currentVideoList = videoList;
        pieceList.addItem(p.title, "").addListener(new GuiListener(p,videoList){
            public void bang ( GuiEvent evt ){
                if ( currentVideoList != null ) currentVideoList.hide();
                currentVideoList = ((GuiList)value(1));
                currentVideoList.show();
                currentPiece = (Piece)value(0);
                loadMovie();
            }
        });
        videoList.setLabel("Videos");
        videoList.setSize(200,20);
        videoList.alignToTopOf(pieceList);
        videoList.atRightEdgeOf(pieceList);
        for ( Video v : p.videos )
        {
            videoList.addItem(v.filename, "").addListener(new GuiListener(v){
                public void bang ( GuiEvent evt ) {
                    currentPiece.selectVideo( (Video)value(0) );
                    loadMovie();
                }
            });
        }
        videoList.hide();
    }
    currentVideoList.show();
    
    GuiButton playPauseButton = new GuiButton(this);
    playPauseButton.set(
        "position", new PVector(10,height-10-20),
        "size", new PVector(20,20)
    );
    playPauseButton.addListener("bang","togglePlayPause");
    
    slider = new GuiMultiSlider(this).setValues(0,0,1).lock(0,2);
    slider.set(
        "position", new PVector(40,height-10-20),
        "label", "Timeline",
        "size", new PVector(width-20-10-20,20),
        "minimum", 0,
        "maximum", 1
    );
    slider.addListener(new GuiListener(){
        public void changed (GuiEvent evt){
            if (movie != null)
            {
                float v = ((GuiMultiSlider)evt.item).value(1);
                movie.jump(movie.duration()*v);
                movie.play();
                if ( !playing ) waitingForPosterFrame = true;
            }
        }
    });
}
