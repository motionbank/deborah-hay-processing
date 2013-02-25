
int[] radialHashing ()
{
    String s = pngs[currentSil];

    sil = loadImage( silhouetteFolder + "/" + s );
    sil.loadPixels();
    for ( int p = 0, k = sil.pixels.length; p < k; p++ )
    {
        if ( sil.pixels[p] == 0xFF00FFFF )
        {
            sil.pixels[p] = 0xFFFFFFFF;
        }
    }

    sil.filter( BLUR );
    sil.filter( GRAY );
    sil.filter( THRESHOLD, 0.7 );

//    xmi = Integer.MAX_VALUE; 
//    xma = Integer.MIN_VALUE; 
//    ymi = Integer.MAX_VALUE;
//    yma = Integer.MIN_VALUE;
//
//    for ( int i = 0, k = sil.pixels.length; i < k; i++ )
//    {
//        if ( sil.pixels[i] != 0xFFFFFFFF )
//        {
//            int x = i % sil.width;
//            int y = i / sil.width;
//            xmi = x < xmi ? x : xmi;
//            xma = x > xma ? x : xma;
//            ymi = y < ymi ? y : ymi;
//            yma = y > yma ? y : yma;
//        }
//    }

    int[] bbox = boundingBox( sil );
    int[] com = centerOfMass( sil );

    return computeHash( sil, com, bbox );

    //     currentSil++;
    //     currentSil %= pngs.length;
}


int[] computeHash ( PImage img, int[] centerOfMass, int[] boundingBox )
{
    int w = boundingBox[6] + abs(boundingBox[2]-centerOfMass[0]);
    int h = boundingBox[7] + abs(boundingBox[3]-centerOfMass[1]);
    int cx = centerOfMass[0];
    int cy = centerOfMass[1];
    
    int hashSize = 32;
    int hashSizeHalf = hashSize / 2;

    int wh = w > h ? w : h;
    float s = (hashSize + 1.0) / wh;

    PGraphics pg = createGraphics( hashSize+1, hashSize+1 );
    pg.beginDraw();
    pg.background( 255 );
    pg.image( sil, -cx * s + hashSizeHalf, -cy * s + hashSizeHalf, sil.width * s, sil.height * s );
    removeCache( sil );
    pg.endDraw();

    PImage sil64 = pg.get();
    sil64.updatePixels();

    int[] hash64 = new int[hashSize];

    float stepAngle = TWO_PI / hashSize;
    float angle = 0;
    for ( int i = 0; i < hashSize; i++ )
    {
        int v = 0, vi = 0;
        angle += stepAngle;
        for ( int ia = 0; ia < (360/hashSize); ia++ )
        {
            float a = angle + radians(ia);
            float sinAngle = sin(a);
            float cosAngle = cos(a);
            for ( int ii = 0; ii <= hashSizeHalf; ii++ )
            {
                int px = int( (hashSizeHalf+1) + cosAngle * ii ) + int( (hashSizeHalf) + sinAngle * ii ) * (hashSize+1);
                v += sil64.pixels[px] & 0xFF;
                vi++;
                sil64.pixels[px] = 0xFF00FF00 | (sil64.pixels[px] & 0xFF);
            }
        }
        v /= vi;
        hash64[i] = v;
    }
    
    normalizeHash( hash64 );
    //hash64 = sortLargestFirst( hash64 );
    
    sil = sil64.get();
    
    return hash64;
}

