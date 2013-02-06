/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Looking for body parts in the text.
 *
 *    Note uses 2010 version of NTTF
 *
 *    P-2.0b6
 *    created: fjenett - 2011-01
 *    updated: mbaer   - 20121204
 */

// using Wordle spinoff by Jonathan Feinberg:
// https://github.com/jdf/cue.language
import cue.lang.*;
import java.util.Map.Entry;

import java.util.*;
import java.io.*;

XML srcXML;
String nttf;
String[] bodyParts;
BodyPartList bodyPartList;

NodeElement[] nodeList;
BodyPartCount[] partList;

float graphHeight = 400;
int nttfLength;

void setup ()
{
    size( 1400, 600 );
    smooth();
    noLoop();
    
    bodyParts = porterStemWordList(loadStrings("body-parts-ext.txt"));
    //bodyParts = loadStrings("body-parts-ext.txt");
    //println("body parts stem: ");
    bodyPartList = new BodyPartList(bodyParts);
  
    srcXML = null;
    try {
        srcXML = new XML( this, "NTTF_nodes_2.xml" );
        //println(srcXML);
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }

    int numChildren = srcXML.getChildren( "node" ).length;

    nodeList = new NodeElement[numChildren];
    int i=0;
    
    nttf = "";

    for ( XML child : srcXML.getChildren( "node" ) )
    {
        println( child.getChild("marker").getContent() );
        String m = child.getChild("marker").getContent();
        String t = child.getChild("text").getContent();
        
        t = join(porterStemWordList( split(t, " ") ), " ");
        
        int startIndex = 0;
        if (i>0) startIndex = nodeList[i-1].endIndex + 1;

        nodeList[i] = new NodeElement(m, t, startIndex);

        if (t != "") nttf += t + " ";
        i++;
    }
    nttf = nttf.toLowerCase();
    
    nttfLength = nttf.length();
    nttfLength = split(nttf, " ").length;

    //println("\n" + nttf);

    //nttf = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();

    //println("\n" + nttf);

    //srcXML = join( loadStrings( "NTTF_sequenced.txt" ), "\n" ).toLowerCase();

    // count instances of body parts ..

    Counter<String> words = new Counter<String>();

    for ( String w : new WordIterator(nttf) )
    {
        words.note(w);
    }

    partList = countBodyParts( nttf );

    //Arrays.sort( partList );

    println("\nnode > body part > count\n");

    for (NodeElement n : nodeList) {
        println(n.marker);
        println("parts\t" + n.numBodyParts);
        println("rel\t" + n.numBodyPartsRel);

        for (BodyPartCount b : n.partList) {
            println("- " + b.part + "\t" + b.count);
        }
        println("\n");
    }


    textFont( createFont( "", 10 ) );
}

void draw ()
{
    background( 255 );


    int offset = 0;
    textAlign( LEFT );

    for (int i=0; i<nodeList.length; i++) {

        int pos0 = 0;
        if (i>0) pos0 = split(nodeList[i-1].text, " ").length;
        NodeElement node = nodeList[i];

        float x = map( offset + pos0, 0, nttfLength, 50, width-80 );
        //float w = map(
        float y = height-graphHeight;

        noStroke();
        fill(255, 0, 0);
        rect(x, y, 1, height);

        pushMatrix();
        translate(x, y);
        rotate(-HALF_PI/2);
        fill(0, 0, 255);
        text( node.numBodyParts, 3, -2 );
        fill(255, 0, 0);
        text( node.marker, 13, -2 );
        popMatrix();

        offset += pos0;
    }


    pushMatrix();

    fill( 0 );
    textAlign( RIGHT );

    float ys = graphHeight/partList.length;
    float y = graphHeight/partList.length/2;
    for ( BodyPartCount part : partList )
    {
        noStroke();
        text( part.part, 40, height-y+3 );

        stroke( 200 );
        line( 50, height-y, width-80, height-y );

        noStroke();
        for ( int pos : part.positions )
        {
            float x = map( pos, 0, nttfLength, 50, width-80 );
            ellipse( x, height-y, 4, 4 );
        }

        y += ys;
    }

    popMatrix();

    noLoop();
}

