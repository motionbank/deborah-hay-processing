/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Read silhouette from file, generate hash, query database and show results along
 *
 *    P2.0
 *    fjenett 20121214
 */
 
import de.bezier.data.sql.*;
 import org.motionbank.imaging.*;

SQLite db;
String databasePath;
String database = "../db/db_v2_Ros_ALL_CamCenter.sqlite";

PImage sil;
String silhouetteFolder;
String[] pngs;
int currentSil = 1000;

void setup ()
{
    size( 250 * 6, 250 * 4 );
    
    initDatabase();
    initPngs();
    
    frameRate( 10 );
}

void draw ()
{
    background( 255 );
    
    int x = 0, y = 0;
    
    sil = loadImage( silhouetteFolder + "/" + pngs[currentSil] );
    
    drawSilhouette( sil, 0, 0, 200, 200 );
    
    db.query( "SELECT id, hex(hash) as hash, performance FROM images WHERE file = \"%s\"", pngs[currentSil] );
    if ( db.next() )
    {
        int id = db.getInt( "id" );
        String fasthash = db.getString( "hash" );
        String performance = db.getString( "performance" );
        
//        String vals = "";
//        for ( int i = 0; i < 32; i++ )
//        {
//            vals += (vals.length() > 0 ? " + " : "") + String.format( "abs(v%03d - %d)", i, db.getInt( String.format("v%03d", i) ) );
//        }
        
        long ts = System.currentTimeMillis();
        
        db.query( "SELECT id, file, hex_dist( X'%s', hash ) as dist, performance "+
                      "FROM images "+
                      "WHERE id IS NOT %d AND "+
                            "performance NOT LIKE \"%s\" AND "+
                            "dist < 200 "+
                      "ORDER BY dist "+
                      "LIMIT 26", 
                      fasthash, 
                      id,
                      performance );
        
        //db.query( "SELECT id, file, (%s) AS dist FROM images WHERE id IS NOT %d AND dist < 200 ORDER BY dist ASC LIMIT 26", vals, id );
        //db.query( "SELECT id, file, fasthash, hamming_distance(%d,fasthash) AS hdist FROM images WHERE id != %d AND hdist < 2 ORDER BY hdist LIMIT 26" , fasthash, id );

        println( (System.currentTimeMillis() - ts) / 1000.0 );
        
        while ( db.next() )
        {
            PImage img = loadImage( silhouetteFolder + "/" + db.getString( "file" ) );
            int dist = db.getInt( "dist" );
            String perf = db.getString( "performance" );
            
            x += 250;
            if ( x > width )
            {
                x = 0;
                y += 250;
            }
            
            drawSilhouette( img, x, y, 200, 200 );
            
            fill( 0 );
            text( dist, x+5, y+15 );
            text( perf, x+5, y+35 );
        }
    }
    
    currentSil += 3;
}

void drawSilhouette ( PImage img, int ix, int iy, int iwidth, int iheight )
{
    removeTurquoise( img );
    
    int[] binPixels = toBinaryPixels( img.pixels );
     
     ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( binPixels, img.width, img.height );
     
     ImageUtilities.PixelBoundingCircle bbCircle = ImageUtilities.getBoundingCircle( binPixels, img.width, img.height, com.x, com.y );
     
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
