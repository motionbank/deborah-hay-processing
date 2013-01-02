/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Piecemaker API test: connection to PM and loading some ..
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
VideoSegmentList videoSegments = new VideoSegmentList();

int idx = 0;

boolean loading = true;
String loadingMessage = "Loading pieces ...";


int[] videoIDs = {
  232, 233, 234, 236, 235, 247, 248, // ros           0 -  6
  249, 250, 251, 252, 253, 255, 254, // juliette      7 - 13
  256, 257, 258, 259, 260, 261, 262  // janine       14 - 20
}; 

int currentID = videoIDs[20];


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
      VideoSegment vSeg = videoSegments.get(i);
      
      float segHeight = (height-40)/float(textSegments.length()-1);
      
      float y = i * segHeight + 20;
      float x = 300;
      
      pushStyle();
      
      noStroke();
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
      
      // video seg
      y += h + 1;
      fill(0,0,255);
      w = 700*vSeg.relLength();
      rect(x, y-h, w, h);
      textAlign(RIGHT);
      text(vSeg.relLength(), x - 10, y);
      
      stroke(200);
      line(x-250,y+segHeight/6, width, y+segHeight/6);
      
      popStyle();
    }
    textAlign( LEFT );
    
    fill(255,0,0);
    text( "text", width-50, 20);
    
    fill(0,0,255);
    text( "video", width-50, 31);
    
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

  // EVENTS
  
  for (int i=0; i<events.length; i++) {
    org.piecemaker.models.Event evt = events[i];

    if (evt.getEventType().equals("scene")) {
      
      long vidHappened = video.getHappenedAt().getTime();
      float vidDuration = video.getDuration()*1000;
      //float vidDuration = events[events.length-1].getHappenedAt().getTime() - vidHappened;
      
      
      // current event
      //float eventLoc0 = map( evt.getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
      float eventLoc0 = (evt.getHappenedAt().getTime() - vidHappened) / vidDuration;

      // next event
      float eventLoc1 = 0;
      //if (i<events.length-1) eventLoc1 = map( events[i+1].getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
      if (i<events.length-1) eventLoc1 = (events[i+1].getHappenedAt().getTime() - vidHappened) / vidDuration;
      else eventLoc1 = 1;

      float eventDur = (eventLoc1 - eventLoc0);
      
      /*
      println(evt.title);
      
      println("eha: " + evt.getHappenedAt().getTime());
      println("vha: " + vidHappened);
      println("dif: " + (evt.getHappenedAt().getTime() - vidHappened));
      println("vdu: " + vidDuration);
      println("edu: " + eventDur);
      println("loc0: " + eventLoc0);
      println("loc1: " + eventLoc1 + "\n");
      */
       
      videoSegments.add( new VideoSegment( evt, eventDur ) );
    }
  }
  
  /*
    for (TextSegment el : textSegments) {
   println(el.marker);
   }
   */
   
  float total = 0;
      
  if ( textSegments.length() == videoSegments.length() ) {
    
    setupFinished = true;
    
    
    for (int i=0; i<textSegments.length(); i++) {
      TextSegment tSeg = textSegments.get(i);
      VideoSegment vSeg = videoSegments.get(i);
      //println(tSeg.text);
      println(tSeg.marker);
      println("t\tv");
      println( tSeg.relLength() + "\t" + vSeg.relLength() + "\n");
      
      total += vSeg.relLength();
      
    }
    println("total v " + total);
    
  }   
}



void drawLoading ()
{
  background( 255 );

  fill( 0 );
  textAlign( CENTER );
  text( loadingMessage, width/2, height/2 );
}



