
PImage loadPrepareBinaryImage ( String png )
{
    sil = loadImage( silhouetteFolder + "/" + png );
    sil.loadPixels();
    
    removeTurquoise( sil );

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

int[] computeHash ( PImage img, int centerOfMassX, int centerOfMassY, 
                    int boundingBoxCenterX, int boundingBoxCenterY, int boundingBoxWidth, int boundingBoxHeight )
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
    pg.image( sil, -cx * s + tileSizeHalf, -cy * s + tileSizeHalf, sil.width * s, sil.height * s );
    removeCache( sil );
    pg.endDraw();

    PImage sil64 = pg.get();
    sil64.updatePixels();

    // generate hash values

    RadialHashGenerator generator = new RadialHashGenerator();
    int[] hash = generator.generateHash( sil64.pixels, tileSize, 8, 4 );
    
    HashingUtilities.normalizeValues( hash );
    
    sil = sil64.get();
    
    return hash;
}
