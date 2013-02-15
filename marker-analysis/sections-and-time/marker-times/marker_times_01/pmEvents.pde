
void videosLoaded ( Videos vids, int piece_id )
{
    loadingMessage = "Loading events ...";
    
    if ( vids.videos.length > 0 ) 
    {
        Video[] videos = vids.videos;
        
        // building clusters from videos
        
        // a cluster is all videos that overlap:
        //   |-------|    video 1
        // |-------|      video 2
        //       |---|    video 3
        // |=========|    cluster
        
        
        clusters = new ArrayList();
        ArrayList<VideoTimeCluster> clustersTemp = new ArrayList();
        
        for ( Video v : videos ) 
        {
            // http://notimetofly.herokuapp.com/api/events/between/1298934000/1304200800.js
            if ( v.getFinishedAt().getTime() < recordingsFrom || 
                 v.getHappenedAt().getTime() > recordingsTo ) continue;
            
            boolean hasCluster = false;
            for ( VideoTimeCluster c : clustersTemp )
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
                clustersTemp.add( cc );
            }
        }
        
        // now load events for clusters by querying for from-to
        
        for ( VideoTimeCluster c : clustersTemp )
        {
            api.loadEventsBetween( c.from, c.to, api.createCallback( "eventsLoaded", c ) );
            clustersExpected++;
            
            println( c.toString() );
        }
        
        clustersTemp = null;
    }
}

int clustersExpected = 0;

void eventsLoaded ( Events evts, VideoTimeCluster c )
{
    clustersExpected--;
    
    loadingMessage = "Loading "+clustersExpected+" clusters ...";
    
    if ( evts == null ) return;
    if ( c == null ) return;
    
    org.piecemaker.models.Event[] events = evts.events;
    
    if ( events == null || events.length == 0 ) return;
    
    for ( org.piecemaker.models.Event e : events )
    {
        if ( e.getEventType().equals("scene") ) c.addEvent( e );
    }
    
    EventGroup group = null;
    for ( org.piecemaker.models.Event e : c.events )
    {
        if ( e.title.equals("fred + ginger") )
        {
            group = new EventGroup();
        }
        if ( group != null )
        {
            group.addEvent(e);
        }
        if ( group != null && e.title.equals( "end" ) )
        {
            if ( groups == null ) groups = new ArrayList();
            if ( group.events != null )
            {
                groups.add( group );
                eventsPerGroup = max( eventsPerGroup, group.events.size() );
            }
            group = null;
        }
    }
    
    if ( clustersExpected == 0 ) 
    {
        loading = false;
    }
}
