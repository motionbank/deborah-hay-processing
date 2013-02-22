/**
 *    Motion Bank, http://motionbank.org
 *
 *    Calculate the travel distance (3D) based on the 3D position track per recording
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
 EventTimeCluster currentCluster;
 
 float[][] positions;
 float[] travelDistances;
 
 long recordingsFrom, recordingsTo;
 String positionsBaseUrl = "http://lab.motionbank.org/dhay/data/";
 
 String loadingMessage = "Loading pieces ...";
 boolean loading = true;
 int clustersExpected = 0;
 
 void setup ()
 {
     size( 900, 400 );
     
     positionsBaseUrl = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
     
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
         text( currentCluster.from() + " - " + currentCluster.to(), 20, 30 );
         for ( Video v : currentCluster.getVideos() )
         {
             if ( v.getTitle().indexOf("AJA") != -1 )
             {
                 text( v.getTitle(), 20, 45 );
                 break;
             }
         }
         
         drawTravelMovement();
     }
 }
 
 void drawTravelMovement ()
 {
     if ( positions == null )
     {
         new Thread() {
             public void run () {
                 loadPositions();
             }
         }.start();
         return;
     }
     
     int blockSize = travelDistances.length / (width-20) + 1;
     float[] blocks = new float[width-20];
     for ( int i = 0, k = 0; i < (travelDistances.length-blockSize); i+=blockSize, k++ )
     {
         float block = 0;
         for ( int b = 0; b < blockSize; b++ )
         {
             block += travelDistances[i+b];
         }
         block /= blockSize;
         blocks[k] = block;
     }
     noStroke();
     fill( 0 );
     for ( int i = 0; i < blocks.length; i++ )
     {
         float b = blocks[i];
         b *= 2000;
         rect( 10+i, height-10-b, 1, b );
     }
 }
 
 void loadPositions ()
 {
     loading = true;
     loadingMessage = "Loading positions ...";
     
     for ( org.piecemaker.models.Event e : currentCluster.getEvents() )
     {
         if ( e.getEventType().equals("data") )
         {
             org.json.JSONObject data = null;
             
             try {
                 data = new org.json.JSONObject( e.description );
             } catch ( Exception excp ) {
                 excp.printStackTrace();
                 return;
             }
             
             String positionsPath = null;
             try {
                 positionsPath = data.getString( "file" );
             } catch ( Exception excp ) {
                 excp.printStackTrace();
             }
             positionsPath = positionsPath.replace( ".txt", "_interpolated.txt" );
             
             String[] lines = loadStrings( positionsBaseUrl + positionsPath );
             
             positions = new float[lines.length][3];
             travelDistances = new float[positions.length];
             float[] lastPosition = null;
             
             for ( int l = 0; l < lines.length; l++ )
             {
                 String line = lines[l];
                 String[] vals = line.split(" ");
                 positions[l] = new float[]{
                     float( vals[0] ),
                     float( vals[1] ),
                     float( vals[2] )
                 };
                 if ( lastPosition != null )
                 {
                     travelDistances[l] = dist( 
                         lastPosition[0], lastPosition[1], lastPosition[2],
                         positions[l][0], positions[l][1], positions[l][2]
                     );
                 }
                 lastPosition = positions[l];
             }
             
             File distFile = new File( sketchPath( "output/" + positionsPath.replace("Tracked3DPosition", "TravelDistances3D") ) );
             if ( !distFile.exists() )
             {
                 distFile.getParentFile().mkdirs();
                 
                 String[] linesOut = new String[travelDistances.length];
                 for ( int i = 0; i < travelDistances.length; i++ )
                 {
                     linesOut[i] = travelDistances[i] + "";
                 }
                 
                 saveStrings( distFile.getPath(), linesOut );
             }
         }
     }
     
     loading = false;
 }
