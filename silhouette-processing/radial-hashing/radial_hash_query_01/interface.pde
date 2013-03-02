public class Button
{
    float x, y, width, height;
    boolean hover;
    
    Button ( float _x, float _y, float _width, float _height )
    {
        x = _x; y = _y; width = _width; height = _height;
        Interactive.add( this );
    }
    
    void mouseEntered ()
    {
        hover = true;
    }
    
    void mouseExited ()
    {
        hover = false;
    }
    
    void mousePressed ()
    {
        Interactive.send( this, "buttonPressed" );
    }
    
    void draw ()
    {
        stroke( 120 );
        fill( hover ? 200 : 170 );
        rectMode( CORNER );
        rect( x, y, width, height );
    }
}

void buttonPressed ()
{
    results = null;
    
    float[] bbox = skeleton.getBoundingBox();
    
    PGraphics pg = createGraphics( (int)(bbox[2]-bbox[0])+100, (int)(bbox[3]-bbox[1])+100 );
    pg.beginDraw();
    pg.background( 255 );
    pg.translate( -(int)bbox[0]+50, -(int)bbox[1]+50 );
    skeleton.drawSkeleton(pg);
    pg.endDraw();
    
    PImage img = pg.get();
    
    for ( int i = 0, k = img.pixels.length; i < k; i++ )
    {
        if ( img.pixels[i] != 0xFFFFFFFF ) img.pixels[i] = 0xFF000000;
    }
    mugshot = img;
    
    img.filter( BLUR, 2 );
    img.filter( THRESHOLD, 0.7 );

    ImageUtilities.PixelLocation centerOfMass = 
        ImageUtilities.getCenterOfMass( img.pixels, 
                                        img.width, img.height );

    ImageUtilities.PixelCircumCircle circumCircle = 
        ImageUtilities.getCircumCircle( img.pixels, 
                                        img.width, img.height, 
                                        centerOfMass.x, centerOfMass.y );
    
    int[] hash = computeHash( img, 
                              centerOfMass.x, centerOfMass.y, 
                              circumCircle.x, circumCircle.y, 
                              circumCircle.radius*2, circumCircle.radius*2 );
    
    int[] hashBits = new int[hash.length * 8];
    for ( int i = 0; i < hash.length; i++ )
    {
        int aByte = hash[i] & 0xFF;
        for ( int ii = 0; ii < 8; ii++ )
        {
            hashBits[i*8 + ii] = (aByte >> (7-ii)) & 0x1;
        }
    }
    FastHash fullHash = new FastHash( hashBits );
    
    int[] hashFast = new int[64];
    float k = ceil(hash.length / (float)hashFast.length);
    for ( int i = 0, ii = 0; i < hash.length; i++ )
    {
        ii = (int)round(i / k);
        if ( ii < hashFast.length )
            hashFast[ii] += (hash[i] & 0xFF) > 127 ? 1 : 0;
    }
    for ( int i = 0; i < hashFast.length; i++ )
    {
        hashFast[i] /= k;
    }
    FastHash fastHash = new FastHash( hashFast );
    
    PImage[] imgs = null;
    if ( db != null )
    {
        imgs = new PImage[0];

        db.query( "SELECT id, "+
                         "file, "+
                         "bit_dist( %d, fasthash ) AS bdist, "+
                         "hex_dist( X'%s', hash ) AS dist, "+
                         "performance "+
                      "FROM silhouettes "+
                      "WHERE "+
                            "bdist <= 2 AND "+
                            "dist < ((length(hash) * 255) / 10) "+
                      "ORDER BY dist ASC "+
                      "LIMIT 20",
                      fastHash.toLong64(),
                      fullHash.toHexString()
                 );
        
        String basePath = "/Volumes/Verytim/2011_FIGD_April_Results";
        if ( ! new File(basePath).exists() ) {
            System.err.println( "\n\tThumbnails not available: " + basePath );
            exit();
            return;
        }
        while ( db.next() )
        {
            String filename = db.getString( "file" );
            PImage ii = loadImage( basePath + "/" + filename );
            if ( ii != null )
            {
                imgs = (PImage[])append( imgs, ii );
            }
        }
    }
    if ( imgs != null ) results = imgs;
    
    mugshot = img;
}
