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
    videos = vids.videos;

    for (Video vid : videos) {
      if (vid.id == currentID) {
        video = vid;
        break;
      }
    }
    api.loadEventsForVideo( video.id, api.createCallback( "eventsLoaded") );
  }
}


void eventsLoaded ( Events evts )
{
  if (evts.events.length > 0 && evts != null) {
    events = evts.events;
    //println(events);

    loading = false;
    initData();
  }
  else {
    println("\t events: " + 0);
  }
}
