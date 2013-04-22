/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Exports the piecemaker scene markers as cutting list for Amin ... to produce the overlay snippets
 *
 *    Processing 2.0
 *    created: fjenett 20130315
 */
 
 import org.piecemaker.api.*;
 import org.piecemaker.models.*;
 import org.piecemaker.collections.*;
 
 PieceMakerApi api;
 
 void setup ()
 {
     size( 200, 200 );
     
     api = new PieceMakerApi(this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", true ? "http://localhost:3000" : "http://notimetofly.herokuapp.com" );
     api.loadVideosForPiece( 3, api.createCallback( "videosLoaded" ) );
 }
 
 void videosLoaded ( Videos videos )
 {
     for ( Video v : videos.videos )
     {
         if ( v.getTitle().toLowerCase().indexOf("_center") != -1 || v.getTitle().toLowerCase().indexOf("_aja_1") != -1 )
         {
             api.loadEventsByTypeForVideo( v.id, "scene", api.createCallback("eventsLoaded", v) );
             delay( 700 );
         }
     }
 }
 
  void eventsLoaded ( Events events, Video v )
 {
     long videoTime = v.getHappenedAt().getTime();
     
     String[] lines = new String[ events.total ];
     int i = 0;
     
     for ( org.piecemaker.models.Event e : events.events )
     {
         float secs = (e.getHappenedAt().getTime() - videoTime) / 1000.0;
         float mins = (int)(secs / 60);
         secs -= (mins * 60);
         
         String secsStr = "00:"+nf(int(mins),2)+":"+nf(int(secs),2);
         
         println( secsStr + " " + e.getTitle() );
         
         lines[i] = v.getTitle() + "," + v.id + "," + secsStr + "," + e.getTitle() + ",";
         
         i++;
     }
     
     saveStrings( "output/" + v.getTitle() + "_ID" + nf(v.id,3) + "_scenes.txt", lines );
 }
