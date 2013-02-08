/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Generating a vector field that will allow to generate new paths based 
 *    on paths taken by Ros / Jeanine / Juliette
 *
 *    P-2.0
 *    created: fjenett 20130205
 */

import org.piecemaker.collections.*;
import org.piecemaker.models.*;
import org.piecemaker.api.*;

import java.util.Date;

PieceMakerApi api;
Piece piece;
Video[] videos;
org.piecemaker.models.Event[] events;

ArrayList<VideoTimeCluster> clusters;
long clustersTimeMin = Long.MAX_VALUE, clustersTimeMax = Long.MIN_VALUE;

ArrayList<String> trackFiles;

static String tracksBaseUrl = "http://lab.motionbank.org/dhay/data/";
static {
    tracksBaseUrl = "/Users/fjenett/Desktop/MOBA/IGD_Positions/";
}

int fieldGrid = 40;
int[][] fieldCount;
PVector[] field;
int[] fieldCounts;
int fieldWidth, fieldHeight;

boolean loading = true;
String loadingMessage = "Loading pieces ...";

boolean showBackground = false, showField = true;

ArrayList<Mover> movers;

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
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
}

boolean clustersBusy = false;

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
        
        if ( showBackground )
        {
            if ( showField ) 
            {
                float cellWidth = (width-0.0) / fieldWidth;
                float cellHeight = (height-0.0) / fieldHeight;
                
                for ( int i = 0; i < field.length; i++ )
                {
                    int fx = i % fieldWidth;
                    int fy = i / fieldWidth;
                    
                    PVector p = field[i];
                    
                    stroke( 0 );
                    colorMode( HSB );
                    if ( fieldCounts[i] > 0 ) {
                        fill( map( p.heading(), -PI, PI, 0, 255 ), 200, 200 );
                    } else {
                        fill( 0 );
                    }
                    colorMode( RGB );
                    
                    float px = fx*cellWidth;
                    float py = fy*cellHeight;
                    
                    rect( px, py, cellWidth, cellHeight );
                    
                    stroke( 255 );
                    noFill();
                    
                    line( px + cellWidth/2,                       py + cellHeight/2, 
                          px + cellWidth/2 + p.x * (cellWidth/2), py + cellHeight/2 + p.y * (cellWidth/2) );
                }
            
            } 
            else 
            {
                clustersBusy = true;
                for ( VideoTimeCluster c : clusters )
                {
                    stroke(0);
                    noFill();
                    beginShape();
                    for ( float[] position : c.track.trackData )
                    {
                        vertex( map( position[0], c.track.trackMin[0], c.track.trackMax[0], 0, width ), 
                                map( position[1], c.track.trackMin[1], c.track.trackMax[1], 0, width ) );
                    }
                    endShape();
                }
                clustersBusy = false;
            }
        }
        
        for ( Mover m : movers )
        {
            m.update();
            m.applyField( field, fieldWidth, fieldHeight );
            m.draw();
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
