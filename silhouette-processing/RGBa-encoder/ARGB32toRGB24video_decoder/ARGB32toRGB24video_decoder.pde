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

import processing.video.*;
import de.bezier.data.argbencoder.*;

Movie movie;

PImage img, img2, imgMask, frame;
int pixelsRGBa[];
float step = 1/25.0;

void setup() 
{
    size(640, 360);
    
    String m = sketchPath("../data/charmy_encoded4.mp4");
    m = "/Volumes/Verytim/2011_FIGD_April_Results/Ros_D01T02_withBackgroundAdjustment_Corrected/Images_BackgroundSubstracted/CamCenter.mp4";
    
    movie = new Movie( this, m );
    movie.play();
    movie.loop();
    movie.speed(1/5.0);
}

void draw() 
{
    //if ( millis() % 400 > 200 )
        background(0, 102, 153);
    //else background(255, 255-102, 255-153);
    
    if ( img != null ) 
    {
        image(img,  0, 0);
        image(img2, img.width, 0);
    }
}

int framesTotal = 0;
void movieEvent ( Movie movie )
{
    movie.read();
    frame = movie.get();

    img = frame;
    img2 = img.get();
    img.mask(img2);
    
    for ( int i = 0; i < img.pixels.length; i++ )
    {
        img.pixels[i] = ARGBEncoder.rgbToArgb(
                                img.pixels[i] >> 16 & 0xFF,
                                img.pixels[i] >>  8 & 0xFF,
                                img.pixels[i]       & 0xFF );
        
        img.pixels[i] = (((img.pixels[i] >> 24) & 0xFF) <= 192 ? 0x00000000 : 0xff000000) + (img.pixels[i] & 0xFFFFFF);                          
    }
    img.updatePixels();
    
    framesTotal++;
}
