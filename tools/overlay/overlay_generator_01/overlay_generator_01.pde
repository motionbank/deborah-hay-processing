/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Generate depth-sorted "overlays" from silhouettes
 *
 *    Processing 2.0
 *    fjenett 20130411
 */
 
 import org.piecemaker.api.*;
 import org.piecemaker.models.*;
 import org.piecemaker.collections.*;

 import org.motionbank.imaging.*;
 
 PieceMakerApi api;
 Performance[] performances;
 Performance[][] performancesPerPerformer;
 java.util.Comparator performanceDepthComparator;
 
 String silhouetteBasePath = "/Volumes/Verytim/2011_FIGD_April_Results/";
 String overlayResultsPath = "/Volumes/Verytim/2013_FIGD_overlays/";
 String dataTracksBasePath = "/Library/WebServer/Documents/motionbank.org/lab/dhay/data/";
 
 String[] scenesByName;
 int currentScene, currentFrame;
 boolean loaded = false;
 int toLoadNum = 0, totalPerformances = 0;
 
 String[] performers;
 PGraphics pg;
 
 void setup () 
 {
     size( 1920/4, 1080/4, JAVA2D );
     pg = createGraphics( 1920, 1080, JAVA2D );
     
     scenesByName = new String[0];
     
     performanceDepthComparator = new java.util.Comparator(){
         public int compare ( Object a, Object b ) {
             return (int)( (((Performance)b).getDepth()*100) - (((Performance)a).getDepth()*100) );
         }
     };
     
     api = new PieceMakerApi( this, 
                              "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe", 
                              true ? "http://localhost:3000" : "http://notimetofly.herokuapp.com" );
    
     int[][] performanceIds = new int[][] {
         new int[]{ 76,77,79,81,82,83,80 }, // Ros
         new int[]{ 84,87,88,89,90,91,86 }, // Jeanine
         new int[]{ 95,96,97,98,99,85,100 } // Juliette
     };
     
     performers = new String[] {
         "roswarby", 
         "juliettemapp", 
         "jeaninedurning"
     };
     
     performances = new Performance[0];
     performancesPerPerformer = new Performance[performers.length][0];
     
     for ( int i = 0; i < performers.length; i++ )
     {
         for ( int ii = 0; ii < performanceIds[i].length; ii++ )
         {
             performances = (Performance[])append( performances, new Performance( performanceIds[i][ii], performers[i], api ) );
             performancesPerPerformer[i] = (Performance[])append( performancesPerPerformer[i], performances[performances.length-1] );
             
             totalPerformances++;
             
             delay( 500 ); // needed on localhost only as connection is "instant" and too many requests at once will hose rails
         }
     }
 }
 
 void draw () 
 {     
     if ( loaded )
     {
         java.util.Arrays.sort( performances, performanceDepthComparator );
         
         boolean changeScene = true;
         boolean[] performerHasMore = new boolean [performers.length];
         
         for ( int i = 0; i < performers.length; i++ )
         {
             java.util.Arrays.sort( performancesPerPerformer[i], performanceDepthComparator );
           
             for ( int ii = 0; ii < performancesPerPerformer[i].length; ii++ )
             {
                 Performance p = performancesPerPerformer[i][ii];
                 boolean hasMore = p.hasMoreForScene( scenesByName[currentScene] );
                 if ( hasMore )
                 {
                     p.nextFrame();
                     changeScene = false;
                     performerHasMore[i] = true;
                 }
             }
         }
         
         if ( !changeScene )
         {
             for ( int i = 0; i < performers.length; i++ )
             {
                 if ( performerHasMore[i] )
                 {
                     String pn = performers[i];
                     
                     String path = overlayResultsPath + "/" + nf(currentScene,2) + "_" + scenesByName[currentScene] + "/" + pn;
                     File oDir = new File( path );
                     
                     String pngFilePath = oDir.getAbsolutePath() + "/" + nf(currentFrame,6) + ".png";
                     
                     File pngFile = new File(pngFilePath);
                     if ( pngFile.exists() ) continue;
                     
                     if ( !oDir.exists() )
                     {
                         oDir.mkdirs();
                     }
                     
                     pg.beginDraw();
                     pg.background( 0x00FFFFFF );
                     
                     for ( int ii = 0; ii < performancesPerPerformer[i].length; ii++ )
                     {
                         Performance p = performancesPerPerformer[i][ii];
                         p.draw( pg );
                     }
                     pg.endDraw();
                     pg.save( pngFilePath );
                 
                     background( 255 );
                     image( pg, 0,0, width, height );
                     removeCache( pg );
                 }
             }
             currentFrame++;
         }
         
         if ( changeScene )
         {
             currentScene++;
             currentFrame = 0;
             
             if ( currentScene >= scenesByName.length || scenesByName[currentScene].equals("end") )
             {
                 exit(); return;
             }
             
             System.out.printf( "Changing scene to %s\n", scenesByName[currentScene] );
         }
     }
     else // not loaded
     {
         boolean allLoaded = true;
         toLoadNum = 0;
         
         for ( Performance p : performances )
         {
             if ( !p.isLoaded() )
             {
                 allLoaded = false;
                 toLoadNum++;
             }
         }
         if ( allLoaded )
         {
             loaded = true;
             currentScene = 0;
             currentFrame = 0;
         }
         
         background( 255 );
         fill(0);
         noStroke();
         float w = map( toLoadNum, totalPerformances, 0, width, 0 );
         rect( width-w, 0, w, height );
     }
 }
