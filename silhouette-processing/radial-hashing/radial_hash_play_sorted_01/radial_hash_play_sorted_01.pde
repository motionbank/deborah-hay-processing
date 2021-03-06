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
 
 MySQL db;
 String dbDatabase = "moba_silhouettes";
 String dbTableName = "silhouettes";
 String silhouettesBase = "/Volumes/Verytim/2011_FIGD_April_Results";
 
 void setup ()
 {
     size( 300, 300 );
     
     initDb();
     
     long ts = System.currentTimeMillis();
     db.query(
         "SELECT id, file, performance "+
         "FROM %s "+
         "ORDER BY CONCAT( LPAD(HEX(hash64),16,'F'), LPAD(HEX(hash128),16,'F'), LPAD(HEX(hash192),16,'F'), LPAD(HEX(hash256),16,'F') ), "+
         "framenumber "+
         "LIMIT 10000",
         dbTableName
     );
     println( (System.currentTimeMillis() - ts) / 1000.0 );
     
     // Ros only (780000 entries) took 5508 secs to complete ... that's 1.5 hours!
     
     frameRate( 10 );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( db.next() )
     {
         //if ( new File(sketchPath("output2/" + nf(frameCount, 15) + ".png")).exists() ) return;
         
         String f = db.getString( "file" );
         String folder = f.split("_")[0];
         if ( folder.equals("Janine") ) folder = "Jeanine";
         f = folder + "/" + f;
         PImage img = loadImage( silhouettesBase + "/" + f );
         if ( img == null ) return;
         if ( img.width < 50 || img.height < 50 ) return;
         removeTurquoise( img );
         //image( img, 0, 0, img.width * (height/img.height), height );
         int[] binPixels = toBinaryPixels( img.pixels );
         
         ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( binPixels, img.width, img.height );
         
         //ImageUtilities.PixelBoundingBox bbox = ImageUtilities.getBoundingBox( binPixels, img.width, img.height );
         //int bbCenterX = bbox.xCenter, bbCenterY = bbox.yCenter;
         //int bbWidth = bbox.width, bbHeight = bbox.height;
         
         ImageUtilities.PixelCircumCircle bbCircle = ImageUtilities.getCircumCircle( binPixels, img.width, img.height, com.x, com.y );
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
     
     //saveFrame( "output2/" + nf(frameCount, 15) + ".png" );
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
