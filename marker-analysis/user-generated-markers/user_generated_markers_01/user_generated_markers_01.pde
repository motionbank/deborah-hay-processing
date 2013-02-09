/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Getting started with analyzing the marker data in Piecemaker.
 *
 *    florian@motionbank.org - 2011-04, 2011-07, 2012-02
 */

// import de.bezier.data.sql.*;

import de.bezier.guido.*;

import org.piecemaker.models.*;
import org.piecemaker.api.*;
import org.piecemaker.collections.*;

import processing.video.*;

import java.util.*;
import java.text.*;

//MySQL db;

org.piecemaker.models.Event[] events;
Piece[] pieces;
User[] users;
org.piecemaker.models.Video selectedVideo = null;

Movie movie;
String videoDir = "/Volumes/Elements/piecemaker_april_session_solos";

Piece currentPiece;
int currentPieceIndex = 0;
//GuiList currentVideoList;
//GuiMultiSlider slider;

PieceMakerApi  api;
org.piecemaker.models.Video[] videos;
ArrayList<VideoTimeCluster> clusters;

DateFormat df;
long recordingsFrom, recordingsTo;
boolean selectionMode = true;
boolean waitingForPosterFrame = false, havePosterFrameDoPause = false;

boolean loading = true;
String loadingMessage = "Loading";
int clustersExpected = 0;

void setup ()
{
    size( 800, 600 );
    
    File f = new File( videoDir );
    if ( !f.exists() )
    {
        videoDir = "/Users/fjenett/Repos/piecemaker/public/video/full";
    }
    
    df = DateFormat.getDateTimeInstance( DateFormat.SHORT, DateFormat.SHORT );
    
    // limit recordings by date
    java.util.Calendar cal = java.util.Calendar.getInstance();
    //cal.setTimeZone( java.util.TimeZone.getTimeZone("UTC") );
    cal.set(2011,3,18,0,0,0); // 3 == April
    recordingsFrom = cal.getTimeInMillis();
    cal.set(2011,3,19,0,0,0);
    recordingsTo = cal.getTimeInMillis();
    
    api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://localhost:3000" );
    api.loadPieces( api.createCallback( "piecesLoaded" ) );
    
    initScene();
    //initGui();
}

void draw ()
{
    if ( loading )
    {
        background( 255 );
        fill( 0 );
        text( loadingMessage, width/2, height/2 );
    }
    else
    {
        if ( movie != null )
        {
            image( movie, 0,0, width,height );
            if ( havePosterFrameDoPause )
            {
                movie.pause();
                havePosterFrameDoPause = false;
            }
        }
        
        drawMarkers();
    }
}

void drawMarkers ()
{
    background( 255 );
    
    int iy = height-10-30-10-10;
    
    VideoTimeCluster currentCluster = clusters.get(0); // TODO: add interface for selecting this
    
    ArrayList<org.piecemaker.models.Event> videoEvents = currentCluster.events;
    
    if ( videoEvents != null && videoEvents.size() > 0 )
    {
        Date from = videoEvents.get(0).getCreatedAt();
        long[] eventDiffs = new long[0];
        
        long total = millisecDifference( currentCluster.from, currentCluster.to );
        HashMap<User,org.piecemaker.models.Event[]> userEvents = getSortedUserEventsForCluster( currentCluster );
        for ( Map.Entry e : userEvents.entrySet() )
        {
            String u = (String)e.getKey();
            org.piecemaker.models.Event[] es = (org.piecemaker.models.Event[])e.getValue();
            
            fill( 0 );
            text( u + " " + es.length, 10, iy+13 );
            fill( 0 );
            
            //Arrays.sort( es );
            long l;
            for ( org.piecemaker.models.Event ee : es )
            {
                l = millisecDifference( currentCluster.from, ee.getHappenedAt() );
                eventDiffs = (long[])append(eventDiffs, l);
                float x = map( l, 0, total, 10, width-10 ); // slider.size().x-10
                
                if ( ee.title.equals("start") )
                    stroke( 255, 0, 0 );
                else if ( ee.title.equals("end") )
                    stroke( 0, 0, 255 );
                else
                    stroke( 0 );
                
                //line( (int)(slider.position().x+5+x), iy, (int)(slider.position().x+5+x), iy+20 );
                line( x, iy, x, iy+2 );
            }
            
            stroke( 200 );
            line( 10, iy, width-10, iy );
            
            iy -= 30;
        }

        // draw current time
        
        int tx = 0;
//        Date vDate = currentPiece.selectedVideo.recordedAt;
//        Calendar cal = GregorianCalendar.getInstance();
//        cal.setTime( vDate );
//        cal.add( Calendar.MILLISECOND, (int)(movie.time()*1000) );
//        Date now = cal.getTime();
//        long diff = millisecDifference(vDate, now);
        
//        int sec = (int)diff / 1000;
//        int min = sec / 60;
//        sec %= 60;
//        
//        slider.setLabel( nf(min,2) + ":" + nf(sec,2) );
//        
//        //println( vDate + " | " + from + " | " + now );
//        //if ( now.getTime() > from.getTime() ) {
//            float x = map(diff, 0,total, 0,slider.size().x-10);
//            stroke(255);
//            line( slider.position().x+x+5, height-40-userEvents.size()*30-60, 
//                  slider.position().x+x+5, height-40 );
//        //}

        // KDE
        
        float h = 5000, mx = 0;
        int u = userEvents.size();
        float[] vals = new float[width-20]; // (int)(slider.size().x-10)
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
        stroke(100,100,0);
        fill(255,120);
        
        beginShape();
        for ( int i = 0, xx = 10; i < vals.length; i++ ) // (int)(slider.position().x+5)
        {
            vertex( xx+i, height-30-userEvents.size()*30 - 10 - (vals[i]/mx) * 60 );
        }
        endShape();
    }
}

HashMap getSortedUserEventsForCluster ( VideoTimeCluster c )
{
    HashMap<String, org.piecemaker.models.Event[]> userEvents = new HashMap();
    
    // make a list of users
    ArrayList<String> users = new ArrayList();
    for ( org.piecemaker.models.Event e : c.events )
    {
        String u = e.getCreatedBy();
        org.piecemaker.models.Event[] events = userEvents.get( u );
        if ( events == null )
        {
            events = new org.piecemaker.models.Event[0];
            userEvents.put( u, events );
        }
        
        events = (org.piecemaker.models.Event[])append( events, e );
        userEvents.put( u, events );
    }
    
    return userEvents;
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
//    else
//        slider.setValue( 1, mov.time()/mov.duration() );
}

long millisecDifference ( Date from, Date to )
{
    return to.getTime() - from.getTime();
}

boolean playing = false;
//void togglePlayPause ( GuiEvent evt )
//{
//    playing = !playing;
//    if ( movie != null )
//    {
//        if ( playing ) movie.play();
//        else movie.pause();
//    }
//}

void loadMovie ()
{
    String movieFile = videoDir + "/" + selectedVideo.title + ".mp4";
    if ( new File(movieFile).exists() )
    {
        if ( movie != null )
        {
            movie.stop();
            movie = null;
        }
        movie = new Movie(this, movieFile );
        movie.play();
        waitingForPosterFrame = true;
        
//        if ( slider != null ) slider.setValue( 1, 0 );
    }
    else
    {
        movie = null;
        System.err.println( "File not found:\n"+movieFile );
    }
}

void keyPressed ()
{
//    togglePlayPause(null);
}
