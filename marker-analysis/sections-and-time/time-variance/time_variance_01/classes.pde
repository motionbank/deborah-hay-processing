class EventTitleCluster
{
    String title;
    
    ArrayList<Integer> columns;
    
    ArrayList<Integer> times;
    ArrayList<Integer> timesNormalized;
    
    ArrayList<org.piecemaker.models.Event> events;
    
    int minTime, maxTime, avgTime;
    
    EventTitleCluster ( String t )
    {
        title = t;
        
        columns = new ArrayList();
        times = new ArrayList();
        timesNormalized = new ArrayList();
        events = new ArrayList();
    }
    
    void addEvent ( int time, int timeNormalized, org.piecemaker.models.Event e, int column )
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
            xx = 10 + ( cc / float(clusters.size()-1)) * (width-100.0);
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
        text( title , width-80, yy );
    }
    
    void drawBlob ( int tf, int tt, float x, float y, float w, float h )
    {
        float total = float(tt-tf);
        
        fill( 200 );
        float y1 = ((minTime-tf) / total) * h;
        float y2 = ((maxTime-tf) / total) * h;
    
        noStroke();
        rect( x, y + y1, w, y2-y1 );
        
        stroke( 170 );
        for ( int i : times )
        {
            float t = y + ((i-tf) / total) * h;
            line( x, t, x+w-1, t );
        }
        
//        noFill();
//        rect( x, y + y1, w, y2-y1 );
        
        float yyy = y + ((avgTime-tf) / total) * h;
        
        fill( 0 );
        text( title , x+w+5, y + y1 );
        
        ellipse( x + w/2, yyy, 3,3 );
        
        stroke( 0 );
        line( x, yyy, x+w-1, yyy );
        
        // draw mean
        stroke( 255, 0, 0 );
        ArrayList<Integer> timesSorted = (ArrayList<Integer>)times.clone();
        Collections.sort( timesSorted );
        float yMedian = y + ((timesSorted.get(timesSorted.size()/2)-tf) / total) * h;
        line( x, yMedian, x+w-1, yMedian );
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
            xx = 10 + ( cc/ float(clusters.size()-1)) * (width-100.0);
            
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
        
        fill( 0 );
        text( title , width-80, yy );
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
        
        noStroke();
        rect( x, y+y1, w, y2-y1 );
        
        stroke( 170 );
        for ( int i : timesNormalized )
        {
            float t =  y + h * ((i-minTimeNormalized) / (1000.0-minTimeNormalized));
            line( x, t, x+w-1, t );
        }
        
        noFill();
        rect( x, y+y1, w, y2-y1 );
        
        float yyy = y + (avgTime) * h;
        
        noStroke();
        fill( 0 );
        text( title , x+w+5, y + y1 );
        
        ellipse( x + w/2, yyy, 3, 3 );
        stroke( 0 );
        line( x, yyy, x+w-1, yyy );
        
        stroke( 255, 0, 0 );
        ArrayList<Integer> timesSorted = (ArrayList<Integer>)timesNormalized.clone();
        Collections.sort( timesSorted );
        float yMedian = y + ((timesSorted.get(timesSorted.size()/2)-minTimeNormalized) / (1000.0-minTimeNormalized)) * h;
        line( x, yMedian, x+w-1, yMedian );
    }
    
    public String toString ()
    {
        return "EventTimeCluster for \"" + title + "\"";
    }
}

class VideoTimeCluster
extends TimeCluster
{
    ArrayList<Video> videos;
    ArrayList<org.piecemaker.models.Event> events;
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
    
    void addEvent ( org.piecemaker.models.Event e )
    {
        events.add( e );
        
        if ( performer == null )
        {
            if ( e.performers.length > 0 )
            {
                performer = e.performers[0].toLowerCase().trim();
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
