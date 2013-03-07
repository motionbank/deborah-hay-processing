/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Processing 2.0b
 *    fjenett 20130306
 */

import de.bezier.data.sql.*;
import org.motionbank.imaging.*;

MySQL db;
String table = "silhouettes";
String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";

PImage sil;

int currentFrame = 0;
String currentPerformance = "Ros_D01T01";
String[] lastFrames;

void setup ()
{
    size( 250, 250 );

    initDatabase();
    lastFrames = new String[]{
        "-1"
    };
    
    frameRate( 50 );
}

void draw ()
{
    background( 255 );

    db.query( "SELECT *, "+
        "LPAD(HEX(hash64) ,16,'F') AS hash64_hex, "+
        "LPAD(HEX(hash128),16,'F') AS hash128_hex, "+
        "LPAD(HEX(hash192),16,'F') AS hash192_hex, "+
        "LPAD(HEX(hash256),16,'F') AS hash256_hex "+
        "FROM %s WHERE framenumber = %d AND performance = \"%s\"", 
        table, 
        currentFrame,
        currentPerformance );

    if ( db.next() )
    {
//        lastFrames = (String[])append( lastFrames, currentFrame+"" );
//        if ( lastFrames.length > 1000 )
//        {
//            String[] tmp = new String[1000];
//            System.arraycopy( lastFrames, 1, tmp, 0, 1000 );
//            lastFrames = tmp;
//            tmp = null;
//        }
        
        String file = db.getString( "file" );

        String[] hashes = {
            db.getString( "hash64_hex" ), 
            db.getString( "hash128_hex" ), 
            db.getString( "hash192_hex" ), 
            db.getString( "hash256_hex" )
        };

        sil = loadImage( silhouetteFolder + "/" + file );
        drawSilhouette( sil, 0, 0, 250, 250 );
        
        db.query( "SELECT *, "+
            "BIT_COUNT( X'%s' ^ hash64 ) + "+
            "BIT_COUNT( X'%s' ^ hash128 ) + "+
            "BIT_COUNT( X'%s' ^ hash192 ) + "+
            "BIT_COUNT( X'%s' ^ hash256 ) AS bitdist, "+
            "ABS( %d - framenumber ) AS framedist "+
            "FROM %s "+
            "WHERE "+
                "performance NOT LIKE \"%s\" AND framenumber >= %d " +
            "HAVING "+
                "bitdist < %d " +
            "ORDER BY bitdist ASC, framedist DESC "+
            "LIMIT 1", 
            hashes[0], hashes[1], hashes[2], hashes[3], 
            currentFrame,
            table, 
            currentPerformance,
            currentFrame,
            (int)(random(0,18))
        );

        if ( db.next () )
        {
            currentPerformance = db.getString( "performance" );
            currentFrame = db.getInt( "framenumber" );
        }
        
        currentFrame++;

        //saveFrame( "output" + "/" + nf(currentId, 7) + ".png" );
    }
    else
    {
        println( "After so many frames, "+currentFrame+", nothing more left to do .. bye!" );
        exit();
    }
}

void initDatabase ()
{
    db = new MySQL( this, "localhost", "moba_silhouettes", "moba", "moba" );
    
    if ( db.connect() )
    {
    }
    else
    {
        System.err.println( "Unable to connect to database!" );
        exit();
    }
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

