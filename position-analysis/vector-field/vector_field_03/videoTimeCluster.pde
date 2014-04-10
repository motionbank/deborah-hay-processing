class VideoTimeCluster
{
    ArrayList<org.piecemaker2.models.Event> videos;
    ArrayList<org.piecemaker2.models.Event> events;
    
    ArrayList<String> performers;
   
    Track3D track;
    
    Date from, to;
    
    VideoTimeCluster ( org.piecemaker2.models.Event v ) 
    {
        videos = new ArrayList();
        
        videos.add( v );
        from = v.utc_timestamp;
        to = new Date( v.utc_timestamp.getTime() + v.duration );
        
        events = new ArrayList();
    }
    
    void addVideo ( org.piecemaker2.models.Event v ) 
    {
        if ( videos.contains( v ) ) return;
        if ( v.utc_timestamp.compareTo(from) < 0 ) {
            from = v.utc_timestamp;
        }
        Date finAt = new Date( v.utc_timestamp.getTime() + v.duration );
        if ( finAt.compareTo(to) > 0 ) {
            to = finAt;
        }
        videos.add( v );
    }
    
    void addEvent ( org.piecemaker2.models.Event e )
    {
        events.add( e );
        
        if ( e.fields.get("performers") != null )
        {
            if ( performers == null ) performers = new ArrayList();

            for ( String p : e.fields.get("performers").toString().split(",") )
            {
                if ( performers.indexOf( p ) == -1 )
                    performers.add( p );
            }
        }
    }
    
    boolean overlapsWith ( org.piecemaker2.models.Event v )
    {
        return !( v.utc_timestamp.compareTo(from) < 0 || v.utc_timestamp.compareTo(to) > 0 );
    }
    
    public String toString ()
    {
        String s = toTitle() + "\n";
        for ( org.piecemaker2.models.Event v : videos )
        {
            s += "\t" + v.fields.get("title") + "\n";
        }
        return s;
    }
    
    public String toTitle()
    {
        String s = from.toString() + " - " + to.toString();
        if ( performers != null )
        {
            for ( String p : performers )
            {
                s += " " + p;
            }
        }
        return s;
    }
}
