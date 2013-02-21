/**
 *    Motion Bank, http://motionbank.org
 *
 *    P2.0
 *    created: fjenett 20130220
 */
 
 import org.piecemaker.api.*;
 import org.piecemaker.models.*;
 import org.piecemaker.collections.*;
 
 PieceMakerApi api;
 Piece piece;
 ArrayList<EventTimeCluster> clusters;
 
 long recordingsFrom, recordingsTo;
 
 String loadingMessage = "Loading pieces ...";
 boolean loading = true;
 int clustersExpected = 0;
 
 void setup ()
 {
     size( 500, 500 );
     
     setFromTo();
     api = new PieceMakerApi( this, "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", "http://notimetofly.herokuapp.com/" );
     api.loadPieces( api.createCallback( "piecesLoaded" ) );
 }
 
 void draw ()
 {
     background( 255 );
     
     if ( loading ) 
     {
         fill( 0 );
         text( loadingMessage, 20, 30 );
     } else {
         fill( 0 );
         text( clusters.size(), 20, 30 );
     }
 }
