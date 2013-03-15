class Track3D
{
    color trackColor;
    
    float[][] trackData;
    float[] trackSpeed;
     
    float trackSpeedMean, trackSpeedHigh, trackSpeedLow, trackSpeedThresh;
    
    // fix [0,0,0] points by interpolating between last and next known point
    
    float[][] fixZeroPoints ( float[][] points )
    {
        // trying to remove any 0,0,0 points by linear interpolation
        
        float[][] tmp = new float[points.length][3];
        float[] pl = null;
        for ( int i = 0, n = 0; i < points.length; i++ )
        {
            n = i+1;
            float[] p = points[i];
            float[] pn = null;
            if ( p[0] == 0 && p[1] == 0 && p[2] == 0 )
            {
                for ( int k = n; k < points.length; k++ )
                {
                    pn = points[k];
                    if ( !( pn[0] == 0 && pn[1] == 0 && pn[2] == 0 ) )
                    {
                        n = k;
                        break;
                    }
                }
            }
            if ( pn != null )
            {
                if ( pl == null ) pl = pn;
                for ( int i2 = i; i2 <= n; i2++ )
                {
                    tmp[i2][0] = map( i2, i, n, pl[0], pn[0] );
                    tmp[i2][1] = map( i2, i, n, pl[1], pn[1] );
                    tmp[i2][2] = map( i2, i, n, pl[2], pn[2] );
                }
                //println( "Fixed " + (n-i) );
                i = n;
                continue;
            }
            tmp[i] = p;
            pl = p;
        }
        return tmp;
    }
}
