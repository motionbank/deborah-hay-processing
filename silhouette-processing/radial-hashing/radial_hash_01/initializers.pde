void initPngs ()
{
    //silhouetteFolder = "/Users/fjenett/Desktop/silhouettes";
    silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/Ros_D01T01_withBackgroundAdjustment_Corrected/Images_BackgroundSubstracted/CamCenter";
    
    File takesDir = new File( silhouetteFolder );
    java.io.FilenameFilter f1 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n ) {
            return n.startsWith("Ros_D01") && n.endsWith("_Corrected");
        }
    };
    java.io.FilenameFilter f2 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n) {
            return n.endsWith(".png");
        }
    };
    
    //String[] takes = takesDir.list(f1);
    
    pngs = new String[0];
    
//    for ( String t : takes )
//    {
        File takeDir = null; //new File( silhouetteFolder + "/" + t + "/" + "Images_BackgroundSubstracted/CamCenter" );
        takeDir = new File( silhouetteFolder );
        
        String[] takePngs = takeDir.list( f2 );
//        for ( int i = 0, k = takePngs.length; i < k; i++ ) {
//            takePngs[i] = t + "/" + "Images_BackgroundSubstracted/CamCenter" + "/" + takePngs[i];
//        }
        pngs = concat( pngs, takePngs );
//    }
    
    println( "PNGs found to be processed: " + pngs.length );
}

void initDatabase ()
{
    db = new SQLite( this, sketchPath("../db.sqlite") );
    
    if ( db.connect() )
    {
        String vals = "";
        for ( int i = 0; i < 32; i++ )
        {
            vals += String.format( "v%03d INTEGER, ", i );
        }
        db.execute( "CREATE TABLE IF NOT EXISTS images ( "+
                    "id INTEGER PRIMARY KEY , " +
                    "fasthash INTEGER , " +
                    vals +
                    "file TEXT )" );
        
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
