/**
 *    Motion Bank research, http://motionbank.org
 */

PImage img;
HumanSilhouette silhouette;

void setup ()
{
    size( 500, 500 );

    img = loadImage( "silhouette2.png" );
    silhouette = new HumanSilhouette( img );
}

void draw ()
{
    image( silhouette.circular, 0, 0 );
}

int[] getBBox ( PImage img )
{
    int scl = 20;

    PImage scaled = img.get();
    scaled.resize(img.width/scl, img.height/scl);
    int xmi = Integer.MAX_VALUE, xma = Integer.MIN_VALUE;
    int ymi = Integer.MAX_VALUE, yma = Integer.MIN_VALUE;
    int xx, yy;
    for ( int i = 0; i < scaled.pixels.length; i++ )
    {
        if ( (scaled.pixels[i] & 0xFF) > 0 )
        {
            xx = i % scaled.width;
            yy = i / scaled.width;
            xmi = min( xmi, xx );
            xma = max( xma, xx );
            ymi = min( ymi, yy );
            yma = max( yma, yy );
        }
    }
    if ( xmi-1 > 0 ) xmi -= 1;
    if ( xma+1 < img.width ) xma += 1;
    if ( ymi-1 > 0 ) ymi -= 1;
    if ( yma+1 < img.height ) yma += 1;
    xmi *= scl;
    xma *= scl;
    ymi *= scl;
    yma *= scl;

    //image( scaled, 0,0, width, height );
    /*noFill();
     stroke(255,0,0);
     rectMode( CORNERS );
     rect( xmi, ymi, xma, yma );*/

    return new int[] { 
        xmi, ymi, xma, yma
    };
}

PImage removeSmacksFillHoles ( PImage img )
{
    PImage ret = img.get();
    int[] indices = new int[] {
        -ret.width-1, -ret.width, -ret.width+1, 
        -1, 1, 
        ret.width-1, ret.width, ret.width+1
    };

    for ( int i = 1+ret.width; i < ret.pixels.length-1-ret.width; i++ )
    {
        if ( i%ret.width == 0 || i%ret.width == ret.width ) continue;

        int p = img.pixels[i] & 0xFF;

        int s = 0;
        for ( int ii = 0; ii < indices.length; ii++ )
        {
            s += ((img.pixels[i + indices[ii]] & 0xFF) == 255) ? 1 : 0;
        }

        ret.pixels[i] = s > 4 ? 0xFFFFFFFF : 0xFF000000;
    }
    ret.updatePixels();

    return ret;
}

