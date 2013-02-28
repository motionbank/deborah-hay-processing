void initTakes ()
{    
    File takesDir = new File( silhouetteFolder );
    
    java.io.FilenameFilter f1 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n ) {
            return /*n.startsWith("Ros_D02T01") &&*/ n.endsWith("_Corrected");
        }
    };
    
    takes = takesDir.list(f1);
    
    if ( takes == null )
    {
        System.err.println( "No silhouettes folders found at " + silhouetteFolder );
        exit();
        return;
    }
    
    currentTake = 0;
}

void initPngs ()
{
    java.io.FilenameFilter f2 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n) { 
            return n.endsWith(".png");
        }
    };
    
    pngs = new String[0];
    
    File takeDir = new File( silhouetteFolder + "/" + takes[currentTake] + "/" + "Images_BackgroundSubstracted/" + camAngle );

    String[] takePngs = takeDir.list( f2 );
    for ( int i = 0, k = takePngs.length; i < k; i++ ) 
    {
        takePngs[i] = takes[currentTake] + "/" + "Images_BackgroundSubstracted/" + camAngle + "/" + takePngs[i];
    }
    pngs = concat( pngs, takePngs );
    
    currentPng = 0;
    
    println( "PNGs found to be processed: " + pngs.length );
}

void initDatabase ()
{
    String[] pieces = takes[currentTake].split("_");
    String take = pieces[0] + "_" + pieces[1] + "_" + camAngle;
    
    File dbFile = new File( sketchPath( String.format( dbFilePath, take ) ) );
    
    dbFile.delete();
    
    if ( !dbFile.exists() )
    {
        try {
            dbFile.createNewFile();
        } catch ( Exception e ) {
            e.printStackTrace();
            exit();
            return;
        }
    }
    
    db = new SQLite( this, dbFile.getPath() );
    
    if ( db.connect() )
    {
        String vals = "";
        for ( int i = 0; i < HASH_SIZE; i++ )
        {
            vals += String.format( (i > 0 ? ", " : " ") + "v%03d INTEGER ", i );
        }
        db.execute( "CREATE TABLE IF NOT EXISTS images ( "+
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        //"fasthash64 INT, " +
                        "fasthash TEXT, " +
                        "framenumber INT, " +
                        "performance TEXT, " +
                        "angle TEXT, " +
                        "file TEXT, " +
                        vals +
                    ")" );
        
        addSQLiteHammingDistance();
        
//        db.query( "SELECT hamming_distance(255,126) as v" );
//        println( db.getInt( "v" ) );
    }
    else
    {
        System.err.println( "Unable to connect to database!" );
        exit();
    }
}

void addSQLiteHammingDistance ()
{
    // HAMMING DISTANCE in SQLite
    // http://en.wikipedia.org/wiki/Hamming_distance
    // This seems related:
    // http://codeblow.com/questions/hamming-distance-on-binary-strings-in-sql/
    
    try {
    org.sqlite.Function.create( db.getConnection(), "hamming_distance", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                int val0 = value_int(0);
                int val1 = value_int(1);
                int dist = 0;
                
                if ( val0 == val1 ) 
                {
                    dist = 0;
                }
                else
                {
                    int val = val0 ^ val1;
                
                    while ( val != 0 )
                    {
                        ++dist;
                        val &= val - 1;
                    }
                }
                
                result( dist );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    } catch ( Exception e ) {
        e.printStackTrace();
    }
}
