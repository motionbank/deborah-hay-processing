void initTakes ()
{    
    File takesDir = new File( silhouetteFolder );
    
    java.io.FilenameFilter f1 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n ) {
            return (n.startsWith("Ros_D02T02") || n.startsWith("Ros_D02T03")) && n.endsWith("_Corrected");
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
    currentTable = String.format( "silhouettes_test_%s", take.toLowerCase() );
    
    // i'm using taps to transfer the data from MySQL to SQLite later on,
    // MySQL is just faster when begin hosed like this ..
    
    // start taps server:
    // taps server -p 7777 mysql://moba:moba@localhost/moba_silhouettes x x
    
    // transfer data to SQLite file:
    // taps pull sqlite://dbV4ALLCenterCam.sqlite http://x:x@localhost:7777

//    File dbFile = new File( sketchPath( String.format( dbFilePath, take ) ) );
//    
//    //dbFile.delete();
//    
//    if ( !dbFile.exists() )
//    {
//        try {
//            dbFile.createNewFile();
//        } catch ( Exception e ) {
//            e.printStackTrace();
//            exit();
//            return;
//        }
//    }
//    
//    db = new SQLite( this, dbFile.getPath() );

    if ( db == null )
    {
        db = new MySQL( this, "localhost", "moba_silhouettes", "moba", "moba" );
        
        if ( !db.connect() )
        {
            System.err.println( "Unable to connect to database!" );
            exit();
            return;
        }
    }

    db.execute( "CREATE TABLE IF NOT EXISTS %s ( "+
                    "id INT(11) PRIMARY KEY AUTO_INCREMENT, " +
                    "fasthash BIGINT NOT NULL DEFAULT 0, " +
                    "hash BLOB, " +
                    "framenumber INTEGER NOT NULL DEFAULT 0, " +
                    "performance TEXT NOT NULL, " +
                    "angle TEXT NOT NULL, " +
                    "file TEXT NOT NULL, " +
                    "circle_x INTEGER NOT NULL DEFAULT 0, " +
                    "circle_y INTEGER NOT NULL DEFAULT 0, " +
                    "circle_radius REAL NOT NULL DEFAULT 0.0" +
                ")", currentTable );
}
