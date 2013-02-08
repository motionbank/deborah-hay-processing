class VideoTimeCluster
extends TimeCluster
{
    ArrayList<Video> videos;
    ArrayList<Event> events;
    ArrayList<Integer> times;
    ArrayList<Integer> timesNormalized;
    
    String performer = null;
    
    VideoTimeCluster ( Video v ) 
    {
        super( v.getRecordedAt(), v.getFinishedAt() );
        
        videos = new ArrayList();
        videos.add( v );
        
        events = new ArrayList();
        times = new ArrayList();
        timesNormalized = new ArrayList();
    }
    
    void addVideo ( Video v ) 
    {
        if ( videos.contains( v ) ) return;
        
        update( v.getRecordedAt() );
        update( v.getFinishedAt() );
        
        videos.add( v );
    }
    
    void addEvent ( Event e )
    {
        events.add( e );
        
        if ( performer == null )
        {
            Yaml perf = new Yaml();
            List<String> performers = (List<String>)perf.load( e.performers );
            if ( performers.size() > 0 )
            {
                performer = performers.get(0).toLowerCase().trim();
            }
        }
    }
    
    boolean overlapsWith ( BasicEvent v )
    {
        return dateInside(v.getHappenedAt()) || dateInside(v.getFinishedAt());
    }
    
    public String toString ()
    {
        String s = "";
        s += from.toString() + " - " + to.toString() + "\n";
        for ( Video v : videos )
        {
            s += "\t" + v.title + "\n";
        }
        return s;
    }
}

class TimeCluster
{
    Date from, to;
    
    TimeCluster ( Date f, Date t )
    {
        from = f;
        to = t;
    }
    
    void update ( Date d )
    {
        if ( d.compareTo(from) < 0 ) {
            from = d;
        }
        if ( d.compareTo(to) > 0 ) {
            to = d;
        }
    }
    
    boolean dateInside ( Date d )
    {
        return d.compareTo(from) >= 0 && d.compareTo(to) <= 0;
    }
}
