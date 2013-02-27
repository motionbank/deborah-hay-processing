/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Experimenting with radial hashing for silhouette similarity search
 *
 *    P2.0
 *    fjenett 20121214
 */
 
import de.bezier.data.sql.*;
import org.motionbank.hashing.*;
import org.motionbank.imaging.*;

SQLite db;
String dbFilePath = "../db/db_Test.sqlite";
String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";

PImage sil;
int xmi, ymi, xma, yma;
String[] pngs;
int currentSil = 0;
boolean isNewHash = true;
final static int HASH_SIZE = 128;

void setup ()
{
    size( 500, 800 );
    
    initDatabase();
    
    initPngs();
}

void draw ()
{
    background( 255 );
    
    //if ( isNewHash ) {
        
        db.query( "SELECT id FROM %s WHERE file = \"%s\"", "images", pngs[currentSil] );
        
        int id = -1;
        
        if ( db.next() )
        {
//            id = db.getInt( "id" );
//            db.execute( "UPDATE %s SET fasthash = %d, file = \"%s\" WHERE id = %d", "images", simpleHash, pngs[currentSil], id );
        }
        else
        {
            PImage silImage = loadPrepareBinaryImage();
                    
            ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( silImage.pixels, silImage.width, silImage.height );
            
            //ImageUtilities.PixelBoundingBox bbox = ImageUtilities.getBoundingBox( silImage.pixels, silImage.width, silImage.height );
            //int[] hash = computeHash( silImage, com.x, com.y, bbox.xCenter, bbox.yCenter, bbox.width, bbox.height );
            
            ImageUtilities.PixelBoundingCircle bbCircle = ImageUtilities.getBoundingCircle( silImage.pixels, silImage.width, silImage.height, com.x, com.y );
            int[] hash = computeHash( silImage, com.x, com.y, bbCircle.x, bbCircle.x, bbCircle.radius*2, bbCircle.radius*2 );
            
            FastHash fastHash = new FastHash( hash );
        
            noSmooth();
            image( sil, 0, 0, width, width );
            removeCache( sil );
        
            //     noFill(); stroke( 255, 0, 0 );
            //     rect( xmi, ymi, xma-xmi, yma-ymi );
            
            stroke( 0 );
            noFill();
            rect( 5, height-5-255, 3*hash.length, 255 );
        
            noStroke();
            fill( 0 );
            for ( int i = 0; i < hash.length; i++ )
            {
                rect( 5 + i*3, height - 5 - hash[i], 2, hash[i] );
                
                if ( hash[i] > 127 )
                {
                    rect( 5 + i*3, height - 5 - 255 - 10, 2, 5 );
                }
            }
            
            fill( 0 );
            text( fastHash.toHexString(), 5, height - 275 );
            
            db.execute( 
                "INSERT INTO %s ( fasthash, file ) VALUES ( \"%s\", \"%s\" )", 
                "images", 
                fastHash.toHexString(), 
                pngs[currentSil]
            );
            db.query( "SELECT last_insert_rowid() AS id" );
            id = db.getInt( "id" );
            
            if ( id != -1 )
            {
                String vals = "";
                for ( int i = 0; i < hash.length; i++ )
                {
                    vals += (vals.length() == 0 ? "" : ",") + String.format( "v%03d = %d", i, hash[i] );
                }
                
                db.execute( "UPDATE %s SET %s WHERE id = %d", "images", vals, id );
            }
        }
        
        //isNewHash = false;
        
        currentSil++;
        if ( currentSil == pngs.length ) exit();
    
    //}
    
    fill( 0 );
    text( String.format( "%02d%% (%d / %d)", (int)(((float)currentSil / pngs.length) * 100), currentSil, pngs.length), 10, 20 );
}


