/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Sort by radial hash values and then play in that order
 *
 *    P2.0
 *    created: fjenett 20130222
 */
 
 import de.bezier.data.sql.*;
 import org.motionbank.imaging.*;

 ArrayList<String> performances;
 ArrayList<Integer> performancesLengths;
 
 SQLite db;
 String dbName = "db_Test.sqlite";
 String silhouettesBase = "/Volumes/Verytim/2011_FIGD_April_Results";
 
 void setup ()
 {
     size( 300, 300 );
     
     initDb();
     
     String vals = "";
     
     for ( int i = 0; i < 128; i++ )
     {
         if ( i > 0 )
             vals += ", ";
         vals += "v" + nf(i,3);
     }
     
     db.query(
         "SELECT id, file, substr( file, 0, 11 ) AS perf FROM images ORDER BY %s",
         vals
     );
     
     frameRate( 999 );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( db.next() )
     {
         String f = db.getString( "file" );
         PImage img = loadImage( silhouettesBase + "/" + f );
         removeTurquoise( img );
         //image( img, 0, 0, img.width * (height/img.height), height );
         int[] binPixels = toBinaryPixels( img.pixels );
         
         ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( binPixels, img.width, img.height );
         
         //ImageUtilities.PixelBoundingBox bbox = ImageUtilities.getBoundingBox( binPixels, img.width, img.height );
         //int bbCenterX = bbox.xCenter, bbCenterY = bbox.yCenter;
         //int bbWidth = bbox.width, bbHeight = bbox.height;
         
         ImageUtilities.PixelBoundingCircle bbCircle = ImageUtilities.getBoundingCircle( binPixels, img.width, img.height, com.x, com.y );
         int bbCenterX = bbCircle.x, bbCenterY = bbCircle.y;
         int bbWidth = bbCircle.radius * 2, bbHeight = bbCircle.radius*2;
         
         int imgWidth  = bbWidth  + abs( bbCenterX - com.x );
         int imgHeight = bbHeight + abs( bbCenterY - com.y );
         int padding = 50;
         float imgSize = width-(2*padding);
         float imgScale = imgSize / ( imgWidth > imgHeight ? imgWidth : imgHeight );
         
         image( img, padding + -com.x * imgScale + imgSize/2, 
                     padding + -com.y * imgScale + imgSize/2, 
                     img.width * imgScale, 
                     img.height * imgScale );
         //image( img, width/2-com.x, height/2-com.y );
         
         removeCache( img );
     }
     else
         exit();
         
     saveFrame( "output/" + nf(frameCount, 15) + ".png" );
 }
 
 int[] toBinaryPixels ( int[] pixels )
 {
     int[] tmp = new int[pixels.length];
     for ( int i = 0; i < pixels.length; i++ )
     {
         tmp[i] = (((pixels[i] >> 16) & 0xFF) + ((pixels[i] >> 8) & 0xFF) + (pixels[i]& 0xFF)) / 3;
         tmp[i] = tmp[i] > 255 / 2 ? 255 : 0;
     }
     return tmp;
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
