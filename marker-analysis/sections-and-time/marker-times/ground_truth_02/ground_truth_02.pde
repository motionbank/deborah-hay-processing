/**   
 *    Looking at the "ground truth" data (scenes) for No Time To Fly by Deborah Hay
 *
 *    fjenett 2012-03
 */
 
 import de.bezier.guido.*;
 import de.bezier.utils.*;
 import de.bezier.data.sql.*;
 import org.yaml.snakeyaml.*; // http://code.google.com/p/snakeyaml/wiki/Documentation
 import org.piecemaker.models.*;
 import processing.pdf.*;

 MySQL db;
 ArrayList<Piece> pieces;
 ArrayList<Event> events;
 ArrayList<EventGroup> groups;
 ArrayList<GraphBar> graph;
 
 String sketchId;
 
 int eventsPerGroup = -1;

 void setup ()
 {
     size( displayWidth-40, 2*displayHeight/3 );
     
     Interactive.make(this);
     sketchId = Utils.makeDateTimeName(this);
     
     initDatabase();
     loadData();
     
     beginRecord(PDF, sketchId+".pdf");
     textFont( createFont( "Lato-Bold", 20 ) );
 }
 
 void draw ()
 {
     background( 255 );
     
//     fill( 240 ); stroke( 0 ); strokeWeight( 1 );
//     rect( 20,20,width-40,height-40 );
     
     long maxGroupDuration = Long.MIN_VALUE;
     long maxEventDuration = Long.MIN_VALUE;
     
     graph = new ArrayList();
     float graphWidth = ((width-40.0)/(eventsPerGroup-1)) / 2;
     
     for ( int i = 0; i < eventsPerGroup-1; i++ )
     {   
         GraphBar bar = null;
         if ( graph.size() == i ) {
             bar = new GraphBar( 
                 20 + graphWidth/2 + i*2*graphWidth, 
                 20, graphWidth, 
                 height-40, 
                 i+" "+groups.get(0).events.get(i).title 
                 );
             graph.add( bar );
         } else {
             bar = graph.get( i );
         }
             
         long[] vs = new long[groups.size()];
         for ( int k = 0, n = groups.size(); k < n; k++ )
         {
             EventGroup g = groups.get(k);
             
             if ( i >= 0 && i < g.events.size()-1 )
             {
                 Event e = g.events.get(i);
                 Event en = g.events.get(i+1);
                 
                 long v = en.getHappenedAt().getTime()-e.getHappenedAt().getTime();
                 
                 bar.add( v );
             }
         }
     }
 
     for ( EventGroup g : groups ) 
     {
         maxGroupDuration = Math.max( maxGroupDuration, g.duration );
         
         Event p = null;
         for ( Event e : g.events )
         {
             if ( p != null )
             {
                 maxEventDuration = Math.max( maxEventDuration, e.getHappenedAt().getTime() - p.getHappenedAt().getTime() );
             }
             p = e;
         }
     }
     
     for ( GraphBar bar : graph )
     {
         bar.draw();
     }
     
//     stroke( 0 );
//     
//     float we = (width-40.0) / (eventsPerGroup-1);
//     float weg = we / groups.size();
//     for ( int i = 0; i < eventsPerGroup-1; i++ )
//     {
//         strokeWeight( 1 );
//         line( 20.0+i*we, 20, 20.0+i*we, height-20 );
//         
//         for ( int k = 0, n = groups.size(); k < n; k++ )
//         {
//             //colorMode( HSB );
//             //fill( map(k,0,n,0,255), 200, 200 );
//             
//             EventGroup g = groups.get(k);
//             Event e = g.events.get(i);
//             Event en = g.events.get(i+1);
//             long duration = en.getHappenedAt().getTime() - e.getHappenedAt().getTime();
//             float val = map( duration, 0, maxEventDuration, 0, height-40 );
//             //rect( 20.0 + i*we + k*weg, height-20-val, weg, val );
//             
////             if ( k == 0 ) {
////             pushMatrix();
////             translate( 20.0 + i*we, 20 );
////             rotate( radians( 90 ) );
////             fill( 0 );
////             text( e.title, 0, 0 );
////             popMatrix();
////             }
//         }
//         
////         float v1 = map( valuePack[i][0], 0, maxEventDuration, 0, height-40 );
////         float v2 = map( valuePack[i][1], 0, maxEventDuration, 0, height-40 );
////         float vm1 = map( valuePack[i][2], 0, maxEventDuration, 0, height-40 );
////         float vm2 = map( valuePack[i][3], 0, maxEventDuration, 0, height-40 );
////         
////         fill( 200 );
////         rect( 20.0 + i*we, height-20-v2, we, v2 );
////         fill( 170 );
////         rect( 20.0 + i*we, height-20-v2, we, v2-v1 );
////         
////         strokeWeight( 2 );
////         line( 20.0 + i*we, height-20-v1, 20.0 + (i+1)*we, height-20-v1 );
////         line( 20.0 + i*we, height-20-v2, 20.0 + (i+1)*we, height-20-v2 );
////         stroke( 200, 0, 0 );
////         line( 20.0 + (i+0.25)*we, height-20-vm1, 20.0 + (i+0.75)*we, height-20-vm1 );
////         stroke( 100 );
////         strokeWeight( 1 );
////         line( 20.0 + (i+0.25)*we, height-20-vm2, 20.0 + (i+0.75)*we, height-20-vm2 );
////         stroke( 0 );
////         strokeWeight( 2 );
////         line( 20.0 + (i+0.5)*we, height-20-v1, 20.0 + (i+0.5)*we, height-20-v2 );
//     }
     
     noLoop();
     endRecord();
 }
