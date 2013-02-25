/** 
 *    Motion Bank research, http://motionbank.org/
 */
 
 import de.bezier.guido.*;
 import de.bezier.data.sql.*;
 
 Skeleton skeleton;
 PImage mugshot;
 PImage[] results;
 SQLite db;
 
 void setup ()
 {
     size( 1200, 800 );
     
     Interactive.make( this );
     
     initDatabase();
     
     Button b = new Button( 5, height-25, 50, 20 );
     Interactive.on( b, "buttonPressed", this, "buttonPressed" );
     
     skeleton = new Skeleton( 200, 300 );
 }
 
 void draw ()
 {
     background( 255 );
     //if ( mugshot != null ) image( mugshot, 0, 0 );
     
     skeleton.drawSkeleton( this.g );
     
     if ( results != null )
     {
         int ix = 400, iy = 0, s = 200;
         
         for ( PImage img : results )
         {
             image( img, ix, iy, s, s );
             
             ix += s;
             if ( ix > width ) 
             {
                 ix = 400;
                 iy += s;
             }
         }
     }
 }
