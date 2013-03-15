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
    frameRate( 10 );
    
    movie = new Movie(this,sketchPath("../data/charmy.mp4"));
    movie.play();
    //movie.loop();
    movie.speed(1/1);
}

void draw() 
{
    //if ( millis() % 400 > 200 )
        background(0, 102, 153);
    //else background(255, 255-102, 255-153);
    
    if ( img != null ) image(img,  0, 0);
    if ( img2 != null ) image(img2, img.width, 0);
}

int framesTotal = 0;
void movieEvent ( Movie movie )
{
    movie.read();
    frame = movie.get();
    
    img =     frame.get(frame.width/2,0, frame.width/2,frame.height);
    imgMask = frame.get(0,0,             frame.width/2,frame.height);
    img.mask(imgMask);
    img2 = img.get();
    
    for ( int i = 0; i < img.pixels.length; i++ )
    {
        img.pixels[i] = ARGBEncoder.argbToRgb( 
                                   img.pixels[i] >> 24 & 0xFF,
                                   img.pixels[i] >> 16 & 0xFF,
                                   img.pixels[i] >> 8  & 0xFF,
                                   img.pixels[i]       & 0xFF );
    }
    
    img.save( sketchPath( "../frames4/" + nf(framesTotal,8) + ".png" ) );
    
    for ( int i = 0; i < img.pixels.length; i++ )
    {
        img.pixels[i] = ARGBEncoder.rgbToArgb(
                                img.pixels[i] >> 16 & 0xFF,
                                img.pixels[i] >>  8 & 0xFF,
                                img.pixels[i]       & 0xFF );
    }
    img.updatePixels();
    
    framesTotal++;
}
