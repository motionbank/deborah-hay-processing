/**
 *
 */
void addSilhouetteToMean ( PImage s )
{
    s.loadPixels();
    if ( silMean == null ) 
    {
        silMean = new int[s.pixels.length];
        silMeanWidth = s.width;
        silMeanHeight = s.height;
    }
    
    for ( int i = 0; i < s.pixels.length; i++ )
    {
        silMean[i] += s.pixels[i] & 0xFF;
    }
    silCount++;
}

/**
 *
 */
PImage meanToPImage ()
{
    PImage img = new PImage( silMeanWidth, silMeanHeight, RGB );
    
    for ( int i = 0, c = 0; i < silMean.length; i++ )
    {
        c = silMean[i] / silCount;
        img.pixels[i] = (c << 16) + (c << 8) + c;
    }
    
    return img;
}

/**
 *
 */
int calcImageDifference ( PImage img1, PImage img2 )
{
    int movement = 0;

    img1.loadPixels();
    img2.loadPixels();

    if ( img1.pixels.length != img2.pixels.length )
    {
        System.err.println( "image sizes do not match!" );
        exit();
    }

    for ( int i = 0; i < img1.pixels.length; i++ )
    {
        movement += abs( (img1.pixels[i] & 0xFF) - (img2.pixels[i] & 0xFF) );
    }

    movement /= img1.pixels.length;

    return movement;
}

/**
 *    Remove turqoise and make greyscale, then center and resize.
 */
PImage loadAndPrepSilhouette ( int i )
{
    String s = pngs[i];

    PImage sil = loadImage( silhouetteFolder + "/" + s );
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

    int[] bbox = boundingBox( sil );
    int[] com = centerOfMass( sil );

    sil = centerAndResize( sil, com, bbox );
    return sil;
}

/**
 *    Takes a PImage and centers and scales it into a fixed 
 *    target size of 128x128 for later pixel comparison.
 */
PImage centerAndResize ( PImage img, int[] centerOfMass, int[] boundingBox )
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

    return imgScaled;
}

