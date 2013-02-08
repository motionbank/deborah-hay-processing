/**
 *    Motion Bank
 *    Getting started with analyzing the marker data in Piecemaker.
 *
 *    florian@motionbank.org - 2011-04-24
 */

import de.bezier.data.sql.*;
import controlP5.*;

ControlP5 cp5;

MySQL db;

Event[] events;
Piece[] pieces;
User[] users;

Piece currentPiece;
int currentPieceIndex = 0;

DateFormat df;
boolean selectionMode = true;

void setup ()
{
    size( 800, 600 );
    
    df = DateFormat.getDateTimeInstance( DateFormat.SHORT, DateFormat.SHORT );
    
    initData();
    initScene();
    smooth();
}

void draw ()
{
    background( 255 );
    
    if ( currentPiece != null )
    {
        fill( 0 );
        text( currentPiece.title + "    " + df.format(currentPiece.selectedVideo.recordedAt), 10, 20 );
            
        if ( selectionMode )
        {
            int ix = 35;
            for ( Video v : currentPiece.videos )
            {
                Event[] videoEvents = currentPiece.getSortedEventsForVideo(v);
                fill( currentPiece.selectedVideo == v ? 0xffff0000 : 0xff000000 );
                text( v.filename + "    " + videoEvents.length, 10, ix );
                ix += 15;
            }
        }
        else
        {
            int ix = 50;
            Event[] videoEvents = currentPiece.getSortedEventsForVideo(currentPiece.selectedVideo);
            if ( videoEvents != null && videoEvents.length > 0 )
            {
                Date from = videoEvents[0].createdAt;
                if ( from.getTime() < currentPiece.selectedVideo.recordedAt.getTime() )
                    from = currentPiece.selectedVideo.recordedAt;
                long total = millisecDifference(from, videoEvents[videoEvents.length-1].createdAt);
                HashMap<User,Event[]> userEvents = currentPiece.getSortedUserEventsForVideo(currentPiece.selectedVideo);
                for ( Map.Entry e : userEvents.entrySet() )
                {
                    User u = (User)e.getKey();
                    Event[] es = (Event[])e.getValue();
                    fill( 120 );
                    text( u.name, 10, ix );
                    textAlign(RIGHT);
                    text( es.length, width-10, ix );
                    textAlign(LEFT);
                    fill( 0 );
                    Arrays.sort( es );
                    /*ix += 15;
                    text( df.format(es[0].createdAt) + " - " + df.format(es[es.length-1].createdAt), 10, ix );*/
                    ix += 15;
                    for ( Event ee : es )
                    {
                        float x = 10+map(millisecDifference(from,ee.createdAt),0,total,0,width-20);
                        
                        if ( ee.title.equals("start") )
                            fill( 255, 0, 0 );
                        else if ( ee.title.equals("end") )
                            fill( 0, 0, 255 );
                        else
                            fill( 0 );
                        
                        if ( ee.title.equals("start") || ee.title.equals("end") )
                        {
                            stroke( 0 );
                            line( x, ix-15, x, ix+10 );
                        }
                            
                        noStroke();
                        ellipse( x, ix-5, 4, 4 );
                    }
                    ix += 15;
                }
            }
        }
    }
}

long millisecDifference ( Date from, Date to )
{
    return to.getTime() - from.getTime();
}

void keyPressed ()
{
    if ( key != CODED )
        switch ( key )
        {
            case ' ':
                selectionMode = !selectionMode;
        }

    switch ( keyCode )
    {
        case RIGHT:
            currentPieceIndex++;
            currentPieceIndex %= pieces.length;
            currentPiece = pieces[currentPieceIndex];
            break;
        
        case LEFT:
            currentPieceIndex--;
            if ( currentPieceIndex < 0  )
                currentPieceIndex = pieces.length-1;
            currentPiece = pieces[currentPieceIndex];
            break;
                
        case UP:
            currentPiece.selectPreviousVideo();
            break;
                
        case DOWN:
            currentPiece.selectNextVideo();
            break;
    }
}


