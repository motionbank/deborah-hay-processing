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

BodyPartCount[] partList;
String nttf;
 
 void setup ()
 {
     size( 600, 400 );
     smooth();
     
     String[] bodyParts = loadStrings("body-parts.txt");
     
     nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();
  
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
            float x = map( pos, 0, nttf.length(), 44, width-6 );
            ellipse( x, height-y, 4, 4 );
        }
        
        y += ys;
    }
    
    noLoop();
 }
