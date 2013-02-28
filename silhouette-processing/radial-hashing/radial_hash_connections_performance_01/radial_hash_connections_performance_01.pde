/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Per run, calculate average value of best connections to other performances
 *
 *    P2.0
 *    created: fjenett 20130222
 */
 
 import de.bezier.data.sql.*;
 import org.motionbank.hashing.*;

 ArrayList<String> performances;
 ArrayList<Integer> performancesLengths;
 float performanceTrackHeight = 0;
 
 ArrayList<Connection> connections;
 Connection origin;
 
 SQLite db;
 String dbName = "db_Ros_all.sqlite";
 String silhouettesBase = "/Volumes/Verytim/2011_FIGD_April_Results";
 
 int perfNum = 0;
 int frameNum = 0;
 
 void setup ()
 {
     size( 1000, 500 );
     
     initDb();
     getPerformances();
     performanceTrackHeight = height / performances.size();
     
     frameNum = performancesLengths.get(perfNum) / 2;
     updatePerformancePosition( perfNum, frameNum );
 }
 
 void draw ()
 {
     background( 255 );
     
     for ( int i = 0, k = performances.size(), n = height/k; i < k; i++ )
     {
         stroke( 200 );
         fill( 220 );
         rect( 0, i*n, width-1, n );
         
         stroke( 0 );
         line( 10, i*n+n/2, width-20, i*n+n/2 );
     }
     
     if ( origin != null )
     {
         stroke( 0 );
         drawConnection( origin );
         
         if ( connections != null && connections.size() > 0 )
         {
             for ( Connection c : connections )
             {
                 stroke( 150 );
                 drawConnection( c );
             }
         }
     }
     
     if ( frameNum < performancesLengths.get(perfNum) )
     {
         frameNum += performancesLengths.get(perfNum) / (width-20); // one screen px
         //frameNum += 50; // 1 sec == 50 frames
         //frameNum ++; // every frame
         updatePerformancePosition( perfNum, frameNum );
     }
     else
         exit();
 }
 
 void drawConnection ( Connection c )
 {
     line( c.x, c.y-10, c.x, c.y+10 );
     
     image( c.image,
            c.x+1, 
            c.y+1 - (performanceTrackHeight/2), 
            c.image.width*((performanceTrackHeight-2.0)/c.image.height), 
            performanceTrackHeight-2 );
     removeCache( c.image );
     
     fill( 0 );
     text( c.imageDistance, c.x+3, c.y );
 }
