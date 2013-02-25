/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    TODO: sketch description
 *
 *    P-2.0
 *    created: mbaer 20121228
 *    
 *    TODO: add word pluralization
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

String TITLE = "image difference variance";

XML srcXML;
String nttf;
TextSegmentList textSegments = new TextSegmentList();
int nttfLength;

PieceMakerApi api;
Piece piece;
VideoObjectList videos = new VideoObjectList();
PerformerVideosList performers = new PerformerVideosList();

// index of the video to load
int idx = 0;

// cycle through all videos and save frames
boolean saveAllFrames = false;

boolean loading = true;
String loadingMessage = "Loading pieces ...";

// missing markers at the start, currently only for juliette
int skipStartMarker = 0;

int performerIndex = 0;

int drawMode = 3;

int[] videoIDs = {
  232, 233, 234, 236, 235, 247, 248, // ros           0 -  6
  249, 250, 251, 252, 253, 255, 254, // juliette      7 - 13 | 2 markers missing at start, "scenefaux" marker added
  256, 257, 258, 259, 260, 261, 262  // jeanine       14 - 20
};

int toLoad = 0;

int currentID = videoIDs[idx];


boolean setupFinished = false;
boolean drawFrame = true;
boolean drawFill = true;

void setup ()
{
  size( 1400, 800 );
  //API_URL = "http://192.168.0.10:3000/";
  api = new PieceMakerApi( this, API_KEY,  API_URL);
  api.loadPieces( api.createCallback( "piecesLoaded" ) );
  loadXML();
  textFont( createFont( "", 10 ) );
}

void draw ()
{
  if ( loading ) {
    drawLoading();
    return;
  }
  
  else if (setupFinished && drawFrame) {
    drawFrame = false;
    
    background( 255 );
    
    drawOnePerformer();
    
    /*
    // cycles through all videos in videoIDs
    if (saveAllFrames) {
      setupFinished = false;
      saveFrame(video.title + "_#####_2.png");
      loading = true;
      idx++;
      if (idx == videoIDs.length) exit();
      else {
        currentID = videoIDs[idx];
        loadVideo(currentID);
      }
    }
    */
  }
}


void loadXML() {
  
    srcXML = null;
  try {
    srcXML = new XML( this, "NTTF_nodes_3.xml" );
    //println(srcXML);
  } 
  catch ( Exception e ) {
    e.printStackTrace();
  }

  int numChildren = srcXML.getChildren( "node" ).length;
  int i=0;

  nttf = "";

  for ( XML child : srcXML.getChildren( "node" ) )
  {
    //println( child.getChild("marker").getContent() );
    String m = child.getChild("marker").getContent();
    String t = child.getChild("text").getContent();

    int startIndex = 0;
    if (i>0) startIndex = textSegments.get(i-1).endIndex + 1;

    textSegments.add( new TextSegment(m, t, startIndex) );

    if (t != "") nttf += t + " ";
    i++;
  }
  nttf = nttf.toLowerCase();

  //nttfLength = nttf.length();
  nttfLength = split(nttf, " ").length;
}


void initData() {
  
  for (int i=0; i<videos.length(); i++) {
    VideoObject video = videos.get(i);
    String n = video.data.performer;
        
    if ( performers.has(n) ) {
      performers.get(n).add(video);
    }
    else {
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


