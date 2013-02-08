/**
 *    Motion Bank
 *    Getting started with analyzing the marker data in Piecemaker.
 *
 *    florian@motionbank.org - 2011-04, 2011-07, 2012-02
 */

import de.bezier.data.sql.*;
import de.bezier.gui.*;
import processing.video.*;
import org.piecemaker.models.*;

MySQL db;

Event[] events;
Piece[] pieces;
User[] users;

Movie movie;
String videoDir = "/Volumes/Elements/piecemaker_april_session_solos";

Piece currentPiece;
int currentPieceIndex = 0;
GuiList currentVideoList;
GuiMultiSlider slider;

DateFormat df;
boolean selectionMode = true;
boolean waitingForPosterFrame = false, havePosterFrameDoPause = false;

void setup ()
{
    size( 800, 600 );
    
    File f = new File( videoDir );
    if ( !f.exists() )
    {
        videoDir = "/Users/fjenett/Repos/piecemaker/public/video/full";
    }
    
    df = DateFormat.getDateTimeInstance( DateFormat.SHORT, DateFormat.SHORT );
    
    initData();
    initScene();
    initGui();
}

void draw ()
{
    if ( movie != null && movie.ready() )
    {
        image( movie, 0,0, width,height );
        if ( havePosterFrameDoPause )
        {
            movie.pause();
            havePosterFrameDoPause = false;
        }
    
        drawMarkers();
    }
}

void drawMarkers ()
{
    int iy = height-10-30-10-10;
    Event[] videoEvents = getSortedEventsForVideo(selectedVideocurrentPiece.);
    if ( videoEvents != null && videoEvents.length > 0 )
    {
        Date from = vicurrentPiece.deoEvents[0].createdAt;
        long[] eventDiffs = new long[0];
        
        long total = (long)movie.duration()*1000;
        HashMap<User,Event[]> userEvents = getSortedUsercurrentPiece.EventsForVideo(selectedVideocurrentPiece.);
        for ( Map.Entry e : userEvents.entrySet() )
        {
            User u = (User)e.getKey();
            Event[] es = (Event[])e.getValue();
            fill( 255 );
            text( u.name + " " + es.length, 10, iy+13 );
            fill( 0 );
            Arrays.sort( es );
            long l;
            for ( Event ee : es )
            {
                l = millisecDifference(
                                   currentPiece.selectedVideo.recordedAt,
                                   ee.createdAt
                               );
                eventDiffs = (long[])append(eventDiffs, l);
                float x = map( l,
                               0,total,
                               0,slider.size().x-10 );
                
                noStroke();
                
                if ( ee.title.equals("start") )
                    stroke( 255, 0, 0 );
                else if ( ee.title.equals("end") )
                    stroke( 0, 0, 255 );
                else
                    stroke( 255 );
                line( (int)(slider.position().x+5+x), iy,
                      (int)(slider.position().x+5+x), iy+20 );
            }
            iy -= 30;
        }

        // draw current time
        
        int tx = 0;
        Date vDate = currentPiece.selectedVideo.recordedAt;
        Calendar cal = GregorianCalendar.getInstance();
        cal.setTime( vDate );
        cal.add( Calendar.MILLISECOND, (int)(movie.time()*1000) );
        Date now = cal.getTime();
        long diff = millisecDifference(vDate, now);
        
        int sec = (int)diff / 1000;
        int min = sec / 60;
        sec %= 60;
        
        slider.setLabel( nf(min,2) + ":" + nf(sec,2) );
        
        //println( vDate + " | " + from + " | " + now );
        //if ( now.getTime() > from.getTime() ) {
            float x = map(diff, 0,total, 0,slider.size().x-10);
            stroke(255);
            line( slider.position().x+x+5, height-40-userEvents.size()*30-60, 
                  slider.position().x+x+5, height-40 );
        //}
        
        // KDE
        
        float h = 5000, mx = 0;
        int u = userEvents.size();
        float[] vals = new float[(int)(slider.size().x-10)];
        for ( int i = 0, k = vals.length; i < k; i++ )
        {
            float vv = map( i, 0,vals.length, 0,total );
            float v = 0;
            for ( long d : eventDiffs )
            {
                v += (1/h) * guassianKernel( (vv - d) / h );
            }
            vals[i] = v*500000;
            mx = max( mx, vals[i] );
        }
        stroke(255,255,0); fill(255,120);
        beginShape();
        for ( int i = 0, xx = (int)(slider.position().x+5); i < vals.length; i++ )
        {
            vertex( xx+i, height-30-userEvents.size()*30 - 10 - (vals[i]/mx) * 60 );
        }
        endShape();
    }
}

 float guassianKernel ( float v )
 {
     return (1.0 / sqrt(TWO_PI)) * exp( -0.5 * (v*v) );
 }

void movieEvent( Movie mov ) 
{
    mov.read();
    if ( !playing && waitingForPosterFrame && mov == movie )
    {
        waitingForPosterFrame = false;
        havePosterFrameDoPause = true;
    }
    else
        slider.setValue( 1, mov.time()/mov.duration() );
}

long millisecDifference ( Date from, Date to )
{
    return to.getTime() - from.getTime();
}

boolean playing = false;
void togglePlayPause ( GuiEvent evt )
{
    playing = !playing;
    if ( movie != null )
    {
        if ( playing ) movie.play();
        else movie.pause();
    }
}

void loadMovie ()
{
    String movieFile = videoDir + "/" + currentPiece.selectedVideo.filename + ".mp4";
    if ( new File(movieFile).exists() )
    {
        if ( movie != null )
        {
            movie.stop();
            movie.delete();
            movie = null;
        }
        movie = new Movie(this, movieFile );
        movie.play();
        waitingForPosterFrame = true;
        
        if ( slider != null ) slider.setValue( 1, 0 );
    }
    else
    {
        movie = null;
        System.err.println( "File not found:\n"+movieFile );
    }
}

void keyPressed ()
{
    togglePlayPause(null);
}
