
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
    
    clusters = new ArrayList();
    EventTimeCluster[] clustersTmp = EventTimeClusters.clusterEvents( vids.videos );
    if ( clustersTmp != null && clustersTmp.length > 0 )
    {
        for ( EventTimeCluster c : clustersTmp )
        {
            api.loadEventsBetween( c.from(), c.to(), api.createCallback( "eventsLoaded", c ) );
            clustersExpected++;
        }
    }
    else
    {
        System.err.println( "Unable to build enough clusters" );
    }
}

void eventsLoaded ( Events evts, EventTimeCluster c )
{
    clustersExpected--;
    
    loadingMessage = "Loading "+clustersExpected+" clusters ...";
    
    if ( evts == null ) return;
    if ( c == null ) return;
    
    org.piecemaker.models.Event[] events = evts.events;
    
    if ( events == null || events.length == 0 ) return;
    
    for ( org.piecemaker.models.Event e : evts.events )
    {
        if ( e.getEventType().equals("scene") )
            c.addEvent( e );
    }
    clusters.add( c );
     
    if ( clustersExpected == 0 ) 
    {
        nextCluster();
        loading = false;
    }
}

