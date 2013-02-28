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
String dbFilePath = "../db/db_v2_%s.sqlite";
String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";

String[] takes;
int currentTake = 0;

String[] pngs;
int currentPng = 0;
PImage sil;

final static int HASH_SIZE = 128;
String camAngle = "CamCenter";

void setup ()
{
    size( 500, 800 );
    
    initTakes();
    initDatabase();
    initPngs();
}

void draw ()
{
    background( 255 );

    db.query( "SELECT id FROM %s WHERE file = \"%s\"", "images", pngs[currentPng] );
    
    int id = -1;
    String performance = "", camAngle = "";
    int frameNumber = -1;
    
    if ( db.next() )
    {
    }
    else
    {
        PImage silImage = loadPrepareBinaryImage( pngs[currentPng] );
                
        ImageUtilities.PixelLocation com = ImageUtilities.getCenterOfMass( silImage.pixels, silImage.width, silImage.height );
        
        //ImageUtilities.PixelBoundingBox bbox = ImageUtilities.getBoundingBox( silImage.pixels, silImage.width, silImage.height );
        //int[] hash = computeHash( silImage, com.x, com.y, bbox.xCenter, bbox.yCenter, bbox.width, bbox.height );
        
        ImageUtilities.PixelBoundingCircle bbCircle = ImageUtilities.getBoundingCircle( silImage.pixels, silImage.width, silImage.height, com.x, com.y );
        
        int[] hash = computeHash( silImage, com.x, com.y, bbCircle.x, bbCircle.x, bbCircle.radius*2, bbCircle.radius*2 );
        
        FastHash fastHash = new FastHash( hash );
        
        int[] hash64 = new int[64];
        for ( int i = 0; i < hash.length; i+= 2 )
        {
            int v = (hash[i] + hash[i+1]) / 2;
            hash64[i/2] = v;
        }
        
        HashingUtilities.binarizeValues( hash64, 127 );
        FastHash fastHash64 = new FastHash( hash64 );
    
        noSmooth();
        image( sil, 0, 0, width, width );
        removeCache( sil );
        
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
        
        String[] pieces = pngs[currentPng].split( "/" );
        frameNumber = Integer.parseInt(
                            pieces[pieces.length-1].substring(
                                pieces[pieces.length-1].length()-10, 
                                pieces[pieces.length-1].length()-4
                            )
                      );
        
//        camAngle = pieces[pieces.length-1].split("_")[0];
        
        pieces = pieces[0].split( "_" );
        performance = pieces[0] + "_" + pieces[1];
        
        db.execute( 
            "INSERT INTO %s ( "+
                "fasthash64, fasthash128, framenumber, performance, angle, file "+
            ") VALUES ( %d, \"%s\", %d, \"%s\", \"%s\", \"%s\" )", 
            "images", 
            fastHash64.getLong64(),
            fastHash.toHexString(),
            frameNumber,
            performance,
            camAngle,
            pngs[currentPng]
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
    
    currentPng++;
    if ( currentPng == pngs.length ) 
    {
        currentTake++;
        if ( currentTake == takes.length )
        {
            exit();
            return;
        }
        initDatabase();
        initPngs();
    }
    
    fill( 0 );
    text( String.format( "%d%% % 6d of % 6d", (int)(((float)currentPng / pngs.length) * 100), currentPng, pngs.length), 10, 20 );
    text( String.format( "%s %s %06d", performance, camAngle, frameNumber ), 10, 36 );
}


