/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Read silhouette from file, generate hash, query database and show results along
 *
 *    Processing 2.0b
 *    fjenett 20121214
 */

import de.bezier.data.sql.*;
import org.motionbank.imaging.*;

MySQL db;
String table = "silhouettes";
String silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/";

PImage sil;
int currentId = 0;
int currentFrame = 0;

int hashLength = 124; // 4 + 8 + 16 + 32 + 64

float ts1a = 0, ts2a = 0;
int tsi = 0;

void setup ()
{
    size( 500, 250 );

    currentId = 0;
    initDatabase();
}

void draw ()
{
    background( 255 );

    db.query( "SELECT *, "+
        "LPAD(HEX(hash64) ,16,'F') AS hash64_hex, "+
        "LPAD(HEX(hash128),16,'F') AS hash128_hex, "+
        "LPAD(HEX(hash192),16,'F') AS hash192_hex, "+
        "LPAD(HEX(hash256),16,'F') AS hash256_hex "+
        "FROM %s WHERE id > %d ORDER BY id LIMIT 1", table, currentId );

    if ( db.next() )
    {
        currentId = db.getInt( "id" );
        //long fasthash = db.getLong( "fasthash" );
        String performance = db.getString( "performance" );
        String file = db.getString( "file" );
        int framenumber = db.getInt( "framenumber" );

        String[] hashes = {
            db.getString( "hash64_hex" ), 
            db.getString( "hash128_hex" ), 
            db.getString( "hash192_hex" ), 
            db.getString( "hash256_hex" )
        };

//            int[] vals = new int[hashLength];
//        String valQuery = "";
//        for ( int i = 0; i < vals.length; i++ )
//        {
//            vals[i] = db.getInt( "val" + nf(i, 3) );
//
//            valQuery += (i > 0 ? " + " : " " ) + " ABS( val"+nf(i, 3)+" - "+vals[i]+" )";
//        }

        sil = loadImage( silhouetteFolder + "/" + file );
        drawSilhouette( sil, 0, 0, 250, 250 );

        long ts1 = System.currentTimeMillis();

        db.query( "SELECT *, "+
            "BIT_COUNT( X'%s' ^ hash64 ) + "+
            "BIT_COUNT( X'%s' ^ hash128 ) + "+
            "BIT_COUNT( X'%s' ^ hash192 ) + "+
            "BIT_COUNT( X'%s' ^ hash256 ) AS bitdist, "+
            "ABS( %d - framenumber ) AS framedist "+
            "FROM %s "+
            "WHERE NOT id = %d "+
                "AND performance NOT LIKE \"%s\" " +
            "HAVING "+
                "bitdist < 30 " + 
            "ORDER BY bitdist ASC, framedist DESC "+
            "LIMIT 1", 
            hashes[0], hashes[1], hashes[2], hashes[3], 
            framenumber,
            table, 
            currentId, 
            performance
            );

        ts1a += (System.currentTimeMillis() - ts1) / 1000.0;
        //println( "Querytime: " + (ts1a / tsi) );

        //db.query( "SELECT id, file, (%s) AS dist FROM images WHERE id IS NOT %d AND dist < 200 ORDER BY dist ASC LIMIT 26", vals, id );
        //db.query( "SELECT id, file, fasthash, hamming_distance(%d,fasthash) AS hdist FROM images WHERE id != %d AND hdist < 2 ORDER BY hdist LIMIT 26" , fasthash, id );

        int x = 250, y = 0;

        while ( db.next () )
        {
            //currentId = db.getInt( "id" );
            PImage img = loadImage( silhouetteFolder + "/" + db.getString( "file" ) );
            //int dist = db.getInt( "dist" );
            int bitDist = db.getInt( "bitdist" );
            String perf = db.getString( "performance" ) + "_" + db.getInt( "framenumber" );

            drawSilhouette( img, x, y, 250, 250 );

            fill( 0 );
            //text( dist + " | " + bitDist, x+5, y+15 );
            //text( perf, x+5, y+35 );

            x += 250;
            if ( x > width )
            {
                x = 0;
                y += 250;
            }
        }

        //saveFrame( "output" + "/" + nf(currentId, 7) + ".png" );
        //currentId += 2;

        tsi++;
    }
    else
    {
        println( "Nothing to do .. bye!" );
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

