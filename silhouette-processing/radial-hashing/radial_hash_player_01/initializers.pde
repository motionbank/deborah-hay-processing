void initPngs ()
{
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
    
    //silhouetteFolder = "/Users/fjenett/Desktop/silhouettes";
    silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results";
    
    File takesDir = new File( silhouetteFolder );
    
    String[] takes = takesDir.list(f1);
    
    pngs = new String[0];
    
    for ( String t : takes )
    {
        File takeDir = new File( silhouetteFolder + "/" + t + "/" + "Images_BackgroundSubstracted/CamCenter" );
//        takeDir = new File( silhouetteFolder );
        
        String[] takePngs = takeDir.list( f2 );
        for ( int i = 0, k = takePngs.length; i < k; i++ ) {
            takePngs[i] = t + "/" + "Images_BackgroundSubstracted/CamCenter" + "/" + takePngs[i];
        }
        pngs = concat( pngs, takePngs );
    }
    
    println( "PNGs found to be processed: " + pngs.length );
}

void initDatabase ()
{
    db = new SQLite( this, sketchPath( database ) );
    
    if ( db.connect() )
    {
        addSQLiteDistanceFunctions();
    }
    else
    {
        System.err.println( "Unable to connect to database!" );
        exit();
    }
}

void addSQLiteDistanceFunctions ()
{
    try {
        
    // compare two blobs
        
    org.sqlite.Function.create( db.getConnection(), "hex_dist", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                byte[] val0 = value_blob(0);
                byte[] val1 = value_blob(1);
                
                int dist = 0;
            
                for ( int i = 0, k = val0.length; i < k; i ++ )
                {
                    int d = val0[i] - val1[i];
                    dist += d > 0 ? d : -d;
                }
                
                result( dist );
                
            } catch ( Exception e ) {
                e.printStackTrace();
            }
        }
    });
    
    // compare two longs
    
    org.sqlite.Function.create( db.getConnection(), "bit_dist", new org.sqlite.Function() {
        protected void xFunc() {
            try {
                
                long val0 = value_long(0);
                long val1 = value_long(1);
                
                int dist = 0;
                
                if ( val0 == val1 ) 
                {
                    dist = 0;
                }
                else
                {
                    long val = val0 ^ val1;
                
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
