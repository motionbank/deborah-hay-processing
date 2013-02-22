
void normalizeHash ( int[] hash )
{
    int min = Integer.MAX_VALUE, max = Integer.MIN_VALUE;
    for ( int i = 0; i < hash.length; i++ )
    {
        min = min > hash[i] ? hash[i] : min;
        max = max < hash[i] ? hash[i] : max;
    }
    
    if ( min == 0 && max == 255 ) return;
    
    float scale = 255.0 / (max-min);
    for ( int i = 0; i < hash.length; i++ )
    {
        hash[i] = (int)((hash[i] - min) * scale);
    }
}

int[] sortLargestFirst ( int[] hash )
{
    int mx = Integer.MIN_VALUE;
    int mxIndex = 0;
    for ( int i = 0; i < hash.length; i++ )
    {
        if ( mx <= hash[i] )
        {
            mx = hash[i];
            mxIndex = i;
        }
    }
    
    if ( mxIndex == 0 ) return hash;
    
    int[] tmp = new int[hash.length];
    System.arraycopy(hash,mxIndex,tmp,0,hash.length-mxIndex);
    System.arraycopy(hash,0,tmp,hash.length-mxIndex,mxIndex);
    
    return tmp;
}
