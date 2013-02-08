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

//ArrayList<EventTitleCluster> titleClusters;
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
