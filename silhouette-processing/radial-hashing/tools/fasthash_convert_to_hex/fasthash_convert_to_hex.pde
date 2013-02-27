/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Converter for 32bit hashes to 64bitz hashes ..
 *
 *    P2.0
 *    fjenett 20130226
 */
 
 import de.bezier.data.sql.*;
 import org.motionbank.hashing.*;

 int total = 0;
 int current = 0;
 
 PApplet papplet;
 
 void setup ()
 {
     size( 200, 200 );
     
     papplet = this;
     
     new Thread ()
     {
         public void run () 
         {
             int[] ids = new int[0];
             
             SQLite db = new SQLite( papplet, sketchPath("../../db/db_Ros_ALL.sqlite") );
             if ( db.connect() )
             {   
                 db.query( "SELECT count(*) AS total FROM images" );
                 if ( db.next() )
                 {
                     total = db.getInt( "total" );
                 }
                 
                 ids = new int[total];
                 int n = 0;
                 
                 db.query( "SELECT id FROM images ORDER BY id" );
                 while ( db.next() )
                 {
                     ids[n] = db.getInt( "id" );
                     n++;
                 }
                 
                 int[] vals = new int[32];
                 int id = -1;
                 
                 for ( int ii : ids )
                 {
                     db.query( "SELECT * FROM images WHERE id = %d", ii );
                     if ( db.next() )
                     {
                         id = db.getInt( "id" );
                         for ( int i = 0; i < 32; i++ )
                         {
                             vals[i] = db.getInt( "v"+nf(i,3) );
                         }
                     }
                     else
                     {
                         continue;
                     }
                     
                     String fHashHex = new FastHash( vals ).toHexString();
                     
                     db.execute( "UPDATE images SET fasthash = \"%s\" WHERE id = %d", fHashHex, id );
                     
                     current++;
                 }
                 
                 exit();
             }
             else
             {
                 System.err.println( "Unable to connect to databases" );
             }
         }
     }.start();
 }
 
 void draw ()
 {
     background( 255 );
     
     noFill();
     stroke( 0 );
     ellipse( width/2, height/2, width/2, height/2 );
     
     fill( 0 );
     noStroke();
     arc( width/2, height/2, width/2, height/2, -HALF_PI, map( current, 0, total, 0, TWO_PI )-HALF_PI );
 }
