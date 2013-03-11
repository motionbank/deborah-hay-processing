/**
 *    Motion Bank research, http://motionbank.org
 *
 *    Processing 2.0
 *    created: fjenett 20130311
 */

String comTrackBase = "/Users/fjenett/Desktop/comTrack2DCamLeft.txt";
String box2DTrackBase = "/Volumes/Verytim/2011_FIGD_April_Results/Janine_D06T04_withBackgroundAdjustment_Corrected/BoundingBox_CamLeft.txt";

void setup ()
{
    size( 500, 500 );

    for ( String cam : new String[]{"CamLeft", "CamRight"} )
    {
        String[] comTrack = loadStrings( comTrackBase.replace( "CamLeft", cam ) );
        String[] comTrackAbsolute = new String[comTrack.length];
        String[] b2DTrack = loadStrings( box2DTrackBase.replace( "CamLeft", cam ) );

        //     println( comTrack.length );
        //     println( b2DTrack.length );

        for ( int i = 0; i < comTrack.length; i++ )
        {
            String[] valsCom = comTrack[i].split(" "); // 25 fps
            String[] valsB2D = b2DTrack[i*2].split(" "); // 50 fps

            comTrackAbsolute[i] = (int(valsB2D[0]) + int(valsCom[0])) + " " + (int(valsB2D[1]) + int(valsCom[1]));
        }

        saveStrings( comTrackBase.replace( "CamLeft", cam ).replace(".txt", "_absolute.txt"), comTrackAbsolute );
    }
    
    exit();
}

