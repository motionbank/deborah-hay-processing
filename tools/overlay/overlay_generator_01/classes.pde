public class Performance {
    
    PieceMakerApi api;
    
    String performer;
    
    float[][] track3D;
    float[][] trackBbox2D;
    
    int videoId;
    String basePath;
    
    int currentScene = -1;
    int currentFrame = -1;
    
    Video video;
    org.piecemaker.models.Event dataEvent;
    org.piecemaker.models.Event[] sceneEvents;
    
    int dataEventFrame = 0;
    int[] sceneEventsFrame;
    
    int loaded = 0;
    
    PImage img;
    String imgPath;
    float[] bbox;
    
    Performance ( int videoId, String performer, PieceMakerApi api ) 
    {
        this.videoId = videoId;
        this.api = api;
        this.performer = performer;
        
        api.loadVideo( videoId, api.createCallback( this, "videoLoaded" ) );
    }
    
   void videoLoaded ( Video video )
   {
       if ( video != null )
       {
           this.video = video;
           
           api.loadEventsByTypeForVideo( video.id, "data", api.createCallback( this, "dataEventsLoaded" ) );
           api.loadEventsByTypeForVideo( video.id, "scene", api.createCallback( this, "sceneEventsLoaded" ) );
       }
   }
   
   void dataEventsLoaded (  Events events )
   {
       //System.out.printf( "Loaded %d data events for %d\n", events.total, videoId );
       
       if ( events != null )
       {
           dataEvent = events.events[0];
           dataEventFrame = int( dataEvent.getHappenedAt().getTime() - video.getHappenedAt().getTime() ) / 20;
           loadData();
       }
   }
   
   void loadData ()
   {
       if ( dataEvent != null )
       {
           if ( track3D == null ) 
           {
               JSONObject data = JSONObject.parse( dataEvent.description );
               String filePath = data.getString("file");
                
               String[] track3DLines = null, trackBboxLines = null;
               
               basePath = filePath.replace("/Tracked3DPosition.txt", "");
               if ( performer.equals("roswarby") )
                   basePath = "Ros/" + basePath;
               else if ( performer.equals("jeaninedurning") )
                   basePath = "Jeanine/" + basePath;
               else if ( performer.equals("juliettemapp") )
                   basePath = "Juliette/" + basePath;
               
               filePath = filePath.replace(".txt", "_com.txt");
               File f = new File( dataTracksBasePath + "/" + filePath );
               if ( f.exists() && f.canRead() )
               {
                   track3DLines = loadStrings( f.getAbsolutePath() );
                   track3D = new float[ track3DLines.length ][ 0 ];
                   for ( int i = 0; i < track3DLines.length; i++ )
                   {
                       track3D[i] = float( track3DLines[i].split( " " ) );
                   }
                   
               } else {
                   System.out.printf( "File is missing %s\n", f.getPath() );
               }
               
               File f2 = new File( dataTracksBasePath + "/" + filePath.replace("Tracked3DPosition_com.txt","BoundingBox_CamCenter.txt") );
               if ( f2.exists() && f.canRead() )
               {
                   trackBboxLines = loadStrings( f2.getAbsolutePath() );
                   trackBbox2D = new float[ trackBboxLines.length ][ 0 ];
                   for ( int i = 0; i < trackBboxLines.length; i++ )
                   {
                       trackBbox2D[i] = float( trackBboxLines[i].split( " " ) );
                   }
                   
               } else {
                   System.out.printf( "File is missing %s\n", f2.getPath() );
               }
               
               //System.out.printf( "%d %d\n", track3DLines.length, trackBboxLines.length );
           }
       }
       
       loaded++;
   }
   
   void sceneEventsLoaded ( Events events )
   {
       //System.out.printf( "Loaded %d scene events for %d\n", events.total, videoId );
       
       if ( events != null && events.total > 0 )
       {
           sceneEvents = events.events;
           java.util.List sceneList = java.util.Arrays.asList(scenesByName);
           
           sceneEventsFrame = new int[events.total];
           
           for ( int i = 0; i < sceneEvents.length; i++ )
           {
               org.piecemaker.models.Event e = sceneEvents[i];
               
               if( -1 == sceneList.indexOf( e.title ) )
               {
                   scenesByName = append( scenesByName, e.title );
               }
               
               sceneEventsFrame[i] = int( e.getHappenedAt().getTime() - video.getHappenedAt().getTime() ) / 20;
           }
           
           currentScene = 0;
           currentFrame = sceneEventsFrame[currentScene];
       
           loaded++;
       }
   }
   
   boolean hasMoreForScene ( String scene )
   {
       if ( !sceneEvents[currentScene].getTitle().equals(scene) ) return false;
       
       if ( currentScene < sceneEventsFrame.length-1 && currentFrame < sceneEventsFrame[currentScene+1] )
       {
           return true;
       }
       return false;
   }
   
   float getDepth ()
   {
       return track3D[currentFrame][1];
   }
   
   void nextFrame ()
   {
       // for draw()
       imgPath = silhouetteBasePath + "/" + basePath + "/Images_BackgroundSubstracted/CamCenter/CamCenter_BackgroundSubstracted" + nf(currentFrame,6) + ".png";
       bbox = trackBbox2D[currentFrame];
       
       if ( currentFrame < track3D.length )
       {
         currentFrame++;
       }
       if ( currentScene < sceneEventsFrame.length-1 && currentFrame >= sceneEventsFrame[currentScene+1] ) 
       {
         currentScene++;
       }
   }
   
   boolean isLoaded ()
   {
       return loaded >= 2;
   }
   
   void draw ( PGraphics pg )
   {
       loadFrame();
       
       if ( img != null && bbox != null )
       {
           pg.image( img, bbox[0], bbox[1] );
           pg.removeCache( img );
           removeCache( img );
       }
   }
   
   void loadFrame ()
   {
       img = loadImage( imgPath );
       
       if ( img != null ) 
       {
           img.loadPixels();
           img.format = ARGB;
           
           for ( int p = 0, k = img.pixels.length; p < k; p++ ) // remove turquoise
            {
                if ( img.pixels[p] == 0xFF00FFFF )
                {
                    img.pixels[p] = 0x00000000;
                }
            }
            
            img.updatePixels();
            
            if ( img.width != (bbox[2]-bbox[0]) || img.height != (bbox[3]-bbox[1]) )
            {
                System.out.printf( "Somethings wrong with this image (dimensions don't match bbox) %s\n[%d, %d] != [%d, %d, %d, %d]\n%d\n", 
                                   imgPath, img.width, img.height, bbox[0], bbox[1], bbox[2], bbox[3] );
            }
            
            removeCache( img );
       }
   }
}
