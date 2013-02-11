/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    How das the mean of all silhouettes of one performance look like?
 *
 *    Interesting finding: could be that key-moments can be detected by
 *    subtracting the current silhouette from the mean of the last 100 
 *    (or less/more).
 *
 *    Discuss here:
 *
 *    P2.0
 *    created: fjenett 20130211
 */

import org.piecemaker.api.*;
import org.piecemaker.models.*;
import org.piecemaker.collections.*;

// Settings, variables and constants
// ----------------------------

PImage sil;
int[] silMean;
int silMeanWidth = 0, silMeanHeight = 0;
int silCount = 0;
int current = 0;

String silhouetteFolder;
String[] pngs;

String[] sessions = {
    "Ros_D01T01",
    "Ros_D01T02",
    "Ros_D01T03",
    "Ros_D01T04",
    "Ros_D02T01",
    "Ros_D02T02",
    "Ros_D02T03",
    "Juliette_D03T01",
    "Juliette_D03T02",
    "Juliette_D03T03",
    "Juliette_D03T04",
    "Juliette_D04T01",
    "Juliette_D04T02",
    "Juliette_D04T03",
    "Janine_D05T01",
    "Janine_D05T02",
    "Janine_D05T03",
    "Janine_D06T01",
    "Janine_D06T02",
    "Janine_D06T03",
    "Janine_D06T04",
};
String cameraAngle = "CamCenter";
int currentSession = 0;

// Processing S'n'D
// ...............................

void setup ()
{
    size( 512, 256 );
    
    nextSession();
}

void draw ()
{
    background( 255 );
    
    sil = loadAndPrepSilhouette( current );
    image( sil, 0, 0, width/2, height );
    removeCache( sil );
    
    addSilhouetteToMean( sil );
    PImage mean = meanToPImage();
    image( mean, width/2, 0, width/2, height );
    removeCache( mean );
    
    updateStepper();
    
    if ( current >= pngs.length )
    {
        saveFrame( sessions[currentSession-1]+"_"+cameraAngle+"/averageSilhouette.png" );
        
        nextSession();
    }
}

// Stepping ahead to next image or directory
// ...............................

void updateStepper ()
{
    current += 1;
}

void nextSession ()
{
    if ( currentSession == sessions.length )
    {
        exit();
        return;
    }
    
    current = 0;
    
    initPngs();
    
    updateStepper();
    
    currentSession++;
}
