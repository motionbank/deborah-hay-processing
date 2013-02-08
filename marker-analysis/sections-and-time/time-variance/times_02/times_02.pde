import org.yaml.snakeyaml.*;

import de.bezier.utils.*;
import de.bezier.data.sql.*;
import org.piecemaker.models.*;

import processing.pdf.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;

MySQL db;
SimpleDateFormat mysqlDateFormat;
Piece piece;

Date timeMin, timeMax;
int minTime = Integer.MAX_VALUE, 
    minTimeNormalized = Integer.MAX_VALUE, 
    maxTime = -1, 
    maxEvents = Integer.MIN_VALUE;

ArrayList<EventTitleCluster> titleClusters;
ArrayList<VideoTimeCluster> clusters;

int viewMode = 3;
boolean savePDF;

void setup () 
{
    size( 1000, 900 );
    
    initDatabase();
    loadMarkers();
    
    textFont( createFont( "Lato-Regular", 9 ) );
}

void draw ()
{
    background( 255 );
    
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

void keyPressed ()
{
    switch ( key )
    {
        case '1':
            viewMode = 0;
            break;
        case '2':
            viewMode = 1;
            break;
        case '3':
            viewMode = 2;
            break;
        case '4':
            viewMode = 3;
            break;
        case 'p':
            savePDF = true;
            break;
    }
}
