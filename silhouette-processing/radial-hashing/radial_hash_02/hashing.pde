
PImage loadPrepareBinaryImage ( String png )
{
    sil = loadImage( silhouetteFolder + "/" + png );
    sil.loadPixels();
    
    removeTurquoise( sil );

    sil.filter( GRAY );
    sil.filter( BLUR );
    sil.filter( THRESHOLD, 0.7 );
    
    return sil;
}

 void removeTurquoise ( PImage img )
{
    for ( int i = 0, k = img.pixels.length; i < k; i++ )
    {
        if ( img.pixels[i] == 0xFF00FFFF )
        {
            img.pixels[i] = 0xFFFFFFFF;
        }
    }
}

int[] computeHash ( PImage img, 
                    int centerOfMassX, int centerOfMassY, 
                    int boundingBoxCenterX, int boundingBoxCenterY, 
                    int boundingBoxWidth, int boundingBoxHeight )
{
    // center silhouette in image of size hash_size ^ 2
    
    int w = boundingBoxWidth + abs(boundingBoxCenterX-centerOfMassX);
    int h = boundingBoxHeight + abs(boundingBoxCenterY-centerOfMassY);
    
    int cx = centerOfMassX;
    int cy = centerOfMassY;
    
    int tileSize = 128;
    int tileSizeHalf = tileSize / 2;

    float wh = w > h ? w : h;
    float s = tileSize / wh;

    PGraphics pg = createGraphics( tileSize, tileSize );
    pg.beginDraw();
    pg.background( 255 );
    pg.image( img, -cx * s + tileSizeHalf, -cy * s + tileSizeHalf, img.width * s, img.height * s );
    removeCache( img );
    pg.endDraw();

    PImage sil64 = pg.get();
    sil64.updatePixels();

    // generate hash values

    int[] hash = RadialHashGenerator.generateHashAdaptive( sil64.pixels, tileSize, 5 );
    
    //HashingUtilities.normalizeValues( hash );
    
    sil = sil64.get();
    
    return hash;
}
