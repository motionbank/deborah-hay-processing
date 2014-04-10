/** 
 *    Java implementation of the App ...
 */

import processing.core.*;
import java.util.Calendar;

import org.piecemaker2.api.*;
import org.piecemaker2.models.*;

public class App
{
    PieceMakerApi api;
    PApplet papplet;

    Group piece;

    App ( PApplet sketch )
    {
        papplet = sketch;

        api = new PieceMakerApi( sketch, 
                                 "http://deborah-hay-pm2.herokuapp.com", 
                                 "0310X9kgAiTWuMIt" );
        
        api.getGroup( 24, api.createCallback( this, "groupLoaded" ) );
    }
    
    public void groupLoaded ( Group p )
    {
        piece = p;
        api.listEventsOfType( p.id, "video", api.createCallback( this, "videosLoaded", p.id ) );
    }
    
    public void videosLoaded ( Event[] videos, int groupId )
    {
        // TODO: interface to select video
        
        api.getEvent( groupId, 69322, api.createCallback( this, "videoLoaded", groupId ) );
    }

    public void videoLoaded ( Event video, int groupId )
    {
        Calendar cal = Calendar.getInstance();
        cal.setTime(video.utc_timestamp);
        cal.add(Calendar.MILLISECOND,(int)(video.duration*1000.0));
        
        api.listEventsForTimespan( groupId, 
                               video.utc_timestamp, 
                               cal.getTime(),
                               api.CONTAINED,
                               api.createCallback( this, "eventsLoaded" ) );
    }

    public void eventsLoaded ( Event[] events )
    {
        Event dataEvent = null;

        for ( Event e : events )
        {
            if ( e.type.equals("data") )
            {
                dataEvent = e;
                break;
            }
        }
        
        if ( dataEvent != null )
        {
            // we know this is a flat JSON string, so let's parse by hand:
            
            String file = dataEvent.fields.get("data-file").toString();
            
            //loadEventData( dataEvent, file );
            //                    loadEventData( dataEvent, file.replace(".txt","_alt.txt") );
            //                    loadEventData( dataEvent, file.replace(".txt","_left_wrist.txt") );
            
            loadEventData( dataEvent, file.replace(".txt", "_com.txt") );
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

