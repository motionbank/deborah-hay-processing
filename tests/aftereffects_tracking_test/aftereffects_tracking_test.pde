/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Drawing the track data generated and exported from After Effects tracker
 *
 *    P2.0
 *    updated: fjenett 20130209
 */
 
import java.util.regex.*;

void setup ()
{
    size( 1920, 1280 );

    background( 255 );
    
    Pattern patt = Pattern.compile("^\t([0-9]+)\t([0-9.]+)\t([0-9.]+).*$");
    
    stroke( 255, 0, 0 );
    beginShape();
    String[] lines = loadStrings("track.txt");
    for ( String l : lines )
    {
        if ( l.startsWith("\t") )
        {
            Matcher m = patt.matcher(l);
            if ( m.matches() )
            {
                float[] pieces = float(l.split("\t"));
                vertex( pieces[2],pieces[3] );
            }
        }
    }
    endShape();
    
    saveFrame("docu/####.jpg");    
}
