/**
 *    Motion Bank
 *    Looking at the "ground truth" added via PieceMaker.
 *
 *    florian@motionbank.org - 2012-02
 */
 
 import de.bezier.data.sql.*;
 import de.bezier.utils.*;
 import org.yaml.snakeyaml.*; // http://code.google.com/p/snakeyaml/wiki/Documentation
 import java.lang.reflect.*;
 import java.util.concurrent.TimeUnit;
 import org.piecemaker.models.*;
 
 MySQL db;
 Style style;
 
 ArrayList<Video> videos;
 HashMap<Integer,Piece> pieces;
 HashMap<Integer,Event> events;
 
 Piece selectedPiece;
 int activeEventNum = 0;
 
 void setup ()
 {
     size( screenWidth, 600 );
     if ( frame != null ) frame.setResizable(true);
     
     initDatabase();
     initData();
     
     textFont( createFont( "Verdana", 8 ) );
 }
 
 void draw ()
 {
     background( 0 );
     
     strokeWeight( 3 );
     stroke( 30 );
     line( width/2, 0, width/2, height );
     
     ArrayList<Event> evs = getVideo(0).getEvents();
     Event ev = evs.get(activeEventNum);
     String activeEvent = ev.title;
     
     int hv = height / videos.size();
     int iv = 0;
     for ( Video video : videos )
     {
         //Video video = (Video)e.getValue();
         if ( video.getEvents() == null || video.getEvents().size() == 0 ) continue;
         
         //println( video );
         fill( 60 );
         textSize( 24 );
         text( video.title, 10, hv*iv + 30 );
         textSize( 8 );
         strokeWeight( 1 );
         stroke( 70 );
         line( 0, hv*iv, width, hv*iv );
         
         Event first = null, last = null, alignBy = null;
         for ( Event event : video.getEvents() )
         {
             if ( event.title.equals( "fred + ginger" ) ) first = event;
             if ( alignBy == null && event.title.equals( activeEvent ) ) alignBy = event;
             last = event;
         }
         if ( first == null || alignBy == null || first == last ) continue;
         
         float tx = 0, txl = 0, ty = 0, tl = 0;
         float tdist = 1.0 * (last.getHappenedAt().getTime() - first.getHappenedAt().getTime());
         
         float txAlign = 10 + ((alignBy.getHappenedAt().getTime() - first.getHappenedAt().getTime()) / tdist) * (width-50);

         for ( Event event : video.getEvents() )
         {
             if ( event.getHappenedAt().getTime() < first.getHappenedAt().getTime() ) continue;
             
             //println( event );
         
             txl = tx;
             tx = 10 + ((event.getHappenedAt().getTime() - first.getHappenedAt().getTime()) / tdist) * (width-50) + (width/2 - txAlign);
            
             strokeWeight( 1 );
             stroke( 110 );
             line( tx+1, hv*iv, tx+1, hv*(iv+1) );
             
             fill( 255 );
             
             if ( tx - txl < tl  )
                 ty += 10;
             else
                 ty = 0;
             tl = textWidth(event.title);
             if ( (8+ty+hv*iv) > hv*(iv+1) ) ty = 0;
             
             text( event.title, tx+5, 8+ty+hv*iv );
             
             fill( 255 );
             noStroke();
             rect( tx+1, ty+hv*iv, 2, 9 );
         }
         
         iv++;
     }
 }
 
 void drawSelectPiece ()
 {
     float h = float(height-20) / pieces.size();
     
     int i = 0;
     for ( Map.Entry entry : pieces.entrySet() ) {
         boolean over = mouseInside( 10, 10 + i*h, width-20, h );
         
         if ( over )
             style.load( "interface-selected" );
         else
             style.load( "interface" );
             
         rect( 10, 10 + i*h, width-20, h );
         
         if ( over )
             style.load( "interface-selected-text" );
         else
             style.load( "interface-text" );
         
         Piece p = (Piece)entry.getValue();
         
         textAlign( CENTER );
         text( p.getTitle(), width/2, i*h + 0.5*h + 8 );
         
         if ( over && mousePressed )
             selectedPiece = p;
         
         i++;
     }
 }
 
 void drawPieceTimeline ()
 {
     style.load( "interface-text" );
     text( selectedPiece.getTitle(), 10, 22 );
 }
 
 boolean mouseInside ( float x, float y, float w, float h )
 {
     return mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h;
 }
 
 void keyPressed ()
 {
     if ( key == CODED ) {
         switch ( keyCode )
         {
             case UP:
                 activeEventNum++;
                 activeEventNum %= getVideo(0).getEvents().size();
                 break;
             case DOWN:
                 activeEventNum--;
                 if ( activeEventNum < 0 ) activeEventNum = getVideo(0).getEvents().size() - 1;
                 break;  
         }
     }
 }
 
 Video getVideo ( int num )
 {
     //Video[] vids = videos.values().toArray(new Video[0]);
     //return vids[num];
     return videos.get( num );
 }
