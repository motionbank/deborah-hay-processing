/**   
 *    Looking at the "ground truth" data (scenes) for No Time To Fly by Deborah Hay
 *
 *    fjenett 2012-03
 */
 
 import de.bezier.utils.*;
 import de.bezier.data.sql.*;
 //import org.yaml.snakeyaml.*; // http://code.google.com/p/snakeyaml/wiki/Documentation
 import org.piecemaker.models.*;
 import processing.pdf.*;
 
 import java.util.*;

 MySQL db;
 ArrayList<Piece> pieces;
 ArrayList<org.piecemaker.models.Event> events;
 ArrayList<EventGroup> groups;
 
 String sketchId;
 
 int eventsPerGroup = -1;

 void setup ()
 {
     size( displayWidth-40, 2*displayHeight/3 );
     sketchId = Utils.makeDateTimeName(this);
     
     initDatabase();
     loadData();
     
     beginRecord(PDF, sketchId+".pdf");
     textFont( createFont( "Lato-Bold", 20 ) );
 }
 
 void draw ()
 {
     background( 255 );
     
     fill( 240 ); stroke( 0 ); strokeWeight( 1 );
     rect( 20,20,width-40,height-40 );
     
     long maxGroupDuration = Long.MIN_VALUE;
     long maxEventDuration = Long.MIN_VALUE;
     
     long[][] valuePack = new long[eventsPerGroup-1][0];
     for ( int i = 0; i < eventsPerGroup-1; i++ )
     {
         valuePack[i] = new long[] {
            Long.MAX_VALUE,
            Long.MIN_VALUE,
            -1,
            -1
         };
         
         long[] vs = new long[groups.size()];
         for ( int k = 0, n = groups.size(); k < n; k++ )
         {
             EventGroup g = groups.get(k);
             org.piecemaker.models.Event e = g.events.get(i);
             org.piecemaker.models.Event en = g.events.get(i+1);
             long v = en.getHappenedAt().getTime()-e.getHappenedAt().getTime();
             valuePack[i][0] = Math.min( valuePack[i][0], v );
             valuePack[i][1] = Math.max( valuePack[i][1], v );
             valuePack[i][2] += v;
             vs[k] = v;
         }
         valuePack[i][2] /= groups.size();
         Arrays.sort(vs);
         valuePack[i][3] = vs[vs.length/2];
     }
 
     for ( EventGroup g : groups ) 
     {
         maxGroupDuration = Math.max( maxGroupDuration, g.duration );
         
         org.piecemaker.models.Event p = null;
         for ( org.piecemaker.models.Event e : g.events )
         {
             if ( p != null )
             {
                 maxEventDuration = Math.max( maxEventDuration, e.getHappenedAt().getTime() - p.getHappenedAt().getTime() );
             }
             p = e;
         }
     }
     
     
     stroke( 0 );
     
     float we = (width-40.0) / (eventsPerGroup-1);
     float weg = we / groups.size();
     for ( int i = 0; i < eventsPerGroup-1; i++ )
     {
         strokeWeight( 1 );
         line( 20.0+i*we, 20, 20.0+i*we, height-20 );
         
         for ( int k = 0, n = groups.size(); k < n; k++ )
         {
             //colorMode( HSB );
             //fill( map(k,0,n,0,255), 200, 200 );
             
             EventGroup g = groups.get(k);
             org.piecemaker.models.Event e = g.events.get(i);
             org.piecemaker.models.Event en = g.events.get(i+1);
             long duration = en.getHappenedAt().getTime() - e.getHappenedAt().getTime();
             float val = map( duration, 0, maxEventDuration, 0, height-40 );
             //rect( 20.0 + i*we + k*weg, height-20-val, weg, val );
             
//             if ( k == 0 ) {
//             pushMatrix();
//             translate( 20.0 + i*we, 20 );
//             rotate( radians( 90 ) );
//             fill( 0 );
//             text( e.title, 0, 0 );
//             popMatrix();
//             }
         }
         
         float v1 = map( valuePack[i][0], 0, maxEventDuration, 0, height-40 );
         float v2 = map( valuePack[i][1], 0, maxEventDuration, 0, height-40 );
         float vm1 = map( valuePack[i][2], 0, maxEventDuration, 0, height-40 );
         float vm2 = map( valuePack[i][3], 0, maxEventDuration, 0, height-40 );
         
         fill( 200 );
         rect( 20.0 + i*we, height-20-v2, we, v2 );
         fill( 170 );
         rect( 20.0 + i*we, height-20-v2, we, v2-v1 );
         
         strokeWeight( 2 );
         line( 20.0 + i*we, height-20-v1, 20.0 + (i+1)*we, height-20-v1 );
         line( 20.0 + i*we, height-20-v2, 20.0 + (i+1)*we, height-20-v2 );
         stroke( 200, 0, 0 );
         line( 20.0 + (i+0.25)*we, height-20-vm1, 20.0 + (i+0.75)*we, height-20-vm1 );
         stroke( 100 );
         strokeWeight( 1 );
         line( 20.0 + (i+0.25)*we, height-20-vm2, 20.0 + (i+0.75)*we, height-20-vm2 );
         stroke( 0 );
         strokeWeight( 2 );
         line( 20.0 + (i+0.5)*we, height-20-v1, 20.0 + (i+0.5)*we, height-20-v2 );
     }
     
     noLoop();
     //endRecord();
 }
