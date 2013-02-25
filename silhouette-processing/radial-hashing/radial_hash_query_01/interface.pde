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
    
    int[] bbx = boundingBox( img );
    int[] com = centerOfMass( img );
    int[] hash = computeHash(img, com, bbx);
    int fasthash = toFasthash(hash);
    
    PImage[] imgs = null;
    if ( db != null )
    {
        imgs = new PImage[0];
        String vals = "";
        for ( int i = 0; i < 32; i++ )
        {
            vals += (vals.length() > 0 ? " + " : "") + String.format( "abs(v%03d - %d)", i, hash[i] );
        }
        db.query( "SELECT file, hamming_distance(fasthash, %d) AS hdist, (%s) AS dist FROM %s WHERE hdist < 3 ORDER BY dist LIMIT 16", fasthash, vals, "images" );
        
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
