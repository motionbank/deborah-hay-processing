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
XML nttf;
String[] texts;
String oneline;
 
 void setup ()
 {
     size( 1000, 400 );
     smooth();
     noLoop();
     
     String[] bodyParts = loadStrings("body-parts.txt");
     
     nttf = null;
     try {
         nttf = new XML( this, "NTTF_nodes.xml" );
         //println(nttf);
     } catch ( Exception e ) {
         e.printStackTrace();
     }
     
     texts = new String[nttf.getChildren( "node" ).length];
     println(texts.length);
     int i=0;
     
     for ( XML child : nttf.getChildren( "node" ) )
     {
         println( child.getChild("marker").getContent() );
         String t = child.getChild("text").getContent();
         texts[i] = t;
         if (t != "") oneline += t + " ";
         i++;
     }
     
     println(oneline);
     
     //oneline = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();
     
     //println("\n" + oneline);
     
     //nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();
  
     // count instances of body parts ..
     
     Counter<String> words = new Counter<String>();
    
    for ( String w : new WordIterator(oneline) )
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
            while ( (idx = oneline.indexOf( part, idx+1 )) != -1 )
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
   
   for (int i=0; i<texts.length; i++) {
     
     int pos0 = 0;
     if (i>0) pos0 = texts[i-1].length();
     int pos1 = texts[i].length();
     
     float x = floor(map( offset + pos1, 0, oneline.length(), 50, width-6 ));
     //float w = map(
     float y = 0;
     
     noStroke();
     fill(255,0,0);
     rect(x,y, 1,height);
     
     offset += pos0;
   }
   
   
   
   for(int i=0; i<partList.length; i++) {
     BodyPartCount b = partList[i];
   }
   
   
       
    fill( 0 );
    textAlign( RIGHT );
    
    float ys = height/partList.length;
    float y = 18;
    for ( BodyPartCount part : partList )
    {
        noStroke();
        text( part.part, 40, height-y+3 );
        
        stroke( 200 );
        line( 44, height-y, width-6, height-y );
        
        noStroke();
        for ( int pos : part.positions )
        {
            float x = map( pos, 0, oneline.length(), 50, width-6 );
            ellipse( x, height-y, 4, 4 );
        }
        
        y += ys;
    }
    
    noLoop();
    
 }
