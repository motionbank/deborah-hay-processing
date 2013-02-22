/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Experimenting with radial hashing for silhouette similarity search
 *
 *    P2.0
 *    fjenett 20121214
 */
 
import de.bezier.data.sql.*;

SQLite db;

PImage sil;
int xmi, ymi, xma, yma;
String silhouetteFolder;
String[] pngs;
int currentSil = 0;
boolean isNewHash = true;

void setup ()
{
    size( 500, 800 );
    
    initDatabase();
    
    initPngs();
}

void draw ()
{
    background( 255 );

    int[] hash = radialHashing();
    
    int simpleHash = 0;
    for ( int i = 0; i < 32; i++ )
    {
        int bit = (hash[i] > 127) ? 0 : 1;
        simpleHash = simpleHash + (bit << i);
    }

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
        
        if ( ((simpleHash >> i) & 0x1) == 0 )
        {
            rect( 5 + i*3, height - 5 - 255 - 10, 2, 5 );
        }
    }
    
    fill( 0 );
    text( simpleHash, 5, height - 275 );
    
    if ( isNewHash )
    {
        db.query( "SELECT id FROM %s WHERE file = \"%s\"", "images", pngs[currentSil] );
        
        int id = -1;
        if ( db.next() )
        {
            id = db.getInt( "id" );
            
            db.execute( "UPDATE %s SET fasthash = %d, file = \"%s\" WHERE id = %d", "images", simpleHash, pngs[currentSil], id );
        }
        else
        {
            db.execute( "INSERT INTO %s ( fasthash, file ) VALUES (%d, \"%s\")", "images", simpleHash, pngs[currentSil] );
            db.query( "SELECT last_insert_rowid() AS id" );
            id = db.getInt( "id" );
        }
        
        if ( id != -1 )
        {
            String vals = "";
            for ( int i = 0; i < hash.length; i++ )
            {
                vals += (vals.length() == 0 ? "" : ",") + String.format( "v%03d = %d", i, hash[i] );
            }
            
            db.execute( "UPDATE %s SET %s WHERE id = %d", "images", vals, id );
        }
        
        //isNewHash = false;
        
        currentSil++;
        if ( currentSil == pngs.length ) exit();
    }
    
    fill( 0 );
    text( String.format( "%03d", (int)(((float)currentSil / pngs.length) * 100) ), 10, 20 );
}


