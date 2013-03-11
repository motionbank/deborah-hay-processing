/**
 *    Motion Bank research, http://motionbank.org
 *
 *    When markers were added
 *
 *    Processing 2.0
 *    created: fjenett 20130311
 */
 
 import org.piecemaker.api.*;
 import org.piecemaker.models.*;
 import org.piecemaker.collections.*;
 
 PieceMakerApi api;
 org.piecemaker.models.Event[] events;
 
 void setup ()
 {
     size( 600, 200 );
     
     api = new PieceMakerApi( this, "fake-api-key", "http://notimetofly.herokuapp.com/" );
     api.loadEventsByTypeForPiece( 3, "scene", api.createCallback( "eventsLoaded" ) );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( events != null )
     {
         long min = events[0].getCreatedAt().getTime();
         long max = events[events.length-1].getCreatedAt().getTime();
         
         for ( org.piecemaker.models.Event e : events )
         {
             int x = (int)map( e.getCreatedAt().getTime() - min, 0, max-min, 10, width-10 );
             line( x, height/2-5, x, height/2+5 );
         }
         
         fill( 100 );
         textAlign( LEFT );
         text( events[0].getCreatedAt().toString(), 10, height/2-20 );
         textAlign( RIGHT );
         text( events[events.length-1].getCreatedAt().toString(), width-10, height/2+30 );
     }
 }
 
 void eventsLoaded ( Events allEvents )
 {
     events = allEvents.events;
     
     java.util.Arrays.sort( events, new java.util.Comparator(){
         public int compare ( Object a, Object b ) {
             return ((org.piecemaker.models.Event)a).getCreatedAt().compareTo(((org.piecemaker.models.Event)b).getCreatedAt());
         }
     });
 }
