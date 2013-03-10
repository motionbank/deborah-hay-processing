/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Using center of mass code to track left/right cam and generate 2D tracks for 3D track calculation.
 *
 *    Processing 2.0
 *    created: fjenett 20130310
 */
 
 import de.bezier.data.sql.*;
 import org.motionbank.imaging.*;
 
 String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";
 
 int currentTake = 0;
 String[] takes;
 
 int currentPng = 0;
 String[] pngs;
 
 String comTracksLeft, comTracksRight;
 ImageUtilities.PixelLocation centerOfMass;
 PImage silImage;
 
 void setup ()
 {
     size( 600, 300 );
     
     //initTakes();
     initPngs();
     
     frameRate( 999 );
 }
 
 void draw ()
 {
    background( 255 );
    
    silImage = loadPrepareBinaryImage( pngs[currentPng] );
    
    if ( silImage.width > 10 )
    {
        silImage.filter( BLUR, 3 );
        silImage.filter( THRESHOLD, 0.7 );
    }
    
    centerOfMass = 
        ImageUtilities.getCenterOfMass( silImage.pixels, 
                                        silImage.width, silImage.height );
    
    comTracksLeft += centerOfMass.x + " " + centerOfMass.y + "\n";
    
    image( silImage, 0,0 );
    removeCache( silImage );
    
    
    fill( 255, 0, 0 );
    noStroke();
    ellipse( centerOfMass.x, centerOfMass.y, 7, 7 );
    
    silImage = loadPrepareBinaryImage( pngs[currentPng].replace("CamLeft","CamRight") );
    
    if ( silImage.width > 10 )
    {
        silImage.filter( BLUR, 3 );
        silImage.filter( THRESHOLD, 0.7 );
    }
    
    centerOfMass = 
        ImageUtilities.getCenterOfMass( silImage.pixels, 
                                        silImage.width, silImage.height );
    
    comTracksRight += centerOfMass.x + " " + centerOfMass.y + "\n";
    
    image( silImage, width/2,0 );
    removeCache( silImage );
    
    ellipse( centerOfMass.x, centerOfMass.y, 7, 7 );
    
    currentPng++;
    if ( currentPng == pngs.length ) 
    {
        saveStrings( silhouetteFolder + "/" + takes[currentTake] + "/" + "comTrack2DCamLeft",  comTracksLeft.split(" ") );
        saveStrings( silhouetteFolder + "/" + takes[currentTake] + "/" + "comTrack2DCamRight", comTracksRight.split(" ") );
        
        currentTake++;
        if ( currentTake == takes.length )
        {
            exit();
            return;
        }
        
        initPngs();
    }
 }
