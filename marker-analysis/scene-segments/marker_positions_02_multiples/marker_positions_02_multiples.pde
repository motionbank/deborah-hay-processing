import processing.pdf.*;

//import org.json.*;
import de.bezier.data.sql.*;
import de.bezier.guido.*;
import org.piecemaker.models.*;

import java.util.*;

final static String PM_ROOT = "/Users/fjenett/Repos/piecemaker";
final int PIECE_ID = 3;
final String FILE_3D_POS = "Tracked3DPosition_com.txt";
final String POS_3D_ROOT = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";

MySQL db;
Piece piece;
ArrayList<VideoTimeCluster> clusters;

boolean showAll = false;
boolean savePDF = false;

VideoTimeCluster currCluster = null;
int currClusterIndex = 0;

ArrayList<ThreeDPositionTrack> tracks3D;

Slider slider1, slider2;
float dt = 0.1, rc = 0;

Listbox list1, list2;

Date timeMin, timeMax;
String sceneFrom = "wordless song", sceneTo = "1 minute turn";
ArrayList<String> sceneNames;

void setup () 
{
    size( 1000, 700 );
    
    Interactive.make(this);
    slider1 = new Slider( 10, 10, width-20, 10 );
    slider1.setValue(dt/2);
    slider2 = new Slider( 10, 20, width-20, 10 );
    slider2.setValue(rc/10);
    
    list1 = new Listbox( width-10-250, 40, 250, (height-30)/2 );
    list2 = new Listbox( width-10-250, 40 + ((height-30)/2) + 10, 250, (height-30)/2 - 30 );
    
    initDatabase();
    loadMarkers();
    currCluster = clusters.get(0);
}

String pdfName = "";

void draw ()
{
    background( 255 );
    
    if ( savePDF )
    {
      pdfName = year()+"-"+month()+"-"+day()+"/"+
                          hour()+"-"+minute()+"-"+second()+"-"+
                          currCluster.videos.get(1).title;
        beginRecord( PDF, pdfName+".pdf" );
    }
    
    dt = slider1.value * 2;
    rc = slider2.value * 10;
    
    float s = (height-20) / 13.0;
    
    noStroke();
    
    fill( 240 );
    rect( 10, height-10, (12*s), -(12*s) );
    
    fill( 210 );
    text( sceneFrom + " - " + sceneTo, 14, height-14 );
    
    for ( VideoTimeCluster c : clusters ) 
    {
        if ( !showAll && currCluster != c ) continue;
        
        org.piecemaker.models.Event evData = null, evFrom = null, evTo = null;
        ThreeDPositionTrack track3D = null;
        
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
            else if ( e.title.equals( sceneFrom ) )
            {
                evFrom = e;
            }
            else if ( e.title.equals( sceneTo ) )
            {
                evTo = e;
            }
        }
        
        if ( evData != null && evFrom != null && evTo != null )
        {
            int fStart = (int)( evFrom.getHappenedAt().getTime() -
                                evData.getHappenedAt().getTime() );
                fStart = int( (fStart / 1000.0) * track3D.fps );
                
            int fLen = int( evTo.getHappenedAt().getTime() -
                            evFrom.getHappenedAt().getTime() );
                fLen = int( (fLen / 1000.0) * track3D.fps );
            
            
            stroke( 0 );
            noFill();
            
            pushMatrix();
            translate( 10, height-10 );
            
            track3D.drawFromTo( fStart, fLen );
            
            float[] pStart = track3D.getPositionAt( fStart );
            float[] pEnd = track3D.getPositionAt( fStart+fLen );
            fill( 0 );
            text( c.videos.get(1).title, pStart[0], pStart[1] );
            
            popMatrix();
        } else {
          if ( evFrom == null ) println( sceneFrom );
          if ( evTo == null ) println( sceneTo );
        }
        
        //break;
    }
    
    if ( savePDF )
    {
        savePDF = false;
        endRecord();
        saveFrame( pdfName+".png" );
    }
}

void keyPressed ()
{
    if ( key == CODED )
    {
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
