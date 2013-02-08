class EventTitleCluster
{
    String title;
    
    ArrayList<Integer> columns;
    ArrayList<Integer> times;
    ArrayList<Integer> timesNormalized;
    ArrayList<Event> events;
    
    int minTime, maxTime, avgTime;
    
    EventTitleCluster ( String t )
    {
        title = t;
        
        columns = new ArrayList();
        times = new ArrayList();
        timesNormalized = new ArrayList();
        events = new ArrayList();
    }
    
    void addEvent ( int time, int timeNormalized, Event e, int column )
    {
        times.add( time );
        timesNormalized.add( timeNormalized );
        events.add( e );
        columns.add( column );
        
        minTime = Integer.MAX_VALUE;
        maxTime = Integer.MIN_VALUE;
        avgTime = 0;
        for ( int i = 0; i < times.size(); i++ )
        {
            int t = times.get(i);
            minTime = (int)min( minTime, t );
            maxTime = (int)max( maxTime, t );
            avgTime += t;
        }
        avgTime /= times.size();
    }
    
    void draw ( int tf, int tt, int y, int h )
    {
        noFill();
        stroke(0);
        
        float total = float(tt-tf);
        float xx = 0, yy = 0, c = -1 ;
        
        beginShape();
        for ( int i = 0; i < times.size(); i++ )
        {
            int cc = columns.get(i);
            xx = 10 + ( cc/ float(clusters.size())) * (width-60.0);
            yy = y + ((times.get(i)-tf) / total) * h;
            
            if ( c != cc-1 )
            {
                endShape();
                beginShape();
            }
            c = cc;
            
            vertex( xx, yy );
        }
        endShape();
        
        fill( 0 );
        text( title , width-65, yy );
    }
    
    void drawBlob ( int tf, int tt, float x, float y, float w, float h )
    {
        float total = float(tt-tf);
        
        fill( 200 );
        float y1 = ((minTime-tf) / total) * h;
        float y2 = ((maxTime-tf) / total) * h;
        stroke( 0 );
        rect( x, y + y1, w, y2-y1 );
        
        float yyy = y + ((avgTime-tf) / total) * h;
//        stroke( 0 );
//        line( 10, yyy, width-80, yyy );
        
        fill( 0 );
        //text( title , width-65, yyy );
        text( title , x+w+5, y + y1 );
        
        ellipse( x + w/2, yyy, 3,3 );
        
        stroke( 0 );
        line( x, yyy, x+w, yyy );
        
        stroke( 255, 0, 0 );
        ArrayList<Integer> timesSorted = (ArrayList<Integer>)times.clone();
        Collections.sort( timesSorted );
        float yMedian = y + ((timesSorted.get(timesSorted.size()/2)-tf) / total) * h;
        line( x, yMedian, x+w, yMedian );
    }
    
    void drawNormalized ( int y, int h )
    {
        noFill();
        stroke(0);
        
        float xx = 0, yy = 0, c = -1;
        
        beginShape();
        for ( int i = 0; i < timesNormalized.size(); i++ )
        {
            int cc = columns.get(i);
            xx = 10 + ( cc/ float(clusters.size())) * (width-60.0);
            
            yy = y + ((timesNormalized.get(i)-minTimeNormalized) / (1000.0 - minTimeNormalized)) * h;
            
            if ( c != cc-1 )
            {
                endShape();
                beginShape();
            }
            c = cc;
            
            vertex( xx, yy );
        }
        endShape();
        
//        float yyy = y + ((avgTime-tf) / total) * h;
//        stroke( 255, 0, 0  );
//        line( 10, yyy, width-60, yyy );
        
        fill( 0 );
        text( title , width-65, yy );
    }
    
    void drawBlobNormalized ( float x, float y, float w, float h )
    {
        float minTimeN = Float.MAX_VALUE;
        float maxTimeN = Float.MIN_VALUE;
        float avgTime = 0;
        
        for ( int i = 0; i < timesNormalized.size(); i++ )
        {
            float t = (timesNormalized.get(i)-minTimeNormalized) / (1000.0-minTimeNormalized);
            
            minTimeN = min( minTimeN, t );
            maxTimeN = max( maxTimeN, t );
            avgTime += t;
        }
        
        avgTime /= timesNormalized.size();
        
        fill( 200 );
        float y1 = minTimeN * h;
        float y2 = maxTimeN * h;
        stroke( 0 );
        
        rect( x, y+y1, w, y2-y1 );
        //ellipse( x+w/2, y+y1+(y2-y1)/2, w, y2-y1 );
        
        float yyy = y + (avgTime) * h;
//        stroke( 0 );
//        line( 10, yyy, width-80, yyy );
        
        fill( 0 );
        //text( title , width-65, yyy );
        text( title , x+w+5, y + y1 );
        
        ellipse( x + w/2, yyy, 3, 3 );
        line( x, yyy, x+w, yyy );
        
        stroke( 255, 0, 0 );
        ArrayList<Integer> timesSorted = (ArrayList<Integer>)timesNormalized.clone();
        Collections.sort( timesSorted );
        float yMedian = y + ((timesSorted.get(timesSorted.size()/2)-minTimeNormalized) / (1000.0-minTimeNormalized)) * h;
        line( x, yMedian, x+w, yMedian );
    }
}

class VideoTimeCluster
extends TimeCluster
{
    ArrayList<Video> videos;
    ArrayList<Event> events;
    
    String performer = null;
    
    VideoTimeCluster ( Video v ) 
    {
        super( v.getRecordedAt(), v.getFinishedAt() );
        
        videos = new ArrayList();
        videos.add( v );
        
        events = new ArrayList();
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
