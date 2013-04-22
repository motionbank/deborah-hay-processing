String getEventData( String attr, String rawJson )
{
    try {
        org.json.JSONObject json = new org.json.JSONObject( rawJson );
        return json.get(attr).toString();
    } catch ( Exception e ) {
    }
    return null;
}

float[] lowPassFilter ( float[] val, float dt, float rc )
{
    float[] val2 = new float[val.length];
    float alph = dt / ( rc + dt );
    //val2[0] = val[0]
    //val2[0] = min(val) + (max(val) - min(val)) / 2;
    val2[0] = val[2];
    for ( int i = 1; i < val.length; i++ )
    {
        val2[i] = alph * val[i] + (1-alph) * val2[i-1];
    }
    return val2;
}

void lowPassFilter2D ( ArrayList<PVector> points, float dt, float rc )
{
    //pointsOrg = (ArrayList<PVector>)points.clone();
    
    // http://en.wikipedia.org/wiki/Low-pass_filter
    float[] valx = new float[points.size()];
    float[] valy = new float[points.size()];
    
    float alph = dt / ( rc + dt );
    
    valx[0] = points.get(2).x;
    valy[0] = points.get(2).y;
    
    for ( int i = 1, k = points.size(); i < k; i++ )
    {
        PVector p = points.get(i);
        valx[i] = alph * p.x + (1-alph) * valx[i-1];
        valy[i] = alph * p.y + (1-alph) * valy[i-1];
        p.set( valx[i], valy[i], 0 );
    }
}
