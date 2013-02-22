int[] computeHash ( PImage img, int[] centerOfMass, int[] boundingBox )
{
    int w = boundingBox[6] + abs(boundingBox[2]-centerOfMass[0]);
    int h = boundingBox[7] + abs(boundingBox[3]-centerOfMass[1]);
    int cx = centerOfMass[0];
    int cy = centerOfMass[1];
    
    int imgSize = 128;
    int imgSizeHalf = imgSize / 2;
    int hashSize = 32;
    int hashSizeHalf = hashSize / 2;

    int wh = w > h ? w : h;
    float s = (float)imgSize / wh;

    PGraphics pg = createGraphics( imgSize, imgSize );
    pg.beginDraw();
    pg.background( 255 );
    pg.image( img, -cx * s + imgSizeHalf, -cy * s + imgSizeHalf, img.width * s, img.height * s );
    removeCache( img );
    pg.endDraw();

    PImage imgScaled = pg.get();
    imgScaled.updatePixels();

    int[] hash = new int[hashSize];

    float stepRadians = TWO_PI / hashSize;
    int stepAngle = 360 / hashSize;
    
    float angle = 0;
    for ( int i = 0; i < hashSize; i++ )
    {
        int v = 0, vi = 0;
        angle += stepRadians;
        for ( int ia = 0; ia < stepAngle; ia++ )
        {
            float a = angle + radians(ia);
            float sinAngle = sin(a);
            float cosAngle = cos(a);
            for ( int ii = 0; ii < imgSizeHalf; ii++ )
            {
                int px = int( imgSizeHalf + cosAngle * ii ) + int( imgSizeHalf + sinAngle * ii ) * imgSize;
                v += imgScaled.pixels[px] & 0xFF;
                vi++;
                imgScaled.pixels[px] = 0xFF00FF00 | (imgScaled.pixels[px] & 0xFF);
            }
        }
        v /= vi;
        hash[i] = v;
    }
    
    normalizeHash( hash );
    
    return hash;
}

int toFasthash ( int[] hash )
{
    int fasthash = 0;
    for ( int i = 0; i < 32; i++ )
    {
        int bit = (hash[i] > 127) ? 0 : 1;
        fasthash = fasthash + (bit << i);
    }
    return fasthash;
}

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

void addSQLiteHammingDistance ()
{
    // HAMMING DISTANCE in SQLite
    // http://en.wikipedia.org/wiki/Hamming_distance
    
    try {
    org.sqlite.Function.create( db.getConnection(), "hamming_distance", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                int val0 = value_int(0);
                int val1 = value_int(1);
                int dist = 0;
                
                if ( val0 == val1 ) 
                {
                    dist = 0;
                }
                else
                {
                    int val = val0 ^ val1;
                
                    while ( val != 0 )
                    {
                        ++dist;
                        val &= val - 1;
                    }
                }
                
                result( dist );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    } catch ( Exception e ) {
        e.printStackTrace();
    }
}
