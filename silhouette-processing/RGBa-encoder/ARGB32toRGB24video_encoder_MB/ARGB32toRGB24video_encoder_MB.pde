/**
 *    Playing with idea to store ARGB in RGB by reducing color range 
 *    from 0-255 to 0-127 for R,G,B and 0-255 to 0-7 for A.
 *
 *    https://gist.github.com/3948111
 *
 *    Use these images from standard examples (or add your own):
 *        Processing > Examples > Basic > Image > Alphamask
 *
 *    fjenett 2012
 */

import de.bezier.data.argbencoder.*;

PImage img, img2, img3;
int pixelsRGBa[];
float step = 1/25.0;

String dir = "/Volumes/Verytim/2011_FIGD_April_Results/Ros_D01T01_withBackgroundAdjustment_Corrected/Images_BackgroundSubstracted";
String pngDir = dir + "/" + "CamCenter";

PGraphics pg;
PImage tImg;
int bCol, totalPngs;

void setup()
{
    size(640, 360);
    //frameRate( 5 );
    
    println( g.getClass() );

    pg = createGraphics( 316, 316 );
    tImg = createImage( 316, 316, RGB );
    tImg.loadPixels();
    
    bCol = ARGBEncoder.argbToRgb( 0, 0, 255, 255 );
    
    totalPngs = new File(pngDir).list().length;
}

void draw() 
{
    background(255);
    
    fill( 0 ); noStroke();
    rect( 0,0,map(framesTotal,0,totalPngs,0,width), height );

    nextImage();
}

int framesTotal = 0;
void nextImage ()
{
    img = loadImage( pngDir + "/" + "CamCenter_BackgroundSubstracted" + nf(framesTotal, 6) + ".png" );
    img.format = ARGB;

    int a, r, g, b;
    for ( int i = 0; i < img.pixels.length; i++ )
    {
        r = img.pixels[i] >> 16 & 0xFF;
        g = img.pixels[i] >> 8  & 0xFF;
        b = img.pixels[i]       & 0xFF;

        a = img.pixels[i] == 0xff00FFFF ? 0 : 255;

        img.pixels[i] = ARGBEncoder.argbToRgb( a, r, g, b );
    }
    
    Arrays.fill( tImg.pixels, bCol );
    for ( int iy = 0; iy < img.height; iy++ )
    {
        System.arraycopy( img.pixels, iy * img.width, tImg.pixels, iy * tImg.width, img.width );
    }
    tImg.save( dir + "/" + "CamCenterEncoded" + "/" + nf(framesTotal,6) + ".png" );

//    pg.beginDraw();
//    pg.background( ARGBEncoder.argbToRgb( 0, 0, 255, 255 ) );
//    pg.image( img, 0, 0 );
//    pg.save( dir + "/" + "CamCenterEncoded" + "/" + nf(framesTotal,6) + ".png" );
//    pg.endDraw();
//    //img3 = pg.get();

    //image( tImg, 0, 0 );
    
//    
//    for ( int i = 0; i < img.pixels.length; i++ )
//    {
//        img.pixels[i] = ARGBEncoder.rgbToArgb(
//                                img.pixels[i] >> 16 & 0xFF,
//                                img.pixels[i] >>  8 & 0xFF,
//                                img.pixels[i]       & 0xFF );
//    }
//    img.updatePixels();
    
    framesTotal++;

    //    if ( img != null ) image(img, 0, 0);
    //    if ( img2 != null ) image(img2, img.width, 0);
    //    if ( img2 != null ) image(img3, 2*img.width, 0);

    img = null; 
    img2 = null; 
    img3 = null;
}

PImage loadImage( String filename ) 
{
    byte bytes[] = loadBytes(filename);
    Image awtImage = java.awt.Toolkit.getDefaultToolkit().createImage(bytes);
    PImage image = loadImageMT(awtImage);
    awtImage = null;
    return image;
}

PImage loadImageMT(Image awtImage) 
{
    java.awt.MediaTracker tracker = new java.awt.MediaTracker(this);
    tracker.addImage(awtImage, 0);
    try {
        tracker.waitForAll();
    } 
    catch (InterruptedException e) {
    }

    PImage image = new PImage(awtImage);
    image.parent = this;
    tracker = null;
    return image;
}

