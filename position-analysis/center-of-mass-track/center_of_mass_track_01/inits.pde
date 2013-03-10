
void initTakes ()
{    
    File takesDir = new File( silhouetteFolder );
    
    java.io.FilenameFilter f1 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n ) {
            return n.endsWith("_Corrected");
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
    String camAngle = "CamLeft";
    
    java.io.FilenameFilter f2 = new java.io.FilenameFilter() {
        public boolean accept ( File f, String n) { 
            return n.endsWith(".png");
        }
    };
    
    pngs = new String[0];
    
    //File takeDir = new File( silhouetteFolder + "/" + takes[currentTake] + "/" + "Images_BackgroundSubstracted/" + camAngle );
    File takeDir = new File( "/Users/fjenett/Desktop/MOBA/silhouettes" );

    String[] takePngs = takeDir.list( f2 );
    for ( int i = 0, k = takePngs.length; i < k; i++ ) 
    {
        takePngs[i] = takeDir.getPath() + "/" + takePngs[i];
    }
    pngs = concat( pngs, takePngs );
    
    currentPng = 0;
    
    comTracksLeft = "";
    comTracksRight = "";
    
    println( "PNGs found to be processed: " + pngs.length );
}
