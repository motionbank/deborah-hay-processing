/** 
 *    Java implementation of the App ...
 */

import processing.core.*;

import org.piecemaker.api.*;
import org.piecemaker.models.*;
import org.piecemaker.collections.*;

public class App
{
    PieceMakerApi api;
    PApplet papplet;

    Piece piece;

    App ( PApplet sketch )
    {
        papplet = sketch;

        api = new PieceMakerApi( sketch, "aoisduaosiduasoidu", "http://localhost:3000" );
        api.loadPieces( api.createCallback( this, "piecesLoaded" ) );
    }

    public void piecesLoaded ( Pieces pieces )
    {
        for ( Piece p : pieces.pieces )
        {
            if ( p.getTitle().startsWith("No time") )
            {
                piece = p;
                api.loadVideosForPiece( p.id, api.createCallback( this, "videosLoaded" ) );
                return;
            }
        }
    }

    public void videosLoaded ( Videos videos )
    {
        // TODO: make video selectable

        int videoId = 100;

        api.loadVideo( videoId, api.createCallback( this, "videoLoaded" ) );
    }

    public void videoLoaded ( Video video )
    {
        api.loadEventsForVideo( video.id, api.createCallback( this, "eventsLoaded" ) );
    }

    public void eventsLoaded ( Events events )
    {
        Event dataEvent = null;

        for ( Event e : events.events )
        {
            if ( e.getEventType().equals("data") )
            {
                dataEvent = e;
                break;
            }
        }
        if ( dataEvent != null )
        {
            // we know this is a flat JSON string, so let's parse by hand:

            String[] attribs = dataEvent.getDescription().split( "," );
            for ( String a : attribs )
            {
                if ( a.indexOf( "file:" ) != -1 )
                {
                    String file = a.substring( a.indexOf("file:")+5 ).replace("\"", "");
                    loadEventData( dataEvent, file.replace(".txt", "_25fps.txt") );
                    //                    loadEventData( dataEvent, file.replace(".txt","_alt.txt") );
                    //                    loadEventData( dataEvent, file.replace(".txt","_left_wrist.txt") );
                    loadEventData( dataEvent, file.replace(".txt", "_CofM.txt") );
                    break;
                }
            }
        }
    }

    private void loadEventData ( Event dataEvent, String file )
    {
        String[] lines = papplet.loadStrings( "http://moba-lab.local/dhay/data/"+file );
        float[][] trackData = new float[lines.length][3];

        for ( int l = 0; l < lines.length; l++ )
        {
            String line = lines[l];
            String[] vals = line.split( " " );
            trackData[l][0] = Float.parseFloat( vals[0] );
            trackData[l][1] = Float.parseFloat( vals[1] );
            trackData[l][2] = Float.parseFloat( vals[2] );
        }

        api.createCallback( papplet, "setData", trackData ).call();
    }
}

