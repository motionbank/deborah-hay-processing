import processing.pdf.*;

//import org.json.*;
import de.bezier.data.sql.*;
import de.bezier.guido.*;
import org.piecemaker.models.*;

import java.util.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;
final String POS_3D_ROOT = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";

MySQL db;
Piece piece;
ArrayList<VideoTimeCluster> clusters;

boolean showAll = false;
boolean savePDF = false;

VideoTimeCluster currCluster = null;
int currClusterIndex = 0;

ArrayList<ThreeDPositionTrack> tracks3D;

Listbox list1, list2;
PFont interfaceFont, stageFont;

Date timeMin, timeMax;
String sceneFrom = "wordless song", sceneTo = "1 minute turn";
ArrayList<String> sceneNames;

boolean showInterface = false, loading = true;
float leftOffset = 0;

void setup () 
{
    size( 1000, 700 );
    
    Interactive.make(this);
    
    list1 = new Listbox( width-10-250, 10, 250, (height-20)/2 );
    list2 = new Listbox( width-10-250, 10 + ((height-20)/2) + 10, 250, (height-20)/2 - 10 );
    
    Interactive.setActive( false );
    
    new Thread(){
        public void run () {
            initDatabase();
            loadMarkers();
            currCluster = clusters.get(0);
            loading = false;
        }
    }.start();
    
    stageFont = createFont( "Open Sans", 11 );
}

String pdfName = "";

void draw ()
{
    background( 255 );
    
    if ( !loading ) 
    {
        if ( savePDF )
        {
          pdfName = year()+"-"+month()+"-"+day()+"/"+
                              hour()+"-"+minute()+"-"+second()+"-"+
                              currCluster.videos.get(1).title;
            beginRecord( PDF, pdfName+".pdf" );
        }
        
        float s = height / 14.0;
        float leftOffsetMax = (width/2)-s-((12/2)*s);
        
        if ( showInterface ) 
        {
            leftOffset /= 2;
            if ( leftOffset <= 0.1 ) {
                Interactive.setActive(true);
            }
        }
        else if ( !showInterface && leftOffset < leftOffsetMax ) 
        {
            leftOffset = (leftOffset+1) * 2;
            if ( leftOffset >= leftOffsetMax ) {
                leftOffset = leftOffsetMax;
            }
        }
        
        pushMatrix();
        translate( leftOffset, 0 );
        
        noStroke();
        
        fill( 240 );
        rect( s, height-s, (12*s), -(12*s) );
        
        fill( 210 );
        textAlign( CENTER );
        textSize( 11 );
        text( sceneFrom + " - " + sceneTo, s+(12*s)/2, height-(s/2) );
        
        for ( VideoTimeCluster c : clusters ) 
        {
            if ( !showAll && currCluster != c ) continue;
            
            org.piecemaker.models.Event evData = null, evFrom = null, evTo = null;
            ThreeDPositionTrack track3D = null;
            
            evFrom = c.events.get(0);
            evTo = c.events.get(1);
            
            for ( org.piecemaker.models.Event e : c.events ) 
            {
                if ( e.getEventType().equals("data") )
                {
                    evData = e;
                    for ( ThreeDPositionTrack t : tracks3D )
                    {
                        if ( t.event == e )
                        {
                            track3D = t;
                            break;
                        }
                    }
                    track3D.setScale( s );
                }
                else 
                {
                    if ( e.title.equals( sceneFrom ) )
                    {
                        evFrom = e;
                    }
                    
                    if ( e.title.equals( sceneTo ) )
                    {
                        evTo = e;
                    }
                }
            }
            
            if ( evData != null && evFrom != null && evTo != null )
            {
                int iEvFrom = c.events.indexOf( evFrom );
                int iEvTo = c.events.indexOf( evTo );
                
                if ( iEvFrom < c.events.size()-1 && iEvFrom >= iEvTo )
                {
                    evTo = c.events.get( iEvFrom+1 );
                    list2.select( evTo.title );
                }
                
                sceneFrom = evFrom.title;
                sceneTo = evTo.title;
                
                int fStart = (int)( evFrom.getHappenedAt().getTime() -
                                    evData.getHappenedAt().getTime() );
                    fStart = int( (fStart / 1000.0) * track3D.fps );
                    
                int fLen = int( evTo.getHappenedAt().getTime() -
                                evFrom.getHappenedAt().getTime() );
                    fLen = int( (fLen / 1000.0) * track3D.fps );
                
                
                stroke( 0 );
                noFill();
                
                pushMatrix();
                translate( s, height-s );
                
                track3D.drawFromTo( fStart, fLen );
                
                popMatrix();
            }
            
            String performer = evFrom.performers != null && evFrom.performers.length > 0 ? evFrom.performers[0] : null;
            if ( performer == null ) performer = evTo.performers != null && evTo.performers.length > 0 ? evTo.performers[0] : null;
            if ( performer == null ) performer = c.videos.get(0).title;
            if ( performer != null )
            {
                fill( 210 );
                textAlign( CENTER );
                textSize( 11 );
                text( performer, s+(12*s)/2, height-(s/2)+14 );
            }
        }
        
        if ( savePDF )
        {
            savePDF = false;
            endRecord();
            saveFrame( pdfName+".png" );
        }
        
        popMatrix();
    }
    else // loading
    {
        fill( 0 );
        textFont( stageFont );
        textSize( 22 );
        textAlign( CENTER );
        text( "Loading", width/2, height/2 );
    }
}

void keyPressed ()
{
    if ( key == CODED )
    {
        int ito, ifrom;
        switch ( keyCode )
        {
            case RIGHT:
                currClusterIndex++;
                currClusterIndex %= clusters.size();
                break;
            case LEFT:
                currClusterIndex--;
                if ( currClusterIndex < 0 ) currClusterIndex = 0;
                break;
            case UP:
                ifrom = sceneNames.indexOf( sceneFrom );
                if ( ifrom > 0 ) ifrom--;
                ito = sceneNames.indexOf( sceneTo );
                if ( ito > ifrom+1 ) ito--;
                sceneFrom = sceneNames.get( ifrom );
                list1.select( sceneFrom );
                sceneTo = sceneNames.get( ito );
                list2.select( sceneTo );
                break;
            case DOWN:
                ito = sceneNames.indexOf( sceneTo );
                if ( ito < sceneNames.size()-1 ) ito++;
                ifrom = sceneNames.indexOf( sceneFrom );
                if ( ifrom < ito-1 ) ifrom++;
                sceneFrom = sceneNames.get( ifrom );
                list1.select( sceneFrom );
                sceneTo = sceneNames.get( ito );
                list2.select( sceneTo );
                break;
        }
        
        currCluster = clusters.get(currClusterIndex);
    }
    else
    {
        switch ( key )
        {
            case 's':
                showAll = !showAll;
                break;
            case 'p':
                savePDF = true;
                break;
            case ' ':
                showInterface = !showInterface;
                if ( !showInterface ) {
                    Interactive.setActive(false);
                }
                break;
        }
    }
}

public void itemClicked ( Listbox lBox, int i, Object item )
{
    if ( lBox == list1 ) {
        sceneFrom = item.toString();
    } else {
        sceneTo = item.toString();
    }
}
