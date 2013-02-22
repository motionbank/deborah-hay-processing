
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
    //hash = sortLargestFirst( hash );
    
    sil = imgScaled.get();
    
    return hash;
}

