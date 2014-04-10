/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Processing 2.0
 *    created fjenett 2012 ??
 */

import org.piecemaker.api.*;
import org.piecemaker.models.*;
import org.piecemaker.collections.*;

import java.util.Date;
import java.util.Map;
import java.text.SimpleDateFormat;

final int PIECE_ID = 3;
final boolean isLocal = true;
final boolean mbLocal = false;
final String TRACK_3D_ROOT = (isLocal ? "http://moba-lab.local/" : "http://lab.motionbank.org/") + "dhay/data";
String LOCAL_DATA_PATH = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
String POSITION_DATA_DIR = "paths/";
String POSITION_DATA_FILE = "_withBackgroundAdjustment_Corrected/Tracked3DPosition_com.txt";

PieceMakerApi api;
boolean loaded = false;
String loadingMessage = "Loading piece";
int groupsLoading = 0;

VideoEventGroup[] groups;
int currentGroup = 0;
int currentSeg = 0;
int currentHeatMap = 0;

String performer = "Juliette";

SceneHeatMap[] multMaps;

boolean saveAll = true;

Date timeMin, timeMax;

void setup () 
{
  size( 640, 420 );
    smooth();
  groups = new VideoEventGroup[0];
  multMaps = new SceneHeatMap[0];
  
  //noLoop();

  api = new PieceMakerApi(this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com" );
  loadingMessage = "Loading videos for piece";
  api.loadVideosForPiece( PIECE_ID, api.createCallback("videosLoaded") );
}

void draw ()
{
  background( 255 );

  if ( loaded )
  {
    if ( groups[currentGroup] != null )
    {
      //fill( 0 );
      //text( groups[currentGroup].video.getTitle(), 5, 15 );

      //groups[currentGroup].heatMaps[currentHeatMap].draw( 250, 25, 200, 200 );
      int w = 360;
      //groups[currentGroup].videoHeatMap.draw( floor((width-w)/2.0), floor((height-w)/2.0), w, w );
      multMaps[currentSeg].draw( floor((width-w)/2.0), floor((height-w)/2.0), w, w );
    }
    
    if (saveAll) {
      String t = multMaps[currentSeg].title;
      saveFrame("output/saves4_c/" + performer + "_" + t.replaceAll("[^-a-zA-Z0-9]+","-")  + ".png");
      currentSeg++;
      if ( currentSeg >= multMaps.length ) exit();
      //redraw();
    }
    
    
//    if (saveAll) {
//      String t = groups[currentGroup].video.getTitle();
//      saveFrame("saves5/" + t.substring(0,t.indexOf("_"))  + ".png");
//      currentGroup++;
//      if ( currentGroup >= groups.length ) exit();
//    }
  }
  else
  {
    fill( 0 );
    text( loadingMessage, 20, 20 );
  }
}

