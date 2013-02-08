
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
        titleClusters = new ArrayList();
        
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
int column = 0;

void eventsLoaded ( Events evts, VideoTimeCluster cluster )
{
    clustersExpected--;
    
    loadingMessage = "Loading "+clustersExpected+" clusters ...";
    
    if ( evts == null ) return;
    if ( cluster == null ) return;
    
    org.piecemaker.models.Event[] events = evts.events;
    
    if ( events == null || events.length == 0 ) return;
    
    boolean hasLinkToPortal = false;
    
    for ( org.piecemaker.models.Event e : events )
    {
        if ( e.getEventType().equals("scene") ) cluster.addEvent( e );
        
        hasLinkToPortal = hasLinkToPortal || e.title.equals( "link to portal" );
    }
    
    if ( !hasLinkToPortal ) return; // skip if not has that marker
    clusters.add( cluster );
    
    Collections.sort( clusters, new Comparator<VideoTimeCluster>(){
        public int compare ( VideoTimeCluster a, VideoTimeCluster b ) 
        {
            if ( a.performer.equals( b.performer ) )
                return a.from.compareTo( b.from );
            else
                return a.performer.compareTo( b.performer );
        }
    });
    
    for ( VideoTimeCluster c : clusters )
    {
        ArrayList<String> eventTitles = new ArrayList();
        
        org.piecemaker.models.Event originEvent = null, endEvent = null;
        
        for ( org.piecemaker.models.Event e : c.events )
        {
            if ( e.title.equals( "link to portal" ) )
            {
                originEvent = e;
            }
            else if ( e.title.equals( "end" ) )
            {
                endEvent = e;
            }
        }
        
        if ( originEvent == null || endEvent == null )
        {
            System.err.println( "ORIGIN or END event missing!" );
            exit();
            return;
        }
        
        long o = originEvent.getHappenedAt().getTime();
        float s = endEvent.getHappenedAt().getTime() - o;
        
        ArrayList<Integer> times = new ArrayList(), 
        timesNormalized = new ArrayList();
        
        for ( org.piecemaker.models.Event e : c.events )
        {
            if ( e.title.indexOf("voice") >= 0 ) continue;
            
            String et = e.title;
            int i = 2;
            while( eventTitles.contains(et) ) 
            {
                et = e.title + " #" + i;
                i++;
            }
            eventTitles.add( et );
            
            EventTitleCluster etc = null;
            for ( EventTitleCluster tc : titleClusters )
            {
                if ( tc.title.equals( et ) )
                {
                    etc = tc;
                    break;
                }
            }
            if ( etc == null )
            {
                etc = new EventTitleCluster( et );
                titleClusters.add( etc );
            }
            
            int time = (int)( e.getHappenedAt().getTime() - o );
            int timeNorm = int((time / s) * 1000);
            
            etc.addEvent( time, timeNorm, e, column );
            times.add( time );
            timesNormalized.add( timeNorm );
            
            minTimeNormalized = (int)min( timeNorm, minTimeNormalized );
            minTime = (int)min( time, minTime );
            maxTime = (int)max( time, maxTime );
        }
        
        c.times = times;
        c.timesNormalized = timesNormalized;
        
        maxEvents = (int)max(c.events.size(),maxEvents);
        column++;
    }
    
    Collections.sort( titleClusters, new Comparator<EventTitleCluster>(){
        public int compare ( EventTitleCluster a, EventTitleCluster b ) {
            return a.minTime - b.minTime;
        } 
    });
    
    if ( clustersExpected == 0 ) 
    {
        loading = false;
    }
}

