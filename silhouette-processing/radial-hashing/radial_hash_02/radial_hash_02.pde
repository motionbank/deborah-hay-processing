/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Experimenting with radial hashing for silhouette similarity search
 *
 *    Processing 2.0b
 *    fjenett 20121214
 */
 
import de.bezier.data.sql.*;
import org.motionbank.hashing.*;
import org.motionbank.imaging.*;

MySQL db;
//String dbFilePath = "../db/db_v5_%s.sqlite";
String currentTable = "";
String tableNameTemplate = "silhouettes_test3_%s";
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

    db.query( "SELECT id FROM %s WHERE file = \"%s\" LIMIT 1", currentTable, pngs[currentPng] );
    
    int id = -1;
    String performance = "", camAngle = "";
    int frameNumber = -1;
    
    if ( db.next() )
    {
        //println( String.format( "Entry with id %d already exists", db.getInt( "id" ) ) );
    }
    else
    {
        PImage silImage = loadPrepareBinaryImage( pngs[currentPng] );
        
        PImage silImageGross = silImage.get();

        if ( silImageGross.width > 10 )
        {
            silImageGross.filter( BLUR, 3 );
            silImageGross.filter( THRESHOLD, 0.7 );
        }
        
        ImageUtilities.PixelLocation centerOfMass = 
            ImageUtilities.getCenterOfMass( silImageGross.pixels, 
                                            silImageGross.width, silImageGross.height );
        
//        ImageUtilities.PixelBoundingBox bbox = 
//            ImageUtilities.getBoundingBox( silImageGross.pixels, 
//                                           silImageGross.width, silImageGross.height );
//        
//        int[] hash = computeHash( silImage, 
//                                  centerOfMass.x, centerOfMass.y, 
//                                  bbox.x, bbox.y, 
//                                  bbox.width, bbox.height );
        
        ImageUtilities.PixelCircumCircle circumCircle = 
            ImageUtilities.getCircumCircle( silImage.pixels, 
                                            silImage.width, silImage.height, 
                                            centerOfMass.x, centerOfMass.y );
        
        int[] hash = computeHash( silImage, 
                                  centerOfMass.x, centerOfMass.y, 
                                  circumCircle.x, circumCircle.y, 
                                  circumCircle.radius*2, circumCircle.radius*2 );
        
        // pack hash bytes into binary array
        
//        String hashVals = "", hashColumns = "";
//        for ( int i = 0; i < hash.length; i++ )
//        {
//            if ( i > 0 )
//           {
//               hashVals += " , ";
//               hashColumns += " , ";
//           }
//            hashVals += (hash[i] & 0xFF);
//            hashColumns += "val"+nf(i,3);
//        }
        
        // byte to bit ---------
        
        String[] hashes = new String[4];
        
        for ( int h = 0; h < hashes.length; h++ )
        {
            int[] hashBlock = new int[64];
            
            for ( int i = 0, k = h*64; i < 64; i++ )
            {
                hashBlock[i] = (hash[k+i] & 0xFF) > 127 ? 1 : 0;
            }
            FastHash hashBlockObj = new FastHash( hashBlock );
            hashes[h] = hashBlockObj.toHexString();
        }
        
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
        
        if ( true ) 
        {
            db.execute( 
                "INSERT INTO %s ( "+
                    "framenumber, "+
                    "performance, "+
                    "angle, "+
                    "file, "+
                    "center_x, "+
                    "center_y, "+
                    "circle_radius, "+
                    "hash64, hash128, hash192, hash256 "+
                ") VALUES ( "+
                    "%d, \"%s\", \"%s\", \"%s\", "+
                    "%d, %d, %d, "+
                    " X'%s', X'%s', X'%s', X'%s'"+
                ")", 
                currentTable,
                frameNumber,
                performance,
                camAngle,
                pngs[currentPng],
                centerOfMass.x,
                centerOfMass.y,
                circumCircle.radius,
                hashes[0],
                hashes[1],
                hashes[2],
                hashes[3]
            );
            
            db.query( "SELECT last_insert_id() AS id" );
            db.next();
            id = db.getInt( "id" );
            
            if ( id != -1 )
            {
                
            }
        }
        
        // draw it -------------------------------------
        
        noSmooth();
        image( sil, 0, 0, width, width );
        removeCache( sil );
        
        float vWidth = (width-10.0) / hash.length;
        int vWidthInt = (int)(vWidth) - 1;
        vWidthInt = vWidthInt < 1 ? 1 : vWidthInt;
        
        stroke( 0 ); noFill();
        rect( 5, height-5-255, hash.length*vWidth, 255 );
    
        noStroke(); fill( 0 );
        
        for ( int i = 0, ii = 0; i < hash.length; i++ )
        {
            rect( 5+i*vWidth, height-5-(255-hash[i]), vWidthInt, (255-hash[i]) );
            
//            ii = (int)round(i / k);
//            if ( ii < hashFast.length && hashFast[ii] == 0 )
//                rect( 5+i*vWidth, height-5-255-5-5, vWidth, 5 );
        }
        
//        fill( 0 );
//        textSize( 9 );
//        text( fullHash.toHexString(), 5, height - 275 );
    
    } // entry exists?
    
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
    textSize( 12 );
    text( String.format( "%d%% % 6d of % 6d", (int)(((float)currentPng / pngs.length) * 100), currentPng, pngs.length), 10, 20 );
    text( String.format( "%s %s %06d", performance, camAngle, frameNumber ), 10, 36 );
}


