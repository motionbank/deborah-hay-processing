/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    TODO: - sketch description
 *          - first frame = data event happenedAt
 *          - simplified position: add end and start marker
 *    
 *    P-2.0
 *    created: mbaer 20121228
 *    
 *    TODO: add word pluralization
 */


/*
 
 VideoObjectList
 - VideoObject[]
 --- VideoData            // whole video: data
 ----- PositionData
 ----- SpeedData
 --- VideoSegmentList
 -----VideoSegment[]      // segments: data
 ------- PositionData
 ------- SpeedData
 
 */

/*
video 232 D01T01_Ros_sync_AJA_1 Mon Apr 18 11:13:21 CEST 2011
 video 233 D01T02_Ros_sync_AJA_1 Mon Apr 18 12:25:39 CEST 2011
 video 234 D01T03_Ros_sync_AJA_1 Mon Apr 18 14:54:41 CEST 2011
 video 236 D01T04_Ros_sync_AJA_1 Mon Apr 18 16:13:51 CEST 2011
 video 235 D02T01_Ros_sync_AJA_1 Tue Apr 19 11:03:26 CEST 2011
 video 247 D02T02_Ros_sync_AJA_1 Tue Apr 19 12:03:07 CEST 2011
 video 248 D02T03_Ros_sync_AJA_1 Tue Apr 19 14:39:59 CEST 2011
 video 249 D03T01_Juliette_sync_AJA_1 Wed Apr 20 11:27:16 CEST 2011
 video 250 D03T02_Juliette_sync_AJA_1 Wed Apr 20 12:34:25 CEST 2011
 video 251 D03T03_Juliette_sync_AJA_1 Wed Apr 20 14:48:57 CEST 2011
 video 252 D03T04_Juliette_sync_AJA_1 Wed Apr 20 15:53:46 CEST 2011
 video 253 D04T01_Juliette_sync_AJA_1 Thu Apr 21 11:01:41 CEST 2011
 video 255 D04T02_Juliette_sync_AJA_1 Thu Apr 21 12:10:16 CEST 2011
 video 254 D04T03_Juliette_sync_AJA_1 Thu Apr 21 14:41:06 CEST 2011
 video 256 D05T01_Janine_sync_AJA_1 Fri Apr 22 10:59:07 CEST 2011
 video 257 D05T02_Janine_sync_AJA_1 Fri Apr 22 12:02:42 CEST 2011
 video 258 D05T03_Janine_sync_AJA_1 Fri Apr 22 14:33:07 CEST 2011
 video 259 D06T01_Janine_sync_AJA_1 Sat Apr 23 10:41:48 CEST 2011
 video 260 D06T02_Janine_sync_AJA_1 Sat Apr 23 11:57:11 CEST 2011
 video 261 D06T03_Janine_sync_AJA_1 Sat Apr 23 14:33:59 CEST 2011
 video 262 D06T04_Janine_sync_AJA_1 Sat Apr 23 15:39:29 CEST 2011
 */

import org.piecemaker.collections.*;
import org.piecemaker.models.*;
import org.piecemaker.api.*;

import cue.lang.*;
import java.util.Map.Entry;

import java.util.*;
import java.io.*;

String API_KEY  = "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe";
String API_URL  = "http://notimetofly.herokuapp.com/";
String DATA_URL = "http://lab.motionbank.org/dhay/data/";


String LOCAL_DATA_PATH = "/Users/mbaer/Documents/_Gestaltung/__Current/motionbank/_data/";

// LOCAL_DATA_PATH + SPEED_DATA_DIR + [video title] + SPEED_DATA_FILE
String SPEED_DATA_DIR = "speed/";
String SPEED_DATA_FILE = "_withBackgroundAdjustment_Corrected/TravelDistances3D_interpolated.txt";

String POSITION_DATA_DIR = "paths/";
String POSITION_DATA_FILE = "_withBackgroundAdjustment_Corrected/Tracked3DPosition_com.txt";

String SAVE_PATH = "output/0/";


////////////////////////////////////
//  DRAW SETTINGS
////////////////////////////////////

float mainX = 50;
float mainY = 50;
float distY = 20;
float distX = 40;
float minSpeed = 0;

// calculated in setup
float mainW = 0;
float mainH = 0;
float scale = 0;
float maxSpeed = 0;
float graphWidth = 0;

// => color hash
color colorLight = 0;
color colorDark = 0;
color colorBg = 0xFFEDEDED;
color colorStage = 0xFFDEDEDE;

float colorLightOpacity = 64;

////////////////////////////////////



String TITLE = "";

XML srcXML;
String nttf;
int nttfLength;

PieceMakerApi api;
Piece piece;
VideoObjectList videos = new VideoObjectList();
PerformerVideosList performers = new PerformerVideosList();



