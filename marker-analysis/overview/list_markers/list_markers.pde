/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Generate an overview of scene markers to aid markering effort.
 *
 *    Discussion:
 *    http://ws.motionbank.org/project/marking-sections-performances
 *
 *    P2.0
 *    updated: fjenett 20130208
 */

import de.bezier.video.*;
import de.bezier.guido.*;
import de.bezier.data.sql.*; 
import org.piecemaker.models.*;

import java.util.*;

MySQL db;
Slider slider, slider2;

ArrayList<Video> videos;
ArrayList<Piece> pieces;
ArrayList<org.piecemaker.models.Event> events;

ArrayList<org.piecemaker.models.Event> eventsFiltered;
ArrayList<EventSequence> sequences;
EventSequence currentSequence;
int currentSequenceIndex = 0;
int sequenceWidth;
String labelHoverText = null;

HashMap<String,Integer> titleColors;

PFont lato8reg, lato8ital;

void setup ()
{
    size(displayWidth-100, displayHeight-100);
    
    Interactive.make( this );
    slider = new Slider( 10, height-20, width-20, 10 );
    slider2 = new Slider( 10, height-30, 100, 10 );
    slider2.setValue( 1 );
    
    titleColors = new HashMap();
    initDatabase();
    initAll();
    sequenceWidth = 100;

    lato8reg = createFont( "Lato-Regular", 8 );
    lato8ital = createFont( "Lato-Italic", 8 );
    textFont( lato8reg );
}

void draw ()
{
    background( 255 );
    
    pushMatrix();
    float offset = sequences.size() * sequenceWidth - width;
    if ( offset > 0 )
        translate( slider.value * -offset, 0 );
    
    sequenceWidth = (int)map(slider2.value,0,1,width/sequences.size(),100);
    
    textAlign( LEFT );

    int y = 15;
    int x = 0;
    for ( EventSequence es : sequences )
    {
        es.setXY( x, y );
        es.drawMe();

        fill( 100 );
        
        int l = Math.min( es.labels.size()-1, 5 );
        ArrayList<Video> eventVideos = getVideosForEvent( es.labels.get(l).event );
        int xx = x + 5;
        y = (es.labels.size()+1) * 15;
        for ( Video v : eventVideos )
        {
            pushMatrix();
            translate( xx, y-10 );
            rotate( HALF_PI );
            text( v.title, 0,0 );
            popMatrix();
            //y += 18;
            xx += 10;
        }

        x += sequenceWidth;
        y = 15;
    }
    popMatrix();
}

