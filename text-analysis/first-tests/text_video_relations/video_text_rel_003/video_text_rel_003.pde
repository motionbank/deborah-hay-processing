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

XML srcXML;
String nttf;
TextSegmentList textSegments = new TextSegmentList();
int nttfLength;

PieceMakerApi api;
Piece piece;
Video video;
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
  232, 233, 234, 236, 235, 247, 248, // ros           0 -  6
  //249, 250, 251, 252, 253, 255, 254, // juliette      7 - 13 | two markers missing at start
  256, 257, 258, 259, 260, 261, 262  // janine       14 - 20
}; 

int currentID = videoIDs[idx];


boolean setupFinished = false;

void setup ()
{
  size( 1000, 800 );

  api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
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
    
    for (int i=0; i<textSegments.length(); i++) {
        
        TextSegment tSeg  = textSegments.get(i);
        
        float segHeight = (height-100)/float(textSegments.length()-1);
        
        float y = i * segHeight + 80;
        float x = 300;
        
        pushStyle();
        
        noStroke();
        
        // marker
        fill(0);
        textAlign(LEFT);
        text(tSeg.marker, x - 250, y);
        
        // text seg
        fill(255,0,0);
        float w = 700*tSeg.relLength();
        float h = floor(segHeight/3) - 1;
        rect(x, y-h, w, h);
        textAlign(RIGHT);
        text(tSeg.relLength(), x - 10, y);
        
      if ( i >= skipStartMarker ) {
        VideoSegment vSeg = videoSegments.get(i - skipStartMarker);
        
        // video seg
        y += h + 1;
        fill(0,0,255);
        w = 700*vSeg.relLength();
        rect(x, y-h, w, h);
        textAlign(RIGHT);
        text(vSeg.relLength(), x - 10, y);
      }
      
      stroke(200);
      line(x-250,y+segHeight/6, width, y+segHeight/6);
      
      popStyle();
    }
    textAlign( RIGHT );
    
    fill(255,0,0);
    text( "text", width-50, 30);
    
    fill(0,0,255);
    text( "video", width-50, 41);
    
    pushStyle();
    textAlign( LEFT );
    fill(0);
    textSize(30);
    text(video.title, 50, 40 );
    popStyle();
    
    setupFinished = false;
    
    // cycles through all videos in videoIDs
    if (saveAllFrames) {
      saveFrame(video.title + "_#####.png");
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



