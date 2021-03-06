import org.piecemaker.api.*;
import org.piecemaker.models.*;
import org.piecemaker.collections.*;

import processing.pdf.*;

import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.Map;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;
final String FILE_3D_POS = "Tracked3DPosition.txt";
final String POS_3D_ROOT = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";

PieceMakerApi api;

Piece piece;
ArrayList<VideoTimeCluster> clusters;
long clustersTimeMin = Long.MAX_VALUE, clustersTimeMax = Long.MIN_VALUE;
boolean clustersBusy;
Video[] videos;

ArrayList<String> trackFiles;
static String tracksBaseUrl = "http://lab.motionbank.org/dhay/data/";
static {
    tracksBaseUrl = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
}

boolean loading = true;
String loadingMessage = "Loading";

Date timeMin, timeMax;
float[] speeds;
float[] gaussKernel; // = new float[]{0.006,0.061,0.242,0.383,0.242,0.061,0.006};

void setup () 
{
    size( 1000, 200 );
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
    
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
    
    if ( !loading )
    {
outer:
        clustersBusy = true;
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
                    fill( 0 );
                    noStroke();
                    
                    float sx = width / (float)speeds.length;
                    float sy = height / (maxSpeed - minSpeed);
                    for ( int x = 0; x < speeds.length; x++ )
                    {
                        float ll = (speeds[x] - minSpeed)*sy;
                        speeds2[(int)(x*sx)] += ll;
                    }
                    
                    String name = "saves/" + c.videos.get(0).title;
                    
                    beginRecord( PDF, name + ".pdf" );
                    
                    beginShape();
                    for ( int x = 0; x < speeds2.length; x++ )
                    {
                        speeds2[x] = (speeds2[x]/speeds.length) * 10;
                        
                        //line( x, height - speeds2[x]*1000, x, height );
                        vertex( x, height - speeds2[x]*1000 );
                    }
                    endShape();
                    
                    endRecord();
                    
                    saveFrame( name + ".png" );
                    
                    name = name + "_gauss" ;
                    
                    background( 255 );
                    
                    beginRecord( PDF, name + ".pdf" );
                    
                    for ( int t = 0; t < 5; t++ )
                        speeds2 = convolve1D( speeds2, gaussKernel );
                    
                    beginShape();
                    for ( int x = 0; x < speeds2.length; x++ )
                    {
                        //line( x, height - speeds2[x], x, height );
                        vertex( x, height - speeds2[x] );
                    }
                    endShape();
                    
                    endRecord();
                    
                    saveFrame( name + ".png" );
                    
                    //break outer;
                }
            }
        }
        clustersBusy = false;
        exit();
    } else {
        fill( 0 );
        text( loadingMessage, 20, 40 );
    }
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
