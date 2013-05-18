void videosLoaded ( Videos videos )
{
    if ( videos != null ) 
    {
        ArrayList<VideoTimeCluster> prelimClust = new ArrayList();
    
        tracks3D = new ArrayList();
        sceneNames = new ArrayList();
        clusters = new ArrayList();
        
        println( selTimeFrom + " " + selTimeTo );
    
        for ( Video v : videos.videos )
        {
            if ( v.getFinishedAt().getTime() < selTimeFrom.getTime() || 
                 v.getHappenedAt().getTime() > selTimeTo.getTime() ) continue;
                 
            if ( v.title.indexOf("_sync_") != -1 )
            {
                boolean hasCluster = false;
                for ( VideoTimeCluster c : prelimClust )
                {
                    if ( c.overlapsWith( v ) )
                    {
                        c.addVideo( v );
                        hasCluster = true;
                    }
                }
                if ( !hasCluster )
                {
                    VideoTimeCluster cc = new VideoTimeCluster( v );
                    prelimClust.add( cc );
                }
            }
        }
        
        for ( VideoTimeCluster c : prelimClust )
        {
            api.loadEventsBetween( c.from, c.to, api.createCallback( "eventsLoaded", c ) );
            clustersToLoad++;
            delay( 500 );
        }
    }
}

void eventsLoaded ( Events events, VideoTimeCluster c )
{
    String prevSceneName = null;
    
    if ( selPerformer != null )
    {
        for ( org.piecemaker.models.Event e : events.events )
        {
            if ( e.getEventType().equals("scene") ) 
            {
                if ( e.performers == null || e.performers.length == 0 || !e.performers[0].equals(selPerformer) ) 
                { 
                    clustersToLoad--;
                    if ( clustersToLoad == 0 )
                    {
                        loading = false;
                        currCluster = clusters.get(0);
                    }
                    return;
                }
            }
        }
    }
    
    for ( org.piecemaker.models.Event e : events.events )
    {
        if ( e.getEventType().equals("scene") && selPerformer != null ) 
        {
            if ( e.performers == null || e.performers.length == 0 || e.performers[0].equals(selPerformer) ) 
                return;
        }
        
        c.addEvent( e );
        
        if ( e.getEventType().equals("data") ) 
        {
            tracks3D.add( new ThreeDPositionTrack( e ) );
        }
        else if ( e.getEventType().equals("scene") && !sceneNames.contains( e.title ) )
        {
            if ( prevSceneName != null && sceneNames.contains(prevSceneName) )
                sceneNames.add( sceneNames.indexOf(prevSceneName)+1, e.title );
            else 
                sceneNames.add( e.title );
        }
        
        prevSceneName = e.title;
    }
        
    if ( c.events.size() > 20 )
    {
        clusters.add( c );
    }
    
    for ( String sn : sceneNames )
    {
        list1.addItem( sn );
        list2.addItem( sn );
    }
    
    clustersToLoad--;
    
    if ( clustersToLoad == 0 )
    {
        loading = false;
        currCluster = clusters.get(0);
    }
}
