/**
 *    Fix null data [0, 0] in path tracks by interpolating from 
 *    last good to next good point.
 *
 *    @paramm float[][] points bad data in form of [ [x,y], [y,x], ... ]
 *    @return float[][] points with interpolated null parts 
 */
float[][] fixZeroPoints2D ( float[][] points )
{
    // trying to remove any 0,0 points by linear interpolation
    
    float[][] tmp = new float[points.length][2];
    float[] pl = null;
    for ( int i = 0, n = 0; i < points.length; i++ )
    {
        n = i+1;
        float[] p = points[i];
        float[] pn = null;
        if ( p[0] == 0 && p[1] == 0 )
        {
            for ( int k = n; k < points.length; k++ )
            {
                pn = points[k];
                if ( !( pn[0] == 0 && pn[1] == 0 ) )
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

/**
 *    Fix null data [0, 0, 0] in path tracks by interpolating from 
 *    last good to next good point.
 *
 *    @paramm float[][] points bad data in form of [ [x,y,z], [y,x,z], ... ]
 *    @return float[][] points with interpolated null parts 
 */
float[][] fixZeroPoints3D ( float[][] points )
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
