import de.bezier.data.sql.*;

MySQL db;
PApplet papplet;

 int total = 0;
 int current = 0;

void setup ()
{
    size( 200, 200 );
    
    papplet = this;
    
    new Thread(){
        public void run () {
            db = new MySQL( papplet, "localhost", "moba_silhouettes", "moba", "moba" );
            if ( db.connect() )
            {
                db.query( "SELECT count(*) AS total, LENGTH(hash) AS length FROM silhouettes" );
                db.next();
                total = db.getInt( "total" );
                int hashLen = db.getInt( "length" );
                
                // create the table
                
                String valQuery = "";
                for ( int i = 0; i < hashLen; i++ )
                {
                    if ( i > 0 ) valQuery += " , ";
                    valQuery += "val"+nf(i,3)+" TINYINT UNSIGNED NOT NULL ";
                }
                
                db.execute(
                    "CREATE TABLE IF NOT EXISTS sil_test ( "+
                        "id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, "+
                        "fasthash BIGINT NOT NULL, "+
                        "file TEXT NOT NULL, "+
                        "framenumber INT NOT NULL, "+
                        "performance VARCHAR(20), "+
                        valQuery+
                    ")"
                );
                
                // transport data
                
                String query = "SELECT * FROM silhouettes WHERE id > %d LIMIT 1";
                int id = 0;
                db.query( query, id );
                while ( db.next() )
                {
                    id = db.getInt("id");
                    byte[] hash = db.getBlob( "hash" );
                    
                    String valsVals = "";
                    String valsColumns = "";
                    for ( int i = 0; i < hashLen; i++ )
                    {
                        if ( i > 0 ) {
                            valsVals += " , ";
                            valsColumns += " , ";
                        }
                        valsVals += (hash[i] + 128);
                        valsColumns += "val"+nf(i,3);
                    }
                    
                    db.execute(
                        "INSERT INTO sil_test ( fasthash, file, framenumber, performance, "+
                            valsColumns + " ) SELECT %d, \"%s\", %d, \"%s\", "+
                            valsVals,
                        db.getLong("fasthash"),
                        db.getString("file"),
                        db.getInt("framenumber"),
                        db.getString("performance")
                    );
                    
                    db.query( query, id );
                    current++;
                }
            }
        }
    }.start();
}

 void draw ()
 {
     background( 255 );
     
     noFill();
     stroke( 0 );
     ellipse( width/2, height/2, width/2, height/2 );
     
     fill( 0 );
     noStroke();
     arc( width/2, height/2, width/2, height/2, -HALF_PI, map( current, 0, total, 0, TWO_PI )-HALF_PI );
 }
