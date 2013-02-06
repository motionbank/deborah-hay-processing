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

String BASE_URL = "http://notimetofly.herokuapp.com/";

XML srcXML;
String nttf;
TextSegmentList textSegments = new TextSegmentList();
int nttfLength;

PieceMakerApi api;
Piece piece;
Video video;
float videoDuration = 0;
float traveledTotal = 0;
Video[] videos;
org.piecemaker.models.Event[] events;
VideoSegmentList videoSegments;

// index of video to load
int idx = 0;

// cycle through all videos and save frames
boolean saveAllFrames = false;

boolean loading = true;
String loadingMessage = "Loading pieces ...";

// missing markers at the start, currently only for juliette
int skipStartMarker = 0;

int[] videoIDs = {
  //232, 233, 234, 236, 235, 247, 248, // ros           0 -  6
  249, 250, 251, 252, 253, 255, 254, // juliette      7 - 13 | 2 markers missing at start
  //256, 257, 258, 259, 260, 261, 262  // jeanine       14 - 20
}; 

int currentID = videoIDs[idx];


boolean setupFinished = false;

void setup ()
{
  size( 1400, 800 );

  api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe",  BASE_URL);
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
  else if (setupFinished)
  {
    background( 255 );
    
    float segHeight = 20;
    float x = 0;
    float y = 0;
    float sw = width/5;
    float sh = textSegments.length() * segHeight;
    
    for (int i=0; i<textSegments.length(); i++) {
        
        TextSegment tSeg  = textSegments.get(i);
        
        //float segHeight = (height-100)/float(textSegments.length()-1);
        
        y = i * segHeight + 120;
        x = sw*2;
        
        pushStyle();
        
        noStroke();
        
        if (i%2 == 1) {
          fill(240);
          rect(50,y, width, segHeight);
        }
        
        // marker
        fill(0);
        textAlign(LEFT);
        text(tSeg.marker, 50, y+13);
        
        float h = segHeight - 2;
        
        // text seg
        x = sw;
        fill(255,0,0);
        float w = 700*tSeg.relLength();
        //float h = floor(segHeight/3) - 1;
        rect(x, y+1, w, (h/3)-1);
        textAlign(RIGHT);
        //text(tSeg.relLength(), 100, y);
        
      if ( i >= skipStartMarker ) {
        VideoSegment vSeg = videoSegments.get(i - skipStartMarker);
        
        // video seg
        //y += h + 1;
        x = sw;
        fill(0,0,255);
        w = 700*vSeg.relLength();
        rect(x, y+1 + (h/3), w, (h/3)-1);
        textAlign(RIGHT);
        //text(vSeg.relLength(), x - 10, y);
        
        // traveled total
        x = sw;
        w = 700*vSeg.traveled - vSeg.relLength();
        fill(0,255,0);
        rect(x, y+1 + (h/3*2), w, (h/3)-1);
        
        // traveled vid diff
        x = sw*3;
        w = 700*( vSeg.traveled - vSeg.relLength() );
        if (w>0) fill(0,255,0);
        else fill(0,0,255);
        rect(x,y+1, w,h);
        
        // traveled text diff
        x = sw*4;
        w = 700*( vSeg.traveled - tSeg.relLength() );
        if (w>0) fill(0,255,0);
        else fill(255,0,0);
        rect(x,y+1, w,h);
        
        // difference
        w = 700*(vSeg.relLength()-tSeg.relLength());
        x = sw*2;
        if (w>0) fill(0,0,255);
        else fill(255,0,0);
        rect(x,y+1, w,h);
        
      } 
      else {
        // difference pseudo
        w = -700*tSeg.relLength();
        x = sw*2;
        fill(255,0,0);
        rect(x,y+1, w,h);
      }
      
      // movement
      /*
      for (int i=0; i<textSegments.length(); i++) {
        
      }
      */
      
      //stroke(200);
      //line(50,y, width, y);
      
      popStyle();
    }
    
    stroke(0);
    strokeWeight(3);
    line(50,117,width,117);
    
    
    
    pushMatrix();
    translate(sw,90);
    textAlign( LEFT );
    fill(255,0,0);
    text( "text", 0, 0);
    fill(0,0,255);
    text( "video", 0, 12);
    fill(0,255,0);
    text( "distance", 0, 24);
    popMatrix();
    
    textAlign( LEFT );
    fill(0);
    text( "MARKER", 50, 90);
    textAlign(CENTER);
    text( "TEXT - VIDEO", sw*2, 90);
    text( "VIDEO - DISTANCE", sw*3, 90);
    text( "TEXT - DISTANCE", sw*4, 90);
    
    /*
    y = segHeight * textSegments.length() + 150;
    x = sw*2;
    fill(100);
    textAlign( LEFT );
    text("Relation of the individual \ntext and video segments \nto the total length of the \nvideo and text respectively", x,y);
    x = sw*3;
    text("Defference between the \nlength of the matching \ntext and video segments", x,y);
    */
    
    pushStyle();
    textAlign( LEFT );
    fill(0);
    textSize(30);
    text(video.title, 48, 40 );
    popStyle();
    
    setupFinished = false;
    
    // cycles through all videos in videoIDs
    if (saveAllFrames) {
      saveFrame(video.title + "_#####_2.png");
      loading = true;
      idx++;
      if (idx == videoIDs.length) exit();
      else {
        currentID = videoIDs[idx];
        loadVideo(currentID);
      }
    }    
    
    //else api.loadPieces( api.createCallback( "piecesLoaded" ) );
    
    
    /*
    textAlign( LEFT );

    text( "Loaded piece \""+piece.title+"\" \nwith "+videos.length+" videos \nand "+events.length+" events.", 10, 20 );
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
  
  videoSegments = new VideoSegmentList( events );
  
  /*
    for (TextSegment el : textSegments) {
   println(el.marker);
   }
   */
  traveledTotal = 0;
  float total = 0;
  
  println( "----> " + textSegments.length() + " " + videoSegments.length() );
      
  //if ( textSegments.length() == videoSegments.length() ) {
    println("events loaded");
    setupFinished = true;
    
    /*
    for (int i=0; i<textSegments.length(); i++) {
      TextSegment tSeg = textSegments.get(i);
      VideoSegment vSeg = videoSegments.get(i);
      //println(tSeg.text);
      //println(tSeg.marker);
      //println("t\tv");
      //println( tSeg.relLength() + "\t" + vSeg.relLength() + "\n");
      
      total += vSeg.relLength();
      
    }
    */
    //println("total v " + total);
    
  //}   
}



void drawLoading ()
{
  background( 255 );

  fill( 0 );
  textAlign( CENTER );
  text( loadingMessage, width/2, height/2 );
}



