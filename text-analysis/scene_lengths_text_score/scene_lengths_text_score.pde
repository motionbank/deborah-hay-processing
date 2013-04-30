/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Processing 2.0
 *    created: fjenett - 2013-03
 */
 
 import processing.pdf.*;
 
 float[] nodeLengths;
 
 void setup ()
 {
     size( 300, 300 );
     
     XML xml = loadXML("NTTF_nodes.xml");
     XML[] nodes = xml.getChildren("node");
     
     int totalLength = 0;
     nodeLengths = new float[nodes.length];
     String[] nodeNames = new String[nodes.length];
     
     for ( int i = 0; i < nodes.length; i++ )
     {
         XML node = nodes[i];
         nodeNames[i] = node.getChild( "marker" ).getContent();
         String text = node.getChild( "text" ).getContent();
         nodeLengths[i] = text.trim().length();
         totalLength += nodeLengths[i];
     }
     
     for ( int i = 0; i < nodeLengths.length; i++ )
     {
         nodeLengths[i] /= totalLength;
         println( nodeLengths[i] );
     }
     
     saveStrings( "output/values.txt",  str(nodeLengths) );
     
     String json = "[\n";
     for ( int i = 0; i < nodeLengths.length; i++ )
     {
         json += "{ \"marker\" : \""+nodeNames[i]+"\" , \"length\" : \""+nodeLengths[i]+"\" },\n";
     }
     json += "]";
     
     saveStrings( "output/values.json",  json.split("\n") );
 }
 
 void draw ()
 {
     background( 255 );
     
     beginRecord( PDF, "output/timeline.pdf" );
     
     float left = 10;
     
     for ( int i = 0; i < nodeLengths.length; i++ )
     {
         fill( 150 + random( 105 ), 200, 200 );
         float w = nodeLengths[i] * (width-20-(nodeLengths.length-1)*2);
         rect( left, height/2 - 10, w, 20 );
         left += w + 2;
     }
     
     noLoop();
     
     endRecord();
 }
