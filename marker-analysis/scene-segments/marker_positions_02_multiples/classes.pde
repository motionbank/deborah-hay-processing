
class ThreeDPositionTrack
{
    org.piecemaker.models.Event event;
    int fps;
    int totalFrames;
    String file;
    
    float[] x, y, z;
    
    float xMin, xMax;
    float yMin, yMax;
    float zMin, zMax;
    
    float avgDist;
    float totalDist;
    
    float scaling = 1;
    
    ThreeDPositionTrack ( org.piecemaker.models.Event e )
    {
        event = e;
        fps = Integer.parseInt( getEventData( "fps", e.description ) );
        //println( fps );
        file = getEventData( "file", e.description );
        file = file.replace( ".txt", "_com.txt" );
        //println( file );
        
        String[] lines = loadStrings( POS_3D_ROOT + file );
        totalFrames = lines.length;
        
        x = new float[totalFrames];
        y = new float[totalFrames];
        z = new float[totalFrames];
        
        xMin = yMin = zMin = Float.MAX_VALUE;
        xMax = yMax = zMax = Float.MIN_VALUE;
        
        avgDist = 0;
        
        for ( int i = 0; i < lines.length; i++ )
        {
            String l = lines[i];
            float[] vals = float( l.split(" ") );
            
            x[i] = vals[0];
            y[i] = vals[1];
            z[i] = vals[2];
            
            xMin = min( x[i], xMin );
            xMax = max( x[i], xMax );
            yMin = min( y[i], yMin );
            yMax = max( y[i], yMax );
            zMin = min( z[i], zMin );
            zMax = max( z[i], zMax );
            
//            if ( i > 0 )
//            {
//                if (  x[i] == 0 &&   y[i] == 0 &&   z[i] == 0 &&
//                     (x[i-1] != 0 || y[i-1] != 0 || z[i-1] != 0) )
//                {
//                    x[i] = x[i-1];
//                    y[i] = y[i-1];
//                    z[i] = z[i-1];
//                }
//                else
//                {
//                    float d = dist( x[i-1], y[i-1], x[i], y[i] );
//                    avgDist += d;
//                }
//            }
        }
        
        totalDist = avgDist;
        avgDist /= totalFrames;
        float mxDist = 20 * avgDist;
        
//        for ( int i = 1; i < lines.length; i++ )
//        {
//            float d = dist( x[i-1], y[i-1], x[i], y[i] );
//            if (  d > mxDist &&
//                 (x[i-1] != 0 || y[i-1] != 0 || z[i-1] != 0) )
//            {
//                x[i] = x[i-1];
//                y[i] = y[i-1];
//                z[i] = z[i-1];
//                
//                mxDist += avgDist;
//            }
//            else
//            {
//                mxDist = 10 * avgDist;
//            }
//        }
    }
    
    void setScale ( float s )
    {
        scaling = s;
    }
    
    void drawFromTo ( int from, int len )
    {
        if ( from < 0 ) from = 0;
        if ( from+len >= x.length ) len = (x.length-1)-from;
        
        beginShape();
        for ( int i = from, k = from+len; i < k; i+=2 )
        {
            vertex( x[i] * scaling, -y[i] * scaling );
        }
        endShape();
    }
    
    float[] getPositionAt ( int at )
    {
        
        return new float[]{ x[at] * scaling, -y[at] * scaling };
    }
}

class VideoTimeCluster
{
    ArrayList<Video> videos;
    ArrayList<org.piecemaker.models.Event> events;
    
    Date from, to;
    
    VideoTimeCluster ( Video v ) 
    {
        videos = new ArrayList();
        
        videos.add( v );
        from = v.getRecordedAt();
        to = v.getFinishedAt();
        
        events = new ArrayList();
    }
    
    void addVideo ( Video v ) 
    {
        if ( videos.contains( v ) ) return;
        if ( v.getRecordedAt().compareTo(from) < 0 ) {
            from = v.getRecordedAt();
        }
        if ( v.getFinishedAt().compareTo(to) > 0 ) {
            to = v.getFinishedAt();
        }
        videos.add( v );
    }
    
    void addEvent ( org.piecemaker.models.Event e )
    {
        events.add( e );
    }
    
    boolean overlapsWith ( BasicEvent v )
    {
        return !( v.getFinishedAt().compareTo(from) < 0 || v.getHappenedAt().compareTo(to) > 0 );
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


