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
 *    http://ws.motionbank.org/project/average-silhouette-image
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

int silNumFrom = 0, silNumTo = 0;
int silNum = 0;

String silhouetteFolder;
String[] pngs;

String cameraAngle = "CamCenter";
String currentSession = null;

PieceMakerApi api;
ArrayList<EventTimeCluster> clusters;
EventTimeCluster currentCluster;
Video currentVideo;
int currentClusterIndex = 0;
org.piecemaker.models.Event currentEvent, lastEvent;
int currentEventIndex = 0;

boolean loading = true;
String loadingMessage = "Loading";
int clustersExpected = 0;

// Processing S'n'D
// ...............................

void setup ()
{
    size( 512, 256 );
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://sdcp-nttf-node13.herokuapp.com/" );
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
}

void draw ()
{
    background( 255 );
    
    if ( loading )
    {
        fill( 0 );
        text( loadingMessage, width/2, height/2 );
    }
    else
    {
        sil = loadAndPrepSilhouette( silNum );
        image( sil, 0, 0, width/2, height );
        removeCache( sil );
        
        addSilhouetteToMean( sil );
        PImage mean = meanToPImage();
        image( mean, width/2, 0, width/2, height );
        removeCache( mean );
        
        silNum++;
        
        if ( silNum >= silNumTo )
        {
            nextEvent();
        }
    }
}

// Stepping ahead to next image or directory
// ...............................

void nextEvent ()
{
    if ( currentEventIndex >= currentCluster.getEvents().length || currentEvent.title.equals("end") )
    {
        saveFrame( currentSession + "_" + cameraAngle + "/" +
                       currentEventIndex + "-" + lastEvent.title.replace(" ","-") + "_averageSilhouette.png" );
        nextCluster();
        return;
    }
    
    org.piecemaker.models.Event nextEvent = currentCluster.getEvents()[currentEventIndex];
    
    silNumFrom = (int)((currentEvent.getHappenedAt().getTime() - currentVideo.getHappenedAt().getTime()) / 20L);
    silNumTo   = (int)((nextEvent.getHappenedAt().getTime()    - currentVideo.getHappenedAt().getTime()) / 20L);
    silMean = null;
    silCount = 0;
    
    if ( silNumTo >= pngs.length )
    {
        println( "More frames calculated than PNGs are available: " + silNumTo + " / " + pngs.length );
        silNumTo = pngs.length-1;
    }
    
    lastEvent = currentEvent;
    currentEvent = nextEvent;
    currentEventIndex++;
}

void nextCluster ()
{
    if ( currentClusterIndex >= clusters.size() )
    {
        exit();
        return;
    }
    
    currentCluster = clusters.get( currentClusterIndex );
    for ( Video v : currentCluster.getVideos() )
    {
        if ( v.title.contains("_Center_") )
        {
            currentVideo = v;
            String[] parts = v.title.split("_");
            currentSession = parts[1] + '_' + parts[0];
            initPngs();
            break;
        }
    }
    
    currentEvent = currentCluster.getEvents()[0];
    currentEventIndex = 1;
    
    nextEvent();
    
    silNum = silNumFrom;
    silMean = null;
    silCount = 0;
    
    currentClusterIndex++;
}
