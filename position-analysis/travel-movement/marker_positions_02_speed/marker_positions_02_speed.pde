import org.yaml.snakeyaml.*;
import de.bezier.data.sql.*;
import org.piecemaker.models.*;

import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Map;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;
final String FILE_3D_POS = "Tracked3DPosition.txt";
final String POS_3D_ROOT = "/Users/fjenett/Desktop/MOBA/IGD_Positions/";

MySQL db;
Piece piece;
ArrayList<VideoTimeCluster> clusters;

Date timeMin, timeMax;
float[] speeds;
float[] gaussKernel; // = new float[]{0.006,0.061,0.242,0.383,0.242,0.061,0.006};

void setup () 
{
    size( 1000, 200 );
    
    initDatabase();
    loadMarkers();
    
    gaussKernel = new float[20*2+1];
    for ( int i = 0; i < gaussKernel.length; i++ )
    {
        float v = (i-(gaussKernel.length/2))/(gaussKernel.length/2.0) * 4;
        println( i + " " + v );
        gaussKernel[i] = guassianKernel( v );
    }
}

void draw ()
{
    background( 255 );
    noFill();
    
outer:
    for ( VideoTimeCluster c : clusters ) 
    {
        for ( org.piecemaker.models.Event e : c.events ) 
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
                
                float[] speeds2 = new float[width];
                
                background( 255 );
                stroke( 0 );
                
                float sx = width / (float)speeds.length;
                float sy = height / (maxSpeed - minSpeed);
                for ( int x = 0; x < speeds.length; x++ )
                {
                    float ll = (speeds[x] - minSpeed)*sy;
                    speeds2[(int)(x*sx)] += ll;
                }
                
                for ( int x = 0; x < speeds2.length; x++ )
                {
                    speeds2[x] = (speeds2[x]/speeds.length) * 10;
                    
                    line( x, height - speeds2[x]*1000, x, height );
                }
                
                saveFrame( c.videos.get(0).title + ".png" );
                
                background( 255 );
                
                for ( int t = 0; t < 5; t++ )
                    speeds2 = convolve1D( speeds2, gaussKernel );
                
                for ( int x = 0; x < speeds2.length; x++ )
                {
                    line( x, height - speeds2[x], x, height );
                }
                
                saveFrame( c.videos.get(0).title + "_gauss.png" );
                
                //break outer;
            }
        }
    }
    noLoop();
}

float guassianKernel ( float v )
{
    return (1.0 / sqrt(TWO_PI)) * exp( -0.5 * (v*v) );
}

float[] convolve1D ( float[] in, float[] kernel )
{
    int i, j, k;
    int dataSize = in.length;
    int kernelSize = kernel.length;
    float[] out = new float[dataSize];
    
    for ( i = 0; i < dataSize; i++ )
    {
        for ( j = 0; j < kernelSize; j++ )
        {
            k = j - kernelSize/2;
            if ( i+k >= 0 && i+k < dataSize )
                out[i] += in[i+k] * kernel[j];
        }
    }
    
//    for(i = kernelSize-1; i < dataSize; ++i)
//    {
//        out[i] = 0;
//
//        for(j = i, k = 0; k < kernelSize; --j, ++k)
//            out[i] += in[j] * kernel[k];
//    }
//
//    for(i = 0; i < kernelSize - 1; ++i)
//    {
//        out[i] = 0;
//
//        for(j = i, k = 0; j >= 0; --j, ++k)
//            out[i] += in[j] * kernel[k];
//    }
    
    return out;
}

String getEventData( String attr, String rawJson )
{
    try {
        org.json.JSONObject json = new org.json.JSONObject( rawJson );
        return json.get(attr).toString();
    } catch ( Exception e ) {
    }
    return null;
}
