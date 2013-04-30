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

    int[] hash = RadialHashGenerator.generateHashAdaptive( sil64.pixels, tileSize, -1, new int[]{1,14,24,30,32,42,53,60} );
    
    HashingUtilities.normalizeValues( hash );
    
    return hash;
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

void addSQLiteDistanceFunctions ()
{
    try {
        
    // compare two blobs
        
    org.sqlite.Function.create( db.getConnection(), "hex_dist", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                byte[] val0 = value_blob(0);
                byte[] val1 = value_blob(1);
                
                int dist = 0;
            
                for ( int i = 0, k = val0.length; i < k; i ++ )
                {
                    int d = val0[i] - val1[i];
                    dist += d > 0 ? d : -d;
                }
                
                result( dist );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    
    // compare two longs
    
    org.sqlite.Function.create( db.getConnection(), "bit_dist", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                long val0 = value_long(0);
                long val1 = value_long(1);
                
                int dist = 0;
                
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
