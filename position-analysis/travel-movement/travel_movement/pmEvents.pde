
void setFromTo ()
{
    java.util.Calendar cal = java.util.Calendar.getInstance();
    
    cal.set(2011,3,18,0,0,0); // 3 == April
    recordingsFrom = cal.getTimeInMillis();
    
    cal.set(2011,3,26,0,0,0);
    recordingsTo = cal.getTimeInMillis();
}

void piecesLoaded ( Pieces pieces )
{
    for ( Piece piece : pieces.pieces )
    {
        if ( piece.id == 3 ) // no time to fly
        {
            api.loadVideosForPiece( piece.id, api.createCallback( "videosLoaded", piece.id ) );
            loadingMessage = String.format( "Loading videos for »%s« ...", piece.getTitle() );
            break;
        }
    }
}

void videosLoaded ( Videos videos, int pieceId )
{
    ArrayList<Video> vids = new ArrayList<Video>();
    
    for ( Video v : videos.videos )
    {
        if ( v.getHappenedAt().getTime() > recordingsTo || v.getFinishedAt().getTime() < recordingsFrom ) continue;
        
        if ( v.getTitle().indexOf( "_AJA" ) >= 0 || v.getTitle().indexOf( "_Center" ) >= 0 ) vids.add( v );
    }
    
    clusters = new ArrayList<EventTimeCluster>();
    
    EventTimeCluster[] cls = EventTimeClusters.clusterEvents(vids.toArray(new Video[0]));
    clustersExpected = 0;
    for ( EventTimeCluster c : cls )
    {
        api.loadEventsBetween(c.from(), c.to(), api.createCallback("eventsLoaded", c));
        clustersExpected++;
    }
}

void eventsLoaded ( Events events, EventTimeCluster cluster )
{
    clustersExpected--;
    loadingMessage = String.format( "Loading %s clusters", clustersExpected );
    
    for ( org.piecemaker.models.Event e : events.events )
    {
        if ( e.getEventType().equals("scene") || e.getEventType().equals("data") )
        {
            cluster.add( e );
        }
    }
    
    clusters.add( cluster );
    
    if ( clustersExpected == 0 )
    {
        java.util.Collections.sort( clusters, new java.util.Comparator(){
            public int compare ( Object a, Object b ) {
                return ((EventTimeCluster)a).from().compareTo( ((EventTimeCluster)b).from() );
            }
        } );
        currentCluster = clusters.get( 0 );
        loading = false;
    }
}
