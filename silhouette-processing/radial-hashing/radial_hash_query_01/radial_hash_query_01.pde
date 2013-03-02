/** 
 *    Motion Bank research, http://motionbank.org/
 */
 
 import de.bezier.guido.*;
 import de.bezier.data.sql.*;
 
 import org.motionbank.imaging.*;
 import org.motionbank.hashing.*;
 
 Skeleton skeleton;
 PImage mugshot;
 PImage[] results;
 
 SQLite db;
 String dbPath = "../db";
 String dbFile = "dbV4Test.sqlite";
 
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
             drawSilhouette( img, ix, iy, s, s );
             
             ix += s;
             if ( ix > width ) 
             {
                 ix = 400;
                 iy += s;
             }
         }
     }
 }
 
 int[] toBinaryPixels ( int[] pixels )
 {
     int[] tmp = new int[pixels.length];
     for ( int i = 0; i < pixels.length; i++ )
     {
         tmp[i] = ( ((pixels[i] >> 16) & 0xFF) + ((pixels[i] >> 8) & 0xFF) + (pixels[i] & 0xFF) ) / 3 > 127 ? 1 : 0;
     }
     return tmp;
 }
 
 void drawSilhouette ( PImage img, int ix, int iy, int iwidth, int iheight )
{
    removeTurquoise( img );
    
    int[] binPixels = toBinaryPixels( img.pixels );
     
     ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( binPixels, img.width, img.height );
     
     ImageUtilities.PixelCircumCircle bbCircle = ImageUtilities.getCircumCircle( binPixels, img.width, img.height, com.x, com.y );
     
     int bbCenterX = bbCircle.x, bbCenterY = bbCircle.y;
     int bbWidth = bbCircle.radius * 2, bbHeight = bbCircle.radius*2;
     
     int imgWidth  = bbWidth  + abs( bbCenterX - com.x );
     int imgHeight = bbHeight + abs( bbCenterY - com.y );
     int padding = 0;
     float imgSize = iwidth;
     float imgScale = imgSize / ( imgWidth > imgHeight ? imgWidth : imgHeight );
     
     image( img, ix + padding + -com.x * imgScale + imgSize/2, 
                 iy + padding + -com.y * imgScale + imgSize/2, 
                 img.width * imgScale, 
                 img.height * imgScale );
    
    removeCache( img );
}
