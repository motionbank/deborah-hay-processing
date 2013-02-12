/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Calculating visual movement in a track of silhouettes by comparing 
 *    neighboring pairs for image brightness differences.
 *
 *    The idea is that the more movement happened the more difference 
 *    there is between two frames. To generate a good data set this needs
 *    to run against multiple camera angles and a mean of all of those
 *    data streams should be used.
 *
 *    Discuss here:
 *    http://ws.motionbank.org/project/calculating-visible-movement-comparing-adjacent-silhouettes
 *
 *    P2.0
 *    created: fjenett 20130207
 */

PImage sil, silNext;
int currentSil = 0;

String silhouetteFolder;
String[] pngs;

int[] movements;
float blockSumMax = 0;

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
String cameraAngle = "CamRight";
int currentSession = 0;

// Processing S'n'D
// ...............................

void setup ()
{
    size( 900, 400 );
    
    nextSession();
}

void draw ()
{
    background( 255 );
    
    silNext = loadAndPrepSilhouette( currentSil );
    image( silNext, 0, 0 );
    removeCache( silNext );
    image( sil, silNext.width, 0 );
    removeCache( sil );
    
    int imageDiff = calcImageDifference( sil, silNext );
//    fill( 0 );
//    text( imageDiff, 5, sil.height + 12 );
    movements[ currentSil-1 ] = imageDiff;
    
    stroke(0);
    noFill();
    beginShape();
    int blockWidth = movements.length / (width-20);
    for ( int b = 0; b < width; b++ )
    {
        float blockSum = 0;
        for ( int i = 0; i < blockWidth; i++ )
        {
            if ( b*blockWidth + i < movements.length )
                blockSum += movements[ b*blockWidth + i ];
        }
        blockSum /= blockWidth;
        blockSumMax = max( blockSumMax, blockSum );
        vertex( 10 + b, height-10-map(blockSum, 0, blockSumMax, 0, 150) );
    }
    endShape();
    
    sil = silNext;
    
    updateStepper();
    
    if ( currentSil >= pngs.length )
    {
        String[] lines = new String[movements.length];
        for ( int i = 0; i < movements.length; i++ )
        {
            lines[i] = movements[i] + "";
        }
        
        saveStrings( "output/" + sessions[currentSession-1]+"_"+cameraAngle+"/imageDifferences.txt", lines );
        saveFrame( "output/" + sessions[currentSession-1]+"_"+cameraAngle+"/imageDifference.png" );
        
        nextSession();
    }
}

// Stepping ahead to next image or directory
// ...............................

void updateStepper ()
{
    currentSil += 1;
}

void nextSession ()
{
    if ( currentSession == sessions.length )
    {
        exit();
        return;
    }
    
    currentSil = 0;
    blockSumMax = 0;
    
    initPngs();
    movements = new int[pngs.length];
    
    sil = loadAndPrepSilhouette( currentSil );
    
    updateStepper();
    
    currentSession++;
}
