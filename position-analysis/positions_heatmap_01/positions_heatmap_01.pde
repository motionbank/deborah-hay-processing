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
final String TRACK_3D_ROOT = (isLocal ? "http://moba-lab.local/" : "http://lab.motionbank.org/") + "dhay/data";

PieceMakerApi api;
boolean loaded = false;
String loadingMessage = "Loading piece";
int groupsLoading = 0;

VideoEventGroup[] groups;
int currentGroup = 0;
int currentHeatMap;

Date timeMin, timeMax;

void setup () 
{
    size( 1200, 900 );
    
    groups = new VideoEventGroup[0];

    api = new PieceMakerApi(this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", isLocal ? "http://localhost:3000" : "http://notimetofly.herokuapp.com" );
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
            fill( 0 );
            text( groups[currentGroup].video.getTitle(), 5, 15 );
            
            groups[currentGroup].heatMaps[currentHeatMap].draw( 5, 25, 200, 200 );
        }
    }
    else
    {
        fill( 0 );
        text( loadingMessage, 20, 20 );
    }
}
