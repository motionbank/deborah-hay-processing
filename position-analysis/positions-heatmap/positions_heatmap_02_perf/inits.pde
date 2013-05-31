
void pieceLoaded ( Piece piece )
{
}

void videosLoaded ( Videos videos )
{
    for ( Video v : videos.videos )
    {
        if ( v.getTitle().indexOf( "Center_Small" ) != -1 )
        //&& v.getTitle().indexOf( performer ) != -1)
        {
            api.loadEventsByTypeForVideo( v.id, "scene", api.createCallback( "eventsLoaded", v ) );
            loadingMessage = "Loading scene events for videos";
            delay( 500 );
        }
    }
}

void eventsLoaded ( Events events, Video video )
{
    VideoEventGroup vGroup = new VideoEventGroup( video, events.events );
    groupsLoading++;
    api.loadEventsByTypeForVideo( video.id, "data", api.createCallback( "dataEventsLoaded", vGroup ) );
    loadingMessage = "Loading data events for videos";
}

void dataEventsLoaded ( Events events, VideoEventGroup group )
{
    org.piecemaker.models.Event dataEvent = events.events[0];
    
    long dataEventStart = dataEvent.getHappenedAt().getTime();
    int msPerFrame = 1000 / 25;
    
    // it's JSON but we just grab what we need and skip the full parsing
    String track3DFile = dataEvent.getDescription();
    track3DFile = track3DFile.substring( track3DFile.indexOf("\"")+1 );
    track3DFile = track3DFile.substring( 0, track3DFile.indexOf("\"") );
    
    // using the 25 fps version
    track3DFile = track3DFile.replace( ".txt", "_com.txt" );
    
    String[] lines = new String[0];
    
    if (mbLocal) {
      String[] parts = group.video.title.split("_");
      lines = loadStrings( LOCAL_DATA_PATH + POSITION_DATA_DIR + parts[1] + "_" + parts[0] + POSITION_DATA_FILE);
    }
    else lines = loadStrings( TRACK_3D_ROOT + "/" + track3DFile );
    
    org.piecemaker.models.Event e1 = null;
        
    for ( int i = 1; i < group.events.length; i++ )
    {
        if ( e1 == null ) e1 = group.events[i-1];
        org.piecemaker.models.Event e2 = group.events[i];
        
        long eventStart = e1.getHappenedAt().getTime();
        long eventEnd = e2.getHappenedAt().getTime();
        
        int iFrom = (int)(eventStart - dataEventStart) / msPerFrame;
        int iTo = iFrom + (int)(eventEnd - eventStart) / msPerFrame;
        
        if ( iTo >= lines.length ) iTo = lines.length-1;
        
        float[][] points = new float[iTo-iFrom][0];
        String[] pieces;
        
        for ( int ii = iFrom; ii < iTo; ii++ )
        {
            pieces = lines[ii].split(" ");
            
            points[ii-iFrom] = new float[]{
                float(pieces[0]),
                float(pieces[1])
            };
        }
        
        SceneHeatMap map = new SceneHeatMap( e1.getTitle() );
        map.generate( points, new float[]{-1,-1}, new float[]{13,13} );
        group.addHeatMap( map );
        
        e1 = e2;
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    float[][] points = new float[lines.length][0];
    for ( int ii = 0; ii < lines.length; ii++ )
        {
            String[] pieces = lines[ii].split(" ");
            
            points[ii] = new float[]{
                float(pieces[0]),
                float(pieces[1])
            };
        }
    
    group.videoHeatMap = new SceneHeatMap( group.video.getTitle() );
    group.videoHeatMap.generate( points, new float[]{-1,-1}, new float[]{13,13} );
    
    group.sortEvents();
    
    groups = (VideoEventGroup[])append( groups, group );
    groupsLoading--;
    
    loadingMessage = "Loading data ... still " + groupsLoading + " more coming";
    
    if ( groupsLoading == 0 )
    {
        java.util.Arrays.sort(groups, new java.util.Comparator(){
            public int compare ( Object a, Object b ) {
                return ((VideoEventGroup)a).video.getHappenedAt().compareTo(((VideoEventGroup)b).video.getHappenedAt());
            }
        });
        
        multMaps = new SceneHeatMap[groups[0].heatMaps.length];
        
        // 25
        for (int i=0; i<multMaps.length; i++) {

            multMaps[i] = new SceneHeatMap(groups[0].events[i].getTitle());
            multMaps[i].values = new float[groups[0].heatMaps[0].values.length];
            
            // 7 - 1
            for (int j=0; j<groups.length; j++) 
            {
               SceneHeatMap hm = groups[j].heatMaps[i];
               
               // res * res
               for (int k=0; k<hm.values.length; k++) 
               {
                  multMaps[i].values[k] += hm.values[k] / (float)groups.length;
               }
            }
        }
        
        loaded = true;
        //redraw();
    }
}
