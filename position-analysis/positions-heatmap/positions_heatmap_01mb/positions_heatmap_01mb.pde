/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Processing 2.0
 *    created fjenett 2012 ??
 */

import org.piecemaker.api.*;
import org.piecemaker.models.*;
import org.piecemaker.collections.*;

import java.util.Date;
import java.util.Map;
import java.text.SimpleDateFormat;

final int PIECE_ID = 3;
final boolean isLocal = false;
final String TRACK_3D_ROOT = (isLocal ? "http://moba-lab.local/" : "http://lab.motionbank.org/") + "dhay/data";
final String performer = "Ros";
final boolean mbLocal = true;
String LOCAL_DATA_PATH = "/Users/mbaer/Documents/_Gestaltung/__Current/motionbank/_data/";
String POSITION_DATA_DIR = "paths/";
String POSITION_DATA_FILE = "_withBackgroundAdjustment_Corrected/Tracked3DPosition_com.txt";

PieceMakerApi api;
boolean loaded = false, doAverage = true, exportAll = true, showAll = true;
String loadingMessage = "Loading piece";
int groupsLoading = 0, colorMode = 1;

VideoEventGroup[] groups;
int currentGroup = 0;
int currentHeatMap;

int heatMapSize = 400;
int heatMapGrid = 28;

Date timeMin, timeMax;

void setup () 
{
    size( 640, 640 );
    
    groups = new VideoEventGroup[0];

    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", 
                             isLocal ? "http://localhost:3000" : "http://notimetofly.herokuapp.com" );
    loadingMessage = "Loading videos for piece";
    api.loadVideosForPiece( PIECE_ID, api.createCallback("videosLoaded") );
}

void draw ()
{
    background( 255 );

    if ( loaded )
    {
        if ( groups[currentGroup] != null )
        {
            if ( showAll ) 
            {
                float[] values = new float[heatMapGrid*heatMapGrid];
                int groupsTotal = 0;
                for ( VideoEventGroup g : groups )
                {
                    if ( currentHeatMap < g.heatMaps.length && g.heatMaps[currentHeatMap] != null )
                    {
                        for ( int i = 0; i < values.length; i++ )
                        {
                            values[i] += g.heatMaps[currentHeatMap].values[i];
                        }
                        groupsTotal++;
                    }
                }
                float valueMax = -1;
                for ( int i = 0; groupsTotal > 0 && i < values.length; i++ )
                {
                    values[i] /= groupsTotal;
                    valueMax = max( valueMax, values[i] );
                }
                drawHeatMap(
                    values, valueMax, heatMapGrid,
                    width/2-(heatMapSize/2), 
                    height/2-(heatMapSize/2), 
                    heatMapSize, 
                    heatMapSize 
                );
                if ( !exportAll )
                {
                    fill( 0 );
                    text( groups[currentGroup].heatMaps[currentHeatMap].scene.getTitle(), 
                          width/2-(heatMapSize/2)-2, 
                          height/2-(heatMapSize/2)+heatMapSize+14
                    );
                }
            }
            else
            {
                groups[currentGroup].heatMaps[currentHeatMap].draw( 
                    width/2-(heatMapSize/2), 
                    height/2-(heatMapSize/2), 
                    heatMapSize, 
                    heatMapSize 
                );
                
                if ( !exportAll )
                {
                    fill( 0 );
                    text( groups[currentGroup].video.getTitle(), 5, 15 );
                    text( groups[currentGroup].heatMaps[currentHeatMap].scene.getTitle(), 
                          width/2-(heatMapSize/2)-2, 
                          height/2-(heatMapSize/2)+heatMapSize+14
                    );
                }
            }
            
            if ( exportAll ) 
            {
                String t = groups[currentGroup].heatMaps[currentHeatMap].scene.getTitle();
                String recording = "";
                if ( !showAll )
                {
                    recording = groups[currentGroup].video.getTitle().split("_")[0];
                }
                saveFrame( "output/" + (showAll ? (performer == null ? "all" : performer) : recording) + "_" + t.replaceAll("[^-a-zA-Z0-9]+", "-")  + ".png" );
                nextHeatMap();
            }
        }
    }
    else
    {
        fill( 0 );
        text( loadingMessage, 20, 20 );
    }
}

void drawHeatMap ( float[] values, float valueMax, int resolution, int xx, int yy, int ww, int hh )
{
    ArrayList colors = null;
    if ( colorMode == 1 )
    {
        colors = new ArrayList();
        for ( int i = 0; i < values.length; i++ )
        {
            if (colors.indexOf(values[i]) == -1) colors.add(values[i]);
        }
        java.util.Collections.sort(colors);
    }
    
    
    float cellWidth  = ww / (float)resolution;
    float cellHeight = hh / (float)resolution;
    float val;
    
    noStroke();
    
    for ( int ix = 0; ix < resolution; ix++ )
    {
        for ( int iy = 0; iy < resolution; iy++ )
        {
            val = values[ix + iy*resolution];
            
            int c = 255 - (int)((val / valueMax) * 255);
            if ( colorMode == 1 )
            {
                c = 255 - (int)((colors.indexOf(val) / (float)colors.size()) * 255);
            }
            fill( c );
            
//            if ( val == 0 )
//                stroke( 200 );
//            else
//                stroke( 0, 150, 255 );
                
//            if ( ix == valueMaxX && iy == valueMaxY )
//                stroke( 255, 0, 0 );
                
            rect( xx + ix*cellWidth, yy + iy*cellHeight, cellWidth, cellHeight );
        }
    }
    
    if ( doAverage ) {
        filter( BLUR, 10 );
        filter( POSTERIZE, 10 );
    }
    
    fill( 0, 15 );
    rect( xx+cellWidth, yy+cellHeight, ww-2*cellWidth, hh-2*cellHeight );
}
