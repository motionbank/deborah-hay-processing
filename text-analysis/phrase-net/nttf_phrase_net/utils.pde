
 void drawLabel ( String label, float x, float y, color labelColor )
 {
     stroke( 0 );
     
     pushMatrix();
        translate( x, y+4 );
        
        float txtWidth = textWidth( label );
        fill( labelColor );
        strokeWeight( 1 );
        beginShape();
        vertex( -txtWidth/2, -12 );
        vertex(  txtWidth/2, -12 );
        bezierVertex( txtWidth/2 + 10, -12, txtWidth/2 + 10,  5, txtWidth/2,  5 );
        vertex( -txtWidth/2,  5 );
        bezierVertex( -txtWidth/2 - 10,  5, -txtWidth/2 - 10, -12, -txtWidth/2,  -12  );
        endShape(CLOSE);
        
        fill( 0 );
        textAlign( CENTER );
        text( label, 0,0 );
    popMatrix();
 }
 
 String cleanString ( String in )
 {
     in = in.toLowerCase();
     in = in.trim();
     
     // strips "the " from "the edge" ..
     if ( in.indexOf(" ") != -1 )
     {
         in = in.substring( in.lastIndexOf(" ")+1 );
     }
     
     return in;
 }
