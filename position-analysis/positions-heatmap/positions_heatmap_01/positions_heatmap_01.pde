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
final boolean isLocal = true;
final String TRACK_3D_ROOT = ( isLocal ? "http://moba-lab.local/" : "http://lab.motionbank.org/" ) + "dhay/data";
final String performer = null; // "Ros" or null for all

PieceMakerApi api;
boolean loaded = false, doAverage = true, exportAll = false, showAll = true, showGrouped = false;
String loadingMessage = "Loading piece";
int groupsLoading = 0, colorMode = 1;

VideoEventGroup[] groups;
int currentGroup = 0;
int currentHeatMap;

int heatMapSize = 400;
int heatMapGrid = 28;

static HashMap<String,Integer> moBaColors, moBaColorsHigh, moBaColorsLow; 
static {
    moBaColors     = new HashMap();
    moBaColorsLow  = new HashMap();
    
    moBaColors.put(     "Ros", 0xFF1E8ED4 );       // blue, ros
    moBaColorsLow.put(  "Ros", 0xFF254966 );
    
    moBaColors.put(     "Janine", 0xFFE04646 ); // red, jeanine 
    moBaColorsLow.put(  "Janine", 0xFF803B3B );
    
    moBaColors.put(     "Juliette", 0xFF349C00 );   // green, juliette
    moBaColorsLow.put(  "Juliette", 0xFF2B6100 );
    
    moBaColors.put( null, 0xFFDEDEDE );             // gray, all
    moBaColors.put( "background", 0xFFEDEDED );     
}

Date timeMin, timeMax;

void setup () 
{
    size( 1000, 700 );
    heatMapSize = (int)((height / 14.0) * 12);
    
    groups = new VideoEventGroup[0];

    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", 
                             isLocal ? "http://localhost:3000" : "http://notimetofly.herokuapp.com" );
    loadingMessage = "Loading videos for piece";
    api.loadVideosForPiece( PIECE_ID, api.createCallback("videosLoaded") );
}

String currentPerformer = null;

void draw ()
{
    background( moBaColors.get("background") );

    if ( loaded )
    {
        currentPerformer = performer;
            
        if ( groups[currentGroup] != null )
        {
            String name = null;
            
            String t = groups[currentGroup].heatMaps[currentHeatMap].scene.getTitle();
            t = t.replaceAll("[^-a-zA-Z0-9]+", "-");
            
            String recording = "";
            if ( !showAll || showGrouped )
            {
                recording = groups[currentGroup].video.getTitle().split("_")[0];
                int sub = int( recording.substring(2,3) );
                if ( sub < 2 ) currentPerformer = "Ros";
                else if ( sub < 4 ) currentPerformer = "Juliette";
                else currentPerformer = "Janine";
            }
            name = "output/" + (showAll && !showGrouped ? (performer == null ? "all" : performer) : recording) + (showGrouped ? "" : "_" + t);
            
            if ( exportAll ) 
            {
                //beginRecord( PDF, name + ".pdf" );
            }
            
            if ( showAll ) 
            {
                // across one scene in all groups
                if ( !showGrouped )
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
                } else {
                    groups[currentGroup].groupHeatMap.draw(
                        width/2-(heatMapSize/2), 
                        height/2-(heatMapSize/2), 
                        heatMapSize, 
                        heatMapSize
                    );
                }
                
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
                //endRecord();
                saveFrame( name + ".png" );
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
    fill( moBaColors.get(null) );
    rect( xx+cellWidth, yy+cellHeight, ww-2*cellWidth, hh-2*cellHeight );
    
    PGraphics pg = createGraphics( width, height );
    pg.beginDraw();
    pg.background( 255 );
    
    pg.noStroke();
    
    for ( int ix = 0; ix < resolution; ix++ )
    {
        for ( int iy = 0; iy < resolution; iy++ )
        {
            val = values[ix + iy*resolution];
            
            int c = (int)((val / valueMax) * 255);
            
            if ( colorMode == 1 )
            {
                c = (int)((colors.indexOf(val) / (float)colors.size()) * 255);
            }
            
            pg.fill( 255 - c );
                
            pg.rect( xx + ix*cellWidth, yy + (hh - cellHeight - iy*cellHeight), cellWidth, cellHeight );
        }
    }
    
    if ( doAverage ) {
        pg.filter( BLUR, 15 );
        pg.filter( POSTERIZE, 7 );
    }
    
    pg.endDraw();
    
    if ( currentPerformer != null ) 
    {
        pg.loadPixels();
        
        int col = moBaColors.get(currentPerformer);
        
        for ( int i = 0; i < pg.pixels.length; i++ )
        {
            if ( pg.pixels[i] != 0xFFFFFFFF ) 
            {
                float s = (pg.pixels[i] & 0xFF) / 255.0;
                pg.pixels[i] = lerpColor( col, 0xFFFFFFFF, s );
            }
        }
        
        pg.updatePixels();
    }
    
    blendMode( MULTIPLY );
    image( pg, 0, 0 );
    
    blendMode( BLEND );
}
