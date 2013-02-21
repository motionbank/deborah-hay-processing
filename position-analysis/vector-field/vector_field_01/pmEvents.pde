
void piecesLoaded ( Pieces pieces )
{
    loadingMessage = "Loading videos ...";
    
    if ( pieces.pieces.length > 0 ) {
        piece = pieces.pieces[0];
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
    
    boolean hasDataEvent = false;
    for ( org.piecemaker.models.Event e : events )
    {
        boolean isDataEvent = e.getEventType().equals("data");
        
        hasDataEvent = hasDataEvent || isDataEvent;
        
        c.addEvent( e );
        
        if ( isDataEvent )
        {
            try {
                org.json.JSONObject obj = new org.json.JSONObject( e.description );
                if ( trackFiles == null ) trackFiles = new ArrayList();
                String tf = obj.getString("file");
                
//                trackFiles.add( tf );
//                if ( tracks == null ) tracks = new ArrayList();
//                tracks.add( new ClusterTrack( c, tf ) );

                String[] lines = loadStrings( tracksBaseUrl + tf );
                Track3D track = new Track3D( c, e );
                c.track = track;
                
                float[][] trackRaw = new float[lines.length][0];
                
                for ( int i = 0; i < lines.length; i++ )
                {
                    String l = lines[i];
                    String[] vals = l.split(" ");
                    if ( vals != null && vals.length == 3 )
                    {
                        trackRaw[i] = new float[]{ float(vals[0]), float(vals[1]), float(vals[2]) };
                    }
                }
                
                trackRaw = fixZeroPoints( trackRaw );
                track.setData( trackRaw );
                track.applyToVectorField( field, fieldCounts, fieldWidth, fieldHeight );
                
            } catch ( Exception exc ) {
                exc.printStackTrace();
            }
        }
    }
    
    if ( hasDataEvent )
    {
        clustersTimeMin = clustersTimeMin > c.from.getTime() ? c.from.getTime() : clustersTimeMin;
        clustersTimeMax = clustersTimeMax < c.to.getTime()   ? c.to.getTime()   : clustersTimeMax;
        
        while ( clustersBusy ) { ; }
        clusters.add( c );
        java.util.Collections.sort( clusters, new java.util.Comparator (){
            public int compare ( Object a, Object b ) {
                return ((VideoTimeCluster)a).from.compareTo( ((VideoTimeCluster)b).from );
            }
        });
    }
    
    if ( clustersExpected == 0 ) 
    {
        updateVectorField();
        //addMoverGrid();
        loading = false;
    }
}

void updateVectorField ()
{
    float fieldLength;
    
    for ( int i = 0; i < field.length; i++ )
    {
        if ( fieldCounts[i] == 0 ) continue;
        
        field[i].div( fieldCounts[i] );
        //field[i].normalize();
        
        fieldLength = field[i].mag();
        
        fieldMean += fieldLength;
        fieldMin = min( fieldMin, fieldLength );
        fieldMax = max( fieldMax, fieldLength );
        
        fieldCountsMax = max( fieldCountsMax, fieldCounts[i] );
        fieldCountsMin = min( fieldCountsMin, fieldCounts[i] );
    }
    
    fieldMean /= field.length;
    println( fieldMin + " " + fieldMax );
}

void addMoverGrid ()
{
    for ( int ix = 0; ix < width; ix += fieldGrid*1.25 )
    {
        for ( int iy = 0; iy < height; iy += fieldGrid*1.25 )
        {
            movers.add( new Mover( ix, iy ) );
        }
    }
}

