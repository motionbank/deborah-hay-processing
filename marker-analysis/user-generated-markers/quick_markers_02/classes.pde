class Piece
{
    int id;
    java.util.Date happendAt;
    String title;
    
    Video selectedVideo = null;
    int selectedVideoIndex = 0;
    
    Event[] events;
    Video[] videos;
    User[] users;
    
    Piece ( int i, Date c, String t )
    {
        id = i;
        happendAt = c;
        title = t;
        
        events = new Event[0];
        videos = new Video[0];
        users = new User[0];
    }
    
    void addEvent ( Event e )
    {
        events = (Event[])append(events,e);
    }
    
    void addVideo ( Video v )
    {
        for ( Video vv : videos )
            if ( vv == v ) return;
            
        videos = (Video[])append(videos,v);
        selectedVideo = videos[0];
    }
    
    void addUser ( User u )
    {
        users = (User[])append(users,u);
    }
    
    void selectVideo ( Video v )
    {
        for ( int i = 0; i < videos.length; i++ )
        {
            if ( v == videos[i] ) {
                selectedVideoIndex = i;
                selectedVideo = videos[selectedVideoIndex];
                break;
            }
        }
    }
    
    void selectPreviousVideo ()
    {
        selectedVideoIndex--;
        if ( selectedVideoIndex < 0 )
            selectedVideoIndex = videos.length-1;
        selectedVideo = videos[selectedVideoIndex];
    }
    
    void selectNextVideo ()
    {
        selectedVideoIndex++;
        selectedVideoIndex %= videos.length;
        selectedVideo = videos[selectedVideoIndex];
    }
    
    Event[] getSortedEventsForVideo ( Video video )
    {
        Event[] evs = new Event[0];
        for ( Event e : events )
        {
            if ( e.videoId == video.id )
                evs = (Event[])append(evs, e);
        }
        Arrays.sort( evs );
        return evs;
    }
    
    HashMap<User,Event[]> getSortedUserEventsForVideo ( Video video )
    {
        Event[] evs = getSortedEventsForVideo( video );
        if ( evs == null ) return null;
        HashMap<User,Event[]> userEvents = new HashMap<User,Event[]>();
        for ( Event e : evs )
        {
            Event[] es = userEvents.get(e.user);
            if ( es == null )
            {
                es = new Event[0];
                userEvents.put(e.user, es);
            }
            es = (Event[])append(es, e);
            userEvents.put(e.user, es);
        }
        return userEvents;
    }
    
    public String toString ()
    {
        return title;
    }
}

class User
{
    String name;
    Event[] events;
    
    User ( String n )
    {
        name = n;
    }
}

class Event
implements Comparable
{
    String title;
    int id, videoId, pieceId;
    java.util.Date createdAt;
    User user;
    Piece piece;
    Video video;
    
    Event ( int i, String t, Date d, int v, int p, User u )
    {
        id = i; title = t;
        createdAt = d;
        videoId = v;
        pieceId = p;
        user = u;
    }
    
    Event ( int i, String t, Date d, int v, User u )
    {
        id = i; title = t;
        createdAt = d;
        videoId = v;
        user = u;
    }
    
    public int compareTo ( Object o )
    {
        return createdAt.compareTo( ((Event)o).createdAt );
    }
    
    String getHappendAt ()
    {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd kk:mm:ss");
        return dateFormat.format(createdAt);
    }
}

class Video
implements Comparable
{
    String filename;
    int id;
    int duration;
    java.util.Date recordedAt;
    Piece piece;
    Event[] events;
    
    Video ( int i, String f, int d, Date ra )
    {
        id = i; filename = f;
        duration = d;
        recordedAt = ra;
    }
    
    String getFilePath ()
    {
        return "/Volumes/Extracted/piecemaker_april_session_solos/" + filename + ".mp4";
    }
    
    public int compareTo ( Object o )
    {
        return recordedAt.compareTo( ((Video)o).recordedAt );
    }
}
