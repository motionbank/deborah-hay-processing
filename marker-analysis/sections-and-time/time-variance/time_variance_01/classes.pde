class EventTitleCluster
{
    String title;
    
    ArrayList<Integer> columns;
    ArrayList<VideoTimeCluster> clusters;
    
    ArrayList<Integer> times;
    ArrayList<Integer> timesNormalized;
    
    ArrayList<org.piecemaker.models.Event> events;
    
    int minTime, maxTime, avgTime;
    
    float[][] segments, segmentsNormalized;
    
    EventTitleCluster ( String t )
    {
        title = t;
        
        columns = new ArrayList();
        clusters = new ArrayList();
        times = new ArrayList();
        timesNormalized = new ArrayList();
        events = new ArrayList();
    }
    
    void addEvent ( int time, int timeNormalized, org.piecemaker.models.Event e, int column, VideoTimeCluster cluster )
    {
        times.add( time );
        timesNormalized.add( timeNormalized );
        events.add( e );
        columns.add( column );
        clusters.add( cluster );
        
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
    
    void calcSegments ( int tf, int tt, int y, int h )
    {
        segments = new float[0][0];
        
        float total = float(tt-tf);
        float xx = 0, yy = 0, c = -1;
        
        float colWidth = (width - ((clusters.size()-1) * COL_PADDING) - (2.0 * PADDING)) / (clusters.size()-1);
        
        float[] segm = null;
        
        for ( int i = 0; i < times.size(); i++ )
        {
            int cc = columns.get(i);
            xx = PADDING + cc * COL_PADDING + cc * colWidth;
            yy = y + ((times.get(i)-tf) / total) * h;
            
            if ( i > 0 )
            {
                org.piecemaker.models.Event ev1 = events.get(i-1);
                org.piecemaker.models.Event ev2 = events.get(i);
                
                if ( c == cc-1 && ev1.performers[0].equals(ev2.performers[0]) )
                {
                    segm[2] = xx-COL_PADDING;
                    segm[3] = yy;
                    segments = (float[][])append( segments, segm );
                }
                else
                {
                    while ( c < cc-1 )
                    {
                        segments = (float[][])append( segments, null );
                        c++;
                    }
                    segments = (float[][])append( segments, null );
                }
            }
            
            segm = new float[]{ xx, yy, 0, 0 };
            
            c = cc;
        }
    }
    
    void calcNormalizedSegments ( int y, int h )
    {
        segmentsNormalized = new float[0][0];
        float[] segm = new float[0];
        
        float xx = 0, yy = 0, c = -1;
        
        float colWidth = (width - ((clusters.size()-1) * COL_PADDING) - (2.0 * PADDING)) / (clusters.size()-1);
        
        for ( int i = 0; i < timesNormalized.size(); i++ )
        {
            int cc = columns.get(i);
            xx = PADDING + cc * COL_PADDING + cc * colWidth;
            yy = y + ((timesNormalized.get(i)-minTimeNormalized) / (1000.0 - minTimeNormalized)) * h;
            
            if ( i > 0 )
            {
                org.piecemaker.models.Event ev1 = events.get(i-1);
                org.piecemaker.models.Event ev2 = events.get(i);
                
                if ( c == cc-1 && ev1.performers[0].equals(ev2.performers[0]) )
                {
                    segm[2] = xx;
                    segm[3] = yy;
                    segmentsNormalized = (float[][])append( segmentsNormalized, segm );
                }
                else
                {
                    while ( c < cc-1 )
                    {
                        segmentsNormalized = (float[][])append( segmentsNormalized, null );
                        c++;
                    }
                    segmentsNormalized = (float[][])append( segmentsNormalized, null );
                }
            }
            
            segm = new float[]{ xx, yy, 0, 0 };
            
            c = cc;
        }
    }
    
    void draw ()
    {
        noFill();
        
        for ( int i = 0; i < segments.length; i++ )
        {
            if ( segments[i] == null ) continue;
            
            VideoTimeCluster cluster = clusters.get(i);
            stroke( moBaColors.get( cluster.performer ) );
            strokeWeight( strokeWeight );
            
            beginShape();
                vertex( segments[i][1], segments[i][0] );
                vertex( segments[i][3], segments[i][2] );
            endShape();
        }
        
//        fill( 0 );
//        text( title , width-80, segments[segments.length-1][3] );
    }
    
    void drawNormalized ()
    {
        noFill();
        
        for ( int i = 0; i < segmentsNormalized.length; i++ )
        {
            if ( segmentsNormalized[i] == null ) continue;
            
            VideoTimeCluster cluster = clusters.get(i);
            stroke( moBaColors.get( cluster.performer ) );
            strokeWeight( strokeWeight );
            
            beginShape();
                vertex( segmentsNormalized[i][1], segmentsNormalized[i][0] );
                vertex( segmentsNormalized[i][3], segmentsNormalized[i][2] );
            endShape();
        }
        
//        fill( 0 );
//        text( title , width-80, segmentsNormalized[segmentsNormalized.length-1][3] );
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
        pushMatrix();
            translate( x+w+5, y + y1 );
            //rotate( -HALF_PI );
            text( title, 0, 0 );
        popMatrix();
        
        // draw average, mean
        ellipse( x + w/2, yyy, 3,3 );
        
        stroke( 0 );
        line( x, yyy, x+w-1, yyy );
        
        // draw median
        stroke( 255, 0, 0 );
        ArrayList<Integer> timesSorted = (ArrayList<Integer>)times.clone();
        Collections.sort( timesSorted );
        float yMedian = y + ((timesSorted.get(timesSorted.size()/2)-tf) / total) * h;
        line( x, yMedian, x+w-1, yMedian );
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
    
    String take = null;
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
        
        String[] pieces = v.getTitle().split("_");
        take = pieces[0];
        performer = pieces[1];
        
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
