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

MySQL db;
String dbFilePath = "../db/db_v4_%s.sqlite";
String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";

String[] takes;
int currentTake = 0;

String[] pngs;
int currentPng = 0;
PImage sil;

//final static int HASH_SIZE = 16;
String camAngle = "CamCenter";

void setup ()
{
    size( 500, 800 );
    
    initTakes();
    initDatabase();
    initPngs();
    
    frameRate( 999 );
}

void draw ()
{
    background( 255 );

    db.query( "SELECT id FROM %s WHERE file = \"%s\"", "silhouettes", pngs[currentPng] );
    
    int id = -1;
    String performance = "", camAngle = "";
    int frameNumber = -1;
    
    if ( db.next() )
    {
        println( String.format( "Entry with id %d already exists", db.getInt( "id" ) ) );
    }
    else
    {
        PImage silImage = loadPrepareBinaryImage( pngs[currentPng] );
                
        ImageUtilities.PixelLocation centerOfMass = 
            ImageUtilities.getCenterOfMass( silImage.pixels, 
                                            silImage.width, silImage.height );
        
        //ImageUtilities.PixelBoundingBox bbox = ImageUtilities.getBoundingBox( silImage.pixels, silImage.width, silImage.height );
        //int[] hash = computeHash( silImage, centerOfMass.x, centerOfMass.y, bbox.xCenter, bbox.yCenter, bbox.width, bbox.height );
        
        ImageUtilities.PixelCircumCircle circumCircle = 
            ImageUtilities.getCircumCircle( silImage.pixels, 
                                            silImage.width, silImage.height, 
                                            centerOfMass.x, centerOfMass.y );
        
        int[] hash = computeHash( silImage, 
                                  centerOfMass.x, centerOfMass.y, 
                                  circumCircle.x, circumCircle.y, 
                                  circumCircle.radius*2, circumCircle.radius*2 );
        
        // pack hash bytes into binary array
        
        int[] hashBits = new int[hash.length * 8];
        for ( int i = 0; i < hash.length; i++ )
        {
            int aByte = hash[i] & 0xFF;
            for ( int ii = 0; ii < 8; ii++ )
            {
                hashBits[i*8 + ii] = (aByte >> (7-ii)) & 0x1;
            }
        }
        FastHash fullHash = new FastHash( hashBits );
        
        // byte to bit ---------
        
        int[] hashLong64 = new int[64];
        for ( int i = 0; i < hashLong64.length && i < hash.length; i++ )
        {
            hashLong64[i] = (hash[i] & 0xFF) > 127 ? 1 : 0;
        }
        FastHash fastHash = new FastHash( hashLong64 );
        
        // store it -------------
        
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
            "INSERT INTO silhouettes ( "+
                "fasthash ," +
                "hash, "+
                "framenumber, "+
                "performance, "+
                "angle, "+
                "file, "+
                "circle_x, "+
                "circle_y, "+
                "circle_radius "+
            ") VALUES ( "+
                "%d, X'%s', %d, \"%s\", \"%s\", \"%s\", %d, %d, %d "+
            ")", 
            fastHash.toLong64(),
            fullHash.toHexString(),
            frameNumber,
            performance,
            camAngle,
            pngs[currentPng],
            circumCircle.x,
            circumCircle.x,
            circumCircle.radius
        );
        
        db.query( "SELECT last_insert_id() AS id" );
        db.next();
        id = db.getInt( "id" );
        
        if ( id != -1 )
        {
            
        }
        
        // draw it -------------------------------------
        
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
        text( fullHash.toHexString(), 5, height - 275 );
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


