/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Generating a vector field that will allow to generate new paths based 
 *    on paths travelled by Ros / Jeanine / Juliette
 *
 *    Discuss here:
 *    http://ws.motionbank.org/project/performances-vector-field
 *
 *    P-2.0
 *    created: fjenett 20130222
 */

import org.piecemaker.collections.*;
import org.piecemaker.models.*;
import org.piecemaker.api.*;

import processing.pdf.*;

import java.util.Date;

// SETTINGS
// ===========================

PieceMakerApi api;
Piece piece;
Video[] videos;
org.piecemaker.models.Event[] events;

ArrayList<VideoTimeCluster> clusters;
long clustersTimeMin = Long.MAX_VALUE, clustersTimeMax = Long.MIN_VALUE;
long recordingsFrom, recordingsTo;

ArrayList<String> trackFiles;

static String tracksBaseUrl = "http://lab.motionbank.org/dhay/data/"; // http://moba-lab.local/dhay/data/
static {
    tracksBaseUrl = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
}

int fieldGrid = 10;
int[][] fieldCount;
PVector[] field;
int[] fieldCounts;
int fieldWidth, fieldHeight;
float fieldMax = 0, fieldMean = 0, fieldMin = Float.MAX_VALUE;
float fieldCountsMax = 0, fieldCountsMin = Float.MAX_VALUE;

boolean loading = true;
String loadingMessage = "Loading pieces ...";

boolean showBackground = false, showField = true;
boolean clustersBusy = false;

ArrayList<Mover> movers;

final static int MOVERS = 0;
final static int FIELD_COLORED = 1;
final static int FIELD_LINES = 2;
final static int PATHS = 3;
final static int INFORMATION = 4;
int drawMode = MOVERS;
boolean safePDF = false;
String saveName = "";

// SETUP & DRAW
// ===========================

void setup ()
{
    size( 900, 900 );
    
    movers = new ArrayList();
    
    fieldWidth = width / fieldGrid;
    fieldHeight = height / fieldGrid;
    field = new PVector[ fieldWidth * fieldHeight ];
    for ( int i = 0; i < field.length; i++ )
    {
        field[i] = new PVector(0,0);
    }
    fieldCounts = new int[field.length];
    
    setFromTo();
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
}

void draw ()
{
    if ( loading ) {
        drawLoading();
        return;
    }
    else
    {
        background( 255 );
        textAlign( LEFT );
        
        if ( safePDF )
        {
            updateSaveName();
            beginRecord( PDF, "output/pdf/"+saveName+".pdf" );
            
            fill( 0 );
            textSize( 6 );
            for ( int i = 0, k = clusters.size(); i < k; i++ )
            {
                text( clusters.get(i).toTitle(), 5, 10 + i*10 );
            }
        }
        
        switch ( drawMode )
        {
            case INFORMATION:
//        fill( 200 );
//        text( "Loaded piece \""+piece.title+"\": "+clusters.size()+" clusters", 10, 20 );
//        
//        stroke( 0 );
//        float y = 5;
//        clustersBusy = true;
//        for ( VideoTimeCluster c : clusters )
//        {
//            float xs = map( c.from.getTime(), clustersTimeMin, clustersTimeMax, 5, width-5 );
//            float xe = map( c.to.getTime(),   clustersTimeMin, clustersTimeMax, 5, width-5 );
//            
//            line( xs, y, xe, y );
//            
////            for ( org.piecemaker.models.Event e : c.events )
////            {
////                if ( e.getEventType().equals("data") 
////                {
////                    
////                }
////            }
//        }
//        clustersBusy = false;
                break;
            case FIELD_COLORED:
            case FIELD_LINES:
                
                boolean isColored = drawMode == FIELD_COLORED;
                
                float cellWidth = (width-0.0) / fieldWidth;
                float cellHeight = (height-0.0) / fieldHeight;
                
                for ( int i = 0; i < field.length; i++ )
                {
                    int fx = i % fieldWidth;
                    int fy = i / fieldWidth;
                    
                    PVector p = field[i].get();
                    
                    if ( isColored )
                    {
                        stroke( 0 );
                        colorMode( HSB );
                        if ( fieldCounts[i] > 0 ) {
                            fill( map( p.heading(), -PI, PI, 0, 255 ), 200, 200 );
                        } else {
                            fill( 0 );
                        }
                        colorMode( RGB );
                    }
                    
                    float px = fx*cellWidth;
                    float py = fy*cellHeight;
                    
                    if ( isColored )
                    {
                        rect( px, height-py-cellHeight, cellWidth, cellHeight );
                    }
                    
                    if ( !isColored )
                    {
                        stroke( 0 );
                    }
                    else
                    {
                        stroke( 255 );
                    }
                
                    p.normalize();
                    p.mult( cellWidth/2 );
                    
                    float pLen = p.mag();
                    
                    if ( pLen > 0 )
                    {
                        pushMatrix();
                        translate( px + cellWidth/2, height - (py + cellHeight/2) );
                        rotate( p.heading() );
                        line( 0, 0, pLen, 0 );
                        line( pLen, 0, pLen-(pLen/3), -(pLen/4) );
                        line( pLen, 0, pLen-(pLen/3),  (pLen/4) );
                        popMatrix();
                    }
                }
                break;
            case PATHS:
                clustersBusy = true;
                for ( VideoTimeCluster c : clusters )
                {
                    stroke(0);
                    noFill();
                    beginShape();
                    for ( float[] position : c.track.trackData )
                    {
                        vertex(        map( position[0], c.track.trackMin[0], c.track.trackMax[0], 0, width ), 
                                height-map( position[1], c.track.trackMin[1], c.track.trackMax[1], 0, width ) );
                    }
                    endShape();
                }
                clustersBusy = false;
                break;
            case MOVERS:
                for ( int i = 0, k = movers.size(); i < k; i++ )
                {
                    Mover m = movers.get(i);
                    m.update();
                    m.applyField( field, fieldWidth, fieldHeight );
                    //m.draw();
                }
                for ( int p = Mover.MAX_POSITIONS-1; p >= 1; p-- )
                {
                    for ( int i = 0, k = movers.size(); i < k; i++ )
                    {
                        movers.get(i).draw(p);
                    }
                }
                break;
        }
        
        if ( safePDF )
        {
            endRecord();
            saveFrame( "output/png/"+saveName+".png" );
            safePDF = false;
        }
    }
}

void drawLoading ()
{
    background( 255 );
    
    fill( 0 );
    textAlign( CENTER );
    text( loadingMessage, width/2, height/2 );
}

void updateSaveName ()
{
    saveName = year()+"-"+nf(month(),2)+"-"+nf(day(),2)+"_"+nf(hour(),2)+"-"+nf(minute(),2)+"-"+nf(second(),2);
}

void setFromTo ()
{
    // limit recordings by date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    //cal.setTimeZone( java.util.TimeZone.getTimeZone("UTC") );
    
    cal.set(2011,3,18,0,0,0); // 3 == April
    recordingsFrom = cal.getTimeInMillis();
    
    cal.set(2011,3,24,0,0,0);
    recordingsTo = cal.getTimeInMillis();
}