// index of the video to load
// 0-6
int idx = 0;
// 0-25
int segIdx = 0;
// 0-2
int performerIndex = 0;

// cycle through all videos and save frames
boolean saveAllFrames = false;

boolean loading = true;
String loadingMessage = "Loading pieces ...";


/*
// AJA
 int[] videoIDs = {
 232, 233, 234, 236, 235, 247, 248, // ros           0 -  6
 249, 250, 251, 252, 253, 255, 254, // juliette      7 - 13 | 2 markers missing at start, "scenefaux" marker added
 256, 257, 258, 259, 260, 261, 262  // jeanine       14 - 20
 };
 */

// CENTER CAM
int[] videoIDs = {
    76, 77, 79, 81, 82, 83, 80, // ros           0 -  6
    84, 87, 88, 89, 90, 91, 86, // juliette      7 - 13 | 2 markers missing at start, "scenefaux" marker added
    95, 96, 97, 98, 99, 85, 100  // jeanine       14 - 20
};

int toLoad = 0;

int currentID = videoIDs[idx];


boolean setupFinished = false;
boolean drawFrame = true;
boolean drawFill = true;


float[] gaussKernel; // = new float[]{0.006,0.061,0.242,0.383,0.242,0.061,0.006};


static HashMap<String,Integer> moBaColors, moBaColorsHigh, moBaColorsLow; 
static {
    moBaColorsHigh = new HashMap();
    moBaColorsLow = new HashMap();
    
    moBaColorsHigh.put( "Ros", 0xFF1E8ED4 );
    moBaColorsLow.put(  "Ros", 0xFF254966 );
    
    moBaColorsHigh.put( "Janine", 0xFFE04646 );
    moBaColorsLow.put(  "Janine", 0xFF803B3B );
    
    moBaColorsHigh.put( "Juliette", 0xFF349C00 );
    moBaColorsLow.put(  "Juliette", 0xFF2B6100 );
}


void setup ()
{
    size( 640, 420 );
    //API_URL = "http://192.168.0.10:3000/";
    //noSmooth();
    smooth();
    api = new PieceMakerApi( this, API_KEY, API_URL);
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
    textFont( createFont( "", 10 ) );
    
    mainW = width - mainX*2;
    mainH = height - mainY*2;
    maxSpeed = (mainH-6*distY)/7;
    scale = mainH/15.0;
    graphWidth = (mainW-2*distX) / 3;

    gaussKernel = new float[10*2+1];
    for ( int i = 0; i < gaussKernel.length; i++ )
    {
        float v = (i-(gaussKernel.length/2))/(gaussKernel.length/2.0) * 4;
        println( i + " " + v );
        gaussKernel[i] = guassianKernel( v );
    }
}

void draw ()
{
    if ( loading ) {
        drawLoading();
        return;
    } else if (setupFinished) {

        drawFrame = false;

        __draw();

        // cycles through all videos in videoIDs
        if (saveAllFrames) {

            VideoObject v = videos.get(idx);
            PerformerVideos perf = performers.get(performerIndex);

            String t = perf.get(idx).data.file.title;
            saveFrame(SAVE_PATH + t.substring(0, t.indexOf("_")) + "_" + v.segments.get(segIdx).event.title.replaceAll("[^-a-zA-Z0-9]+", "-") + ".png");      
            drawFrame = true;

            segIdx++;

            if (segIdx == 25) {
                idx++;
                segIdx = 0;

                if (idx == 7) {
                    performerIndex++;
                    idx = 0;
                }
            }
            if (performerIndex == performers.length()) exit();
        }
    }
}




void initData() {

    for (int i=0; i<videos.length(); i++) {
        VideoObject video = videos.get(i);
        String n = video.data.performer;

        if ( performers.has(n) ) {
            performers.get(n).add(video);
        } else {
            performers.add(n, video);
        }
    }

    drawFrame = true;

    float total = 0;

    println("events loaded");
    setupFinished = true;
}



void drawLoading ()
{
    background( 255 );

    fill( 0 );
    textAlign( CENTER );
    text( loadingMessage, width/2, height/2 );
}

float guassianKernel ( float v )
{
    return (1.0 / sqrt(TWO_PI)) * exp( -0.5 * (v*v) );
}

float[] convolve1D ( float[] in, float[] kernel )
{
    int i, j, k;
    int dataSize = in.length;
    int kernelSize = kernel.length;
    float[] out = new float[dataSize];

    for ( i = 0; i < dataSize; i++ )
    {
        for ( j = 0; j < kernelSize; j++ )
        {
            k = j - kernelSize/2;
            if ( i+k >= 0 && i+k < dataSize )
                out[i] += in[i+k] * kernel[j];
        }
    }

    return out;
}

