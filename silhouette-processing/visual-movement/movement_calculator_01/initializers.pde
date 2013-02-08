
// compile a bunch of png paths from given directory
void initPngs ()
{
    //silhouetteFolder = "/Users/fjenett/Desktop/silhouettes";
    silhouetteFolder = "/Volumes/Verytim/2011_FIGD_April_Results/"+sessions[currentSession]+"_withBackgroundAdjustment_Corrected/Images_BackgroundSubstracted/CamCenter";
    
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

