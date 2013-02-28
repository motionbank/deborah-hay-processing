/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Read silhouette from file, generate hash, query database and show results along
 *
 *    P2.0
 *    fjenett 20121214
 */
 
import de.bezier.data.sql.*;

SQLite db;
String databasePath;
String database = "../db/db_v2_Janine_D05T01_CamCenter.sqlite";

PImage sil;
String silhouetteFolder;
String[] pngs;
int currentSil = 0;

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
    removeTurquoise( sil );
    image( sil, 0, 0 );
    removeCache( sil );
    
    db.query( "SELECT * FROM images WHERE file = \"%s\"", pngs[currentSil] );
    if ( db.next() )
    {
        int id = db.getInt( "id" );
        String fasthash = db.getString( "hash" );
        
//        String vals = "";
//        for ( int i = 0; i < 32; i++ )
//        {
//            vals += (vals.length() > 0 ? " + " : "") + String.format( "abs(v%03d - %d)", i, db.getInt( String.format("v%03d", i) ) );
//        }
        
        db.query( "SELECT id, file, hex_dist( \"%s\", hash ) as dist FROM images WHERE id IS NOT %d AND dist < 200 ORDER BY dist LIMIT 26", fasthash, id );
        
        //db.query( "SELECT id, file, (%s) AS dist FROM images WHERE id IS NOT %d AND dist < 200 ORDER BY dist ASC LIMIT 26", vals, id );
        
        //db.query( "SELECT id, file, fasthash, hamming_distance(%d,fasthash) AS hdist FROM images WHERE id != %d AND hdist < 2 ORDER BY hdist LIMIT 26" , fasthash, id );
        
        while ( db.next() )
        {
            PImage img = loadImage( silhouetteFolder + "/" + db.getString( "file" ) );
            int dist = db.getInt( "dist" );
            
            x += 250;
            if ( x > width )
            {
                x = 0;
                y += 250;
            }
            
            removeTurquoise( img );
            image( img, x, y );
            removeCache( img );
            
            fill( 0 );
            text( dist, x+5, y+15 );
        }
    }
    
    currentSil++;
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
