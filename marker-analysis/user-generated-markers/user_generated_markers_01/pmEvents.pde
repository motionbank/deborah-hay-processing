
void piecesLoaded ( Pieces pieces )
{
    loadingMessage = "Loading videos ...";
    
    if ( pieces.pieces.length > 0 ) {
        Piece piece = pieces.pieces[0];
        api.loadVideosForPiece( piece.id, api.createCallback( "videosLoaded", piece.id ) );
    }
}

void videosLoaded ( Videos vids, int piece_id )
{
    loadingMessage = "Loading events ...";
    
    if ( vids.videos.length > 0 ) 
    {
        videos = vids.videos;
        
        // building clusters from videos
        
        // a cluster is all videos that overlap:
        //   |-------|    video 1
        // |-------|      video 2
        //       |---|    video 3
        // |=========|    cluster
        
        
        clusters = new ArrayList();
        ArrayList<VideoTimeCluster> clustersTemp = new ArrayList();
        
        for ( org.piecemaker.models.Video v : videos ) 
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
        clustersExpected = 0;
        
        for ( VideoTimeCluster c : clustersTemp )
        {
            api.loadEventsBetween( c.from, c.to, api.createCallback( "eventsLoaded", c, clustersExpected ) );
            
            println( ">> requested cluster #" + clustersExpected );
            clustersExpected++;
        }
        
        clustersTemp = null;
    }
}

void eventsLoaded ( Events evts, VideoTimeCluster c, int clusterNum )
{
    println( "<< received cluster #" + clusterNum );
    clustersExpected--;
    
    loadingMessage = "Loading "+clustersExpected+" clusters ...";
    
    if ( c == null ) 
    {
        System.err.println( "No cluster!" );
        return;
    }
    
    if ( evts == null ) 
    {
        System.err.println( "No events!" );
        return;
    }
    
    org.piecemaker.models.Event[] events = evts.events;
    
    if ( events == null || events.length == 0 ) 
    {
        System.err.println( "No events!" );
        return;
    }
    
    for ( org.piecemaker.models.Event e : events )
    {
        if ( e.getEventType().equals("marker") ) c.addEvent( e );
    }
    
    clusters.add( c );
    
    if ( clustersExpected == 0 ) 
    {
        loading = false;
    }
}

