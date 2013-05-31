void piecesLoaded ( Pieces pieces )
{
    loadingMessage = "Loading videos ...";

    if ( pieces.pieces.length > 0 ) {
        piece = pieces.pieces[0];
        api.loadVideosForPiece( piece.id, api.createCallback( "videosLoaded") );
    }
}

void videosLoaded ( Videos vids )
{
    loadingMessage = "Loading events ...";

    if ( vids.videos.length > 0 ) {

        for (int id : videoIDs) {

            for (Video vid : vids.videos) {

                if (vid.id == id) {
                    toLoad++;
                    api.loadEventsForVideo( vid.id, api.createCallback( "eventsLoaded", vid) );
                }
            }
        }
    }
}

/*
void loadVideo( int _i ) {
 
 println("loading video " + _i);
 
 for (Video vid : videos) {
 if (vid.id == _i) {
 video = vid;
 break;
 }
 }
 api.loadEventsForVideo( video.id, api.createCallback( "eventsLoaded") );
 }
 */


void eventsLoaded ( Events evts, Video _vid )
{
    if (evts.events.length > 0 && evts != null) {
        println("- video " + _vid.id + " loaded");
        //events = evts.events;
        //println(events);

        videos.add(_vid, evts.events);

        toLoad--;
        println("> to load " + toLoad);

        if (toLoad == 0) {
            println("- - all videos loaded");
            loading = false;

            videos.sort();
            println("- - - init data");
            initData();
            performers.sort();
        }
    }
    else {
        println("\t events: " + 0);
    }
}

