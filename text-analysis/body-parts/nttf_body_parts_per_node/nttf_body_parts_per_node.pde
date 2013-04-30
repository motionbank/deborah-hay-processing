/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Looking for body parts in the text.
 *
 *    Note uses 2010 version of NTTF
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: fjenett 20121116
 */
 
 // using Wordle spinoff by Jonathan Feinberg:
// https://github.com/jdf/cue.language
import cue.lang.*;
import java.util.Map.Entry;

import java.util.*;

BodyPartCount[] partList;
XML srcXML;
String nttf;

NodeElement[] nodeList;

float graphHeight = 400;
 
 void setup ()
 {
     size( 1400, 600 );
     smooth();
     noLoop();
     
     String[] bodyParts = loadStrings("body-parts.txt");
     
     srcXML = null;
     try {
         srcXML = new XML( this, "NTTF_nodes_2.xml" );
         //println(srcXML);
     } catch ( Exception e ) {
         e.printStackTrace();
     }
     
     int numChildren = srcXML.getChildren( "node" ).length;
     
     nodeList = new NodeElement[numChildren];
     int i=0;
     
     for ( XML child : srcXML.getChildren( "node" ) )
     {
         println( child.getChild("marker").getContent() );
         String m = child.getChild("marker").getContent();
         String t = child.getChild("text").getContent();
         int startIndex = 0;
         if (i>0) startIndex = nodeList[i-1].endIndex + 1;
         
         nodeList[i] = new NodeElement(m,t,startIndex);
         
         if (t != "") nttf += t + " ";
         i++;
         
         
     }
     
     //println(nttf);
     
     //nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();
     
     //println("\n" + nttf);
     
     //srcXML = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();
  
     // count instances of body parts ..
     
     Counter<String> words = new Counter<String>();
    
    for ( String w : new WordIterator(nttf) )
    {
        words.note(w);
    }
    
    partList = new BodyPartCount[0];
    
    for ( String part : bodyParts )
    {
        int c = words.getCount( part );
        if ( c > 0 )
        {
            int idx = -1;
            int[] positions = new int[0];
            while ( (idx = nttf.indexOf( part, idx+1 )) != -1 )
            {
                positions = append( positions, idx );
            }
            partList = (BodyPartCount[])append( partList, new BodyPartCount(part, c, positions) );
        }
    }
    
    Arrays.sort( partList );
    
    
    textFont( createFont( "", 10 ) );
 }
 
 void draw ()
 {
   background( 255 );
   
   
   int offset = 0;
   textAlign( LEFT );
   
   for (int i=0; i<nodeList.length; i++) {
     
     int pos0 = 0;
     if (i>0) pos0 = nodeList[i-1].text.length();
     NodeElement node = nodeList[i];
     
     float x = floor(map( offset + pos0, 0, nttf.length(), 50, width-6 ));
     //float w = map(
     float y = height-graphHeight;
     
     noStroke();
     fill(255,0,0);
     rect(x,y, 1,height);
     
     pushMatrix();
     translate(x,y);
     rotate(-HALF_PI);
     text( node.marker, 10, 5 );
     popMatrix();
     
     offset += pos0;
   }
   
   
   pushMatrix();
       
    fill( 0 );
    textAlign( RIGHT );
    
    float ys = graphHeight/partList.length;
    float y = 18;
    for ( BodyPartCount part : partList )
    {
        noStroke();
        text( part.part, 40, height-y+3 );
        
        stroke( 200 );
        line( 50, height-y, width-6, height-y );
        
        noStroke();
        for ( int pos : part.positions )
        {
            float x = map( pos, 0, nttf.length(), 50, width-6 );
            ellipse( x, height-y, 4, 4 );
        }
        
        y += ys;
    }
    
    popMatrix();
    
    noLoop();
    
 }
