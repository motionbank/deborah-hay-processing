/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Use Google image similarity search to find similar images to the silhouettes.
 *    Create a "Solo commissioning project" instance from these: 
 *    http://www.deborahhay.com/about.html
 *
 *    fjenett 20121205
 */

import java.io.*;

String[] files;
String[] googleImageSearchResults;
PImage currentImg = null;
String currentFile = null;

// http://hc.apache.org/httpclient-3.x/apidocs/index.html
// http://jsoup.org/

void setup ()
{
    size( 400, 130 );

    //googleImageSearchByUrl( "http://florianjenett.de/files/gimgs/12_dsc0051ret.jpg" );
    //googleImageSearchByImage( new File(sketchPath("data/CamCenter_BackgroundSubstracted000200.png")) );
    
    files = loadStrings( "files.txt" );
    googleImages();
}

void draw ()
{
    background( 255 );
    
    if ( currentImg != null ) {
        ///image( currentImg, 0, 0 );
    }
    if ( currentFile != null ) {
        fill( 0 );
        textAlign( CENTER );
        text( currentFile, width/2, height/2-8 );
    }
}

void googleImages ()
{
    new Thread(){
        public void run () {
            for ( int n = 1000, k = files.length; n < k; n+=1 )
            {
                String file = files[n];
                
                PImage img = loadImage( file );
                img.loadPixels();
                for ( int i = 0; i < img.pixels.length; i++ )
                {
                    if ( img.pixels[i] == 0xFF00FFFF )
                    {
                        img.pixels[i] = 0xFFFFFFFF;
                    }
                }
                img.save( sketchPath( "tmp.png" ) );
                currentImg = img;
                img = null;
                
                googleImageSearchResults = null;
                googleImageSearchByImage( new File( sketchPath( "tmp.png" ) ) );
                if ( googleImageSearchResults != null )
                {
                    String resultsFile = file.replace("/CamCenter/","/CamCenterGoogle/").replace(".png",".txt");
                    saveStrings( resultsFile, googleImageSearchResults );
                }
                currentFile = (new File( file )).getName();
                delay( 2000 );
            }   
        }
    }.start();
}
