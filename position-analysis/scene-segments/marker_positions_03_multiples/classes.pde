
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
        file = file.replace( "_BackgroundSubstracted_", "_withBackgroundAdjustment_" );
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
    
    void drawHullFromTo ( int from, int len )
    {
        
        if ( from < 0 ) from = 0;
        if ( from+len >= x.length ) len = (x.length-1)-from;
        if ( len <= 0 ) return;
        
        Point2D in[] = new Point2D[len/2];
        Point2D hull[] = new Point2D[in.length];
        
        for ( int n = 0, i = from, k = from+len; i < k && n < in.length; n++, i+=2 )
        {
            in[n] = new Point2D( x[i], y[i] );
        }
        
        int total = nearHull2D( in, hull );
        
        beginShape();
        for ( int i = 0; i < total; i++ )
        {
            vertex( hull[i].x * scaling, -hull[i].y * scaling );
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
    ArrayList<String> performers;
    
    ThreeDPositionTrack track3D;
    
    VideoTimeCluster ( Video v ) 
    {
        videos = new ArrayList();
        performers = new ArrayList();
        
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
        
        if ( e.performers != null && 
             e.performers.length > 0 && 
             !e.performers[0].trim().equals("") && 
             performers.indexOf( e.performers[0] ) == -1 )
        {
            performers.add( e.performers[0] );
        }
    }
    
    boolean overlapsWith ( BasicEvent v )
    {
        return !( v.getFinishedAt().compareTo(from) < 0 || v.getHappenedAt().compareTo(to) > 0 );
    }
    
    void setTrack3DScale ( float s )
    {
        if ( track3D != null ) track3D.setScale(s);
    }
    
    void drawFromTo ( String sceneFrom, String sceneTo, float s )
    {
        int[] fromTo = getFromTo( sceneFrom, sceneTo );
        setTrack3DScale( s );
        
        if ( fromTo != null )
        {
            if ( withHighlight && currCluster == this )
            {
                strokeWeight( 5 );
                stroke( moBaColorsLow.get( performers.get(0) ) );
            }
            else
            {
                strokeWeight( 2.5 );
                stroke( moBaColors.get( performers.get(0) ) );
            }
            
            if ( asConvexHull )
            {
                fill( moBaColors.get( performers.get(0) ), 64 );
            }
            else
            {
                noFill();
            }
            
            strokeJoin( ROUND );
            
            pushMatrix();
            translate( PADDING*s, height-(PADDING*s) );
            
            if ( !asConvexHull )
                track3D.drawFromTo( fromTo[0], fromTo[1] );
            else
                track3D.drawHullFromTo( fromTo[0], fromTo[1] );
                            
            popMatrix();
        }
    }
    
    int[] getFromTo ( String sceneFrom, String sceneTo )
    {
        org.piecemaker.models.Event evData = null, evFrom = null, evTo = null;
        
        for ( org.piecemaker.models.Event e : events ) 
        {
            if ( e.getEventType().equals("data") )
            {
                evData = e;
                if ( track3D == null )
                { 
                    for ( ThreeDPositionTrack t : tracks3D )
                    {
                        if ( t.event == e )
                        {
                            track3D = t;
                            break;
                        }
                    }
                }
            }
            else 
            {
                if ( e.title.equals( sceneFrom ) )
                {
                    evFrom = e;
                }
                
                if ( e.title.equals( sceneTo ) )
                {
                    evTo = e;
                }
            }
        }
        
        if ( evData != null && evFrom != null && evTo != null && evFrom != evTo )
        {
            int iEvFrom = events.indexOf( evFrom );
            int iEvTo = events.indexOf( evTo );
            
            if ( iEvFrom < events.size()-1 && iEvFrom >= iEvTo )
            {
                evTo = events.get( iEvFrom+1 );
                list2.select( evTo.title );
            }
            
            int fStart = (int)( evFrom.getHappenedAt().getTime() -
                                evData.getHappenedAt().getTime() );
                fStart = int( (fStart / 1000.0) * track3D.fps );
                
            int fLen = int( evTo.getHappenedAt().getTime() -
                            evFrom.getHappenedAt().getTime() );
                fLen = int( (fLen / 1000.0) * track3D.fps );
        
            return new int[]{ fStart, fLen };
        }
        
        return null;
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


