/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Sort by radial hash values and then play in that order
 *
 *    P2.0
 *    created: fjenett 20130222
 */
 
 import de.bezier.data.sql.*;

 ArrayList<String> performances;
 ArrayList<Integer> performancesLengths;
 
 SQLite db;
 String dbName = "db_Ros_all.sqlite";
 String silhouettesBase = "/Volumes/Verytim/2011_FIGD_April_Results";
 
 void setup ()
 {
     size( 800, 800 );
     
     initDb();
     
     String vals = "";
     
     for ( int i = 0; i < 32; i++ )
     {
         if ( i > 0 )
             vals += ", ";
         vals += "v" + nf(i,3);
     }
     
     db.query(
         "SELECT id, file, substr( file, 0, 11 ) AS perf FROM images ORDER BY %s",
         "fasthash64"
     );
     
     frameRate( 25 );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( db.next() )
     {
         String f = db.getString( "file" );
         PImage img = loadImage( silhouettesBase + "/" + f );
         removeTurquoise( img );
         image( img, 0, 0, img.width * (height/img.height), height );
         removeCache( img );
     }
     else
         exit();
 }

 void removeTurquoise ( PImage img )
{
    for ( int i = 0, k = img.pixels.length; i < k; i++ )
    {
        if ( img.pixels[i] == 0xFF00FFFF )
        {
            img.pixels[i] = 0xFFFFFFFF;
        }
    }
}
