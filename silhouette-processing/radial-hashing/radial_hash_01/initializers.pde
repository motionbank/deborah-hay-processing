void initTakes ()
{    
    File takesDir = new File( silhouetteFolder );
    
    java.io.FilenameFilter f1 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n ) {
            return n.startsWith("Ros_") && n.endsWith("_Corrected");
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
//        String vals = "";
//        for ( int i = 0; i < HASH_SIZE; i++ )
//        {
//            vals += String.format( (i > 0 ? ", " : " ") + "v%03d INTEGER ", i );
//        }
        db.execute( "CREATE TABLE IF NOT EXISTS images ( "+
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "hash BLOB, " +
                        "framenumber INT, " +
                        "performance TEXT, " +
                        "angle TEXT, " +
                        "file TEXT " +
                        //vals +
                    ")" );
        
//        db.query( "SELECT hamming_distance(255,126) as v" );
//        println( db.getInt( "v" ) );
    }
    else
    {
        System.err.println( "Unable to connect to database!" );
        exit();
    }
}
