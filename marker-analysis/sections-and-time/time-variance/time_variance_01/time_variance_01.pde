/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Discuss here:
 *    http://ws.motionbank.org/project/time-variance-markers
 *
 *    P2.0
 *    updated: fjenett 20130209
 */
 
import de.bezier.utils.*;

import org.piecemaker.models.*;
import org.piecemaker.api.*;
import org.piecemaker.collections.*;

import java.util.*;
import java.text.*;

import processing.pdf.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;

static HashMap<String,Integer> moBaColors, moBaColorsHigh, moBaColorsLow; 
static {
    moBaColorsHigh = new HashMap();
    moBaColorsLow = new HashMap();
    
    moBaColorsHigh.put( "Ros", 0xFF1E8ED4 );
    moBaColorsLow.put(  "Ros", 0xFF254966 );
    
    moBaColorsHigh.put( "Janine", 0xFFE04646 );
    moBaColorsLow.put(  "Janine", 0xFF803B3B );
    
    moBaColorsHigh.put( "Juliette", 0xFF349C00 );
    moBaColorsLow.put(  "Juliette", 0xFF2B6100 );
}

float moBaOpacity = 64;
float strokeWeight = 1.5;

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

int viewMode = 1;
boolean savePDF;
int clustersExpected = 0;
int displayColumn = 0;

void setup () 
{
    size( 1000, 900 );
    
    // limit recordings by date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    //cal.setTimeZone( java.util.TimeZone.getTimeZone("UTC") );
    cal.set(2011,3,18,0,0,0); // 3 == April
    recordingsFrom = cal.getTimeInMillis();
    cal.set(2011,3,26,0,0,0);
    recordingsTo = cal.getTimeInMillis();
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", 
                             false ? "http://localhost:3000" : "http://notimetofly.herokuapp.com/" );
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
            beginRecord( PDF, "output" + File.separator + Utils.makeDateTimeName( this ) + ".pdf" );
        }
        
        if ( viewMode < 2 )
        {
            float w = (width - 100.0) / (clusters.size()-1);
            
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
                        text( /*c.performer + "\n" +*/ c.videos.get(0).title, 0, 0 );
                        
                    popMatrix();
                
                popMatrix();
                
                i++;
            }
            
            for ( int tc = 0; tc < titleClusters.size()-1; tc++ )
            {
                EventTitleCluster tc1 = titleClusters.get(tc);
                EventTitleCluster tc2 = titleClusters.get(tc+1);
                
                switch ( viewMode )
                {
                    case 0:
                        for ( int si = 0; si < tc1.segments.length && si < tc2.segments.length; si++ )
                        {
                            float[] seg1 = tc1.segments[si];
                            float[] seg2 = tc2.segments[si];
                            if ( seg1 != null && seg2 != null )
                            {
                                fill( 0, 15 );
                                beginShape();
                                vertex(seg1[0],seg1[1]);
                                vertex(seg1[2],seg1[3]);
                                vertex(seg2[2],seg2[3]);
                                vertex(seg2[0],seg2[1]);
                                endShape();
                            }
                        }
                        break;
                    case 1:
                        for ( int si = 0; si < tc1.segmentsNormalized.length && si < tc2.segmentsNormalized.length; si++ )
                        {
                            float[] seg1 = tc1.segmentsNormalized[si];
                            float[] seg2 = tc2.segmentsNormalized[si];
                            if ( seg1 != null && seg2 != null )
                            {
                                fill( 0, 15 );
                                beginShape();
                                vertex(seg1[0],seg1[1]);
                                vertex(seg1[2],seg1[3]);
                                vertex(seg2[2],seg2[3]);
                                vertex(seg2[0],seg2[1]);
                                endShape();
                            }
                        }
                        break;
                }
            }
            
            for ( EventTitleCluster tc : titleClusters )
            {
                switch ( viewMode )
                {
                    case 0:
                        tc.draw();
                        break;
                    case 1:
                        tc.drawNormalized();
                        break;
                }
            }
        }
        else // viewmode > 2
        {
            float w = (width-100.0) / titleClusters.size();
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
