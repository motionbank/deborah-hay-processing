
import de.bezier.utils.*;

import org.piecemaker.models.*;
import org.piecemaker.api.*;
import org.piecemaker.collections.*;

import java.util.*;
import java.text.*;

import processing.pdf.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;

//MySQL db;
SimpleDateFormat mysqlDateFormat;
Piece piece;

Date timeMin, timeMax;
int minTime = Integer.MAX_VALUE, 
    minTimeNormalized = Integer.MAX_VALUE, 
    maxTime = -1, 
    maxEvents = Integer.MIN_VALUE;

PieceMakerApi api;
ArrayList<EventTitleCluster> titleClusters;
ArrayList<VideoTimeCluster> clusters;
 long recordingsFrom, recordingsTo;
 String loadingMessage = "Loading";
 boolean loading = true;

int viewMode = 3;
boolean savePDF;

void setup () 
{
    size( 1000, 900 );
    
    // limit recordings by date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    //cal.setTimeZone( java.util.TimeZone.getTimeZone("UTC") );
    cal.set(2011,3,18,0,0,0); // 3 == April
    recordingsFrom = cal.getTimeInMillis();
    cal.set(2011,3,19,0,0,0);
    recordingsTo = cal.getTimeInMillis();
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
    api.loadVideosForPiece( 3, api.createCallback( "videosLoaded", 3 ) );
    
    textFont( createFont( "Lato-Regular", 9 ) );
}

void draw ()
{
    background( 255 );
    
    if ( loading ) 
    {
        fill( 0 );
        text( loadingMessage, width/2, height/2 );
    }
    else
    {
        if ( savePDF )
        {
            beginRecord( PDF, Utils.makeDateTimeName( this ) + ".pdf" );
        }
        
        if ( viewMode < 2 )
        {
            float w = (width - 60.0) / clusters.size();
            
            int i = 0;
            String performer = null;
            
            for ( VideoTimeCluster c : clusters )
            {
                pushMatrix();
                translate( 10+i*w, 0 );
                
                pushMatrix();
                
                stroke( 240 );
                if ( performer == null )
                    performer = c.performer;
                else if ( !c.performer.equals(performer) )
                {
                    performer = c.performer;
                    stroke( 220 );
                }
                line( 0, 10, 0, height-10 );
                
                translate( 10, height-14 );
                rotate( -HALF_PI );
                fill( 220 );
                text( /*c.performer + "\n" +*/ c.videos.get(1).title, 0, 0 );
                
                popMatrix();
                
                popMatrix();
                
                i++;
            }
            
            for ( EventTitleCluster tc : titleClusters )
            {
                switch ( viewMode )
                {
                    case 0:
                        tc.draw( minTime, maxTime, 10, height-20 );
                        break;
                    case 1:
                        tc.drawNormalized( 10, height-20 );
                        break;
                }
            }
        }
        else
        {
            float w = (width-85.0) / titleClusters.size();
            int i = 0;
            for ( EventTitleCluster tc : titleClusters )
            {
                switch ( viewMode )
                {
                    case 2:
                        tc.drawBlob( minTime, maxTime, 10 + i*w, 10, w, height-20 );
                        break;
                    case 3:
                        tc.drawBlobNormalized( 10 + i*w, 10, w, height-20 );
                        break;
                }
                i++;
            }
        }
        
        if ( savePDF )
        {
            savePDF = false;
            endRecord();
        }
    }
}
