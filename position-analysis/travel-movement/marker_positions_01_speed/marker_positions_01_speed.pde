import org.yaml.snakeyaml.*;
import org.json.*;
import de.bezier.data.sql.*;
import org.piecemaker.models.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;
final String FILE_3D_POS = "Tracked3DPosition.txt";
final String POS_3D_ROOT = "/Users/fjenett/Desktop/IGD_Positions/";

MySQL db;
Piece piece;
ArrayList<VideoTimeCluster> clusters;

Date timeMin, timeMax;
float[] speeds;

void setup () 
{
    size( 1000, 200 );
    
    initDatabase();
    loadMarkers();
}

void draw ()
{
    background( 255 );
    noFill();
    
outer:
    for ( VideoTimeCluster c : clusters ) 
    {
        println( c.toString() );
        
        for ( Event e : c.events ) 
        {
            float minSpeed = Float.MAX_VALUE;
            float maxSpeed = Float.MIN_VALUE;
    
            if ( e.getEventType().equals("data") )
            {
                String[] lines = loadStrings( POS_3D_ROOT + getEventData( "file", e.description ) );
                
                float s = height/13.0;
                float xl = -1, yl = -1;
                speeds = new float[lines.length];
                int i = 0;
                
                for ( String l : lines )
                {
                    float[] vals = float(l.split(" "));
                    if ( vals[0] == 0 && vals[1] == 0 ) continue;
                    float x = vals[0]*s;
                    float y = height - (vals[1]*s);
                    
                    if ( xl != -1 && yl != -1 )
                    {
                        float d = dist( x, y, xl, yl );
                        minSpeed = min( minSpeed, d );
                        maxSpeed = max( maxSpeed, d );
                        speeds[i] = d;
                    }
                    
                    xl = x;
                    yl = y;
                    i++;
                }
                
                maxSpeed = 18;
                
                background( 255 );
                stroke( 0 );
                
                float h = 5000;
                float sx = width / (float)speeds.length;
                float sy = height / (maxSpeed - minSpeed);
                for ( int x = 0; x < speeds.length; x++ )
                {
                    float ll = (speeds[x] - minSpeed)*sy;
                    line( x*sx, height - ll, x*sx, height );
                    
                    // KDE
                    /*float v = 0;
                    for ( float d : speeds )
                    {
                        d = (d - minSpeed)*sy;
                        
                        v += (1/h) * guassianKernel( (ll - d) / h );
                    }
                    ll = v*5000;
                    
                    line( x*sx, height - ll, x*sx, height );
                    
                    println( (float(x)/speeds.length) * 100 );*/
                }
                             
                saveFrame( c.videos.get(0).title + ".png" );
                
                break outer;
            }
        }
    }
    
    noLoop();
}

float guassianKernel ( float v )
 {
 return (1.0 / sqrt(TWO_PI)) * exp( -0.5 * (v*v) );
 }

String getEventData( String attr, String rawJson )
{
    try {
        JSONObject json = new JSONObject( rawJson );
        return json.get(attr).toString();
    } catch ( Exception e ) {
    }
    return null;
}
