/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Calculating a fasthash with better granularity (2 bits per value)
 *
 *    P2.0
 *    created: fjenett 20130226
 */

void setup ()
{
    int[] vals = new int[32];
    
    vals[0] = 3;
    vals[15] = 3;
    vals[31] = 3;
    
    long hash1 = toFastHash64( vals );
    println( Long.toBinaryString( hash1 ) );
    
    vals[15] = 1;
    vals[16] = 3;
    
    long hash2 = toFastHash64( vals );
    println( Long.toBinaryString( hash2 ) );
    
    println( hammingDistance64( hash1, hash2 ) );
    
    println();
    
    for ( int i = 0; i < vals.length; i++ )
    {
        vals[i] = vals[i] > 0 ? 1 : 0;
    }
    
    int hash3 = toFastHash32( vals );
    println( Integer.toBinaryString(hash3) );
}
 
long toFastHash64 ( int ... values )
{
    long hash = 0L;
    
    for ( int i = 0; i < values.length; i++ )
    {
        long v = values[i] & 0x3;
        int s = (62 - (i*2));
        hash = hash + ( v << s );
    }
    
    return hash;
}

long hammingDistance64 ( long val0, long val1 )
{
    long dist = 0;
    
    if ( val0 == val1 ) 
    {
        dist = 0;
    }
    else
    {
        long val = val0 ^ val1;
    
        while ( val != 0 )
        {
            ++dist;
            val &= val - 1;
        }
    }
    
    return dist;
}

int toFastHash32 ( int ... values )
{
    int hash = 0;
    
    for ( int i = 0; i < values.length; i++ )
    {
        int v = values[i] & 0x1;
        int s = (31 - i);
        hash = hash + ( v << s );
    }
    
    return hash;
}
