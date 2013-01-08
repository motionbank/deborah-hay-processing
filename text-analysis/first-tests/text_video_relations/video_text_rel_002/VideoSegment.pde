
class VideoSegmentList {
  
  VideoSegment[] segments;
  org.piecemaker.models.Event[] sceneEvents;

  VideoSegmentList( org.piecemaker.models.Event[] _events ) {
    
    this.sceneEvents = new org.piecemaker.models.Event[0];
    
    // EVENTS
    for (int i=0; i<_events.length; i++) {
      org.piecemaker.models.Event evt = _events[i];
      
      if (evt.getEventType().equals("scene")) {
        sceneEvents = (org.piecemaker.models.Event[]) append( sceneEvents, evt );
      }
    }
    
    segments = new VideoSegment[sceneEvents.length];
    
    for (int i=0; i<sceneEvents.length; i++) {
      org.piecemaker.models.Event evt = sceneEvents[i];
      
        long vidHappened = video.getHappenedAt().getTime();
        float vidDuration = video.getDuration()*1000;
        //float vidDuration = events[events.length-1].getHappenedAt().getTime() - vidHappened;
        
        
        // current event
        //float eventLoc0 = map( evt.getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        float eventLoc0 = (evt.getHappenedAt().getTime() - vidHappened) / vidDuration;
  
        // next event
        float eventLoc1 = 0;
        //if (i<events.length-1) eventLoc1 = map( events[i+1].getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        if (i<sceneEvents.length-1) eventLoc1 = (sceneEvents[i+1].getHappenedAt().getTime() - vidHappened) / vidDuration;
        else eventLoc1 = 1;
  
        float eventDur = eventLoc1 - eventLoc0;
        
        
        println(evt.title);
        /*
        println("eha: " + evt.getHappenedAt().getTime());
        println("vha: " + vidHappened);
        println("dif: " + (evt.getHappenedAt().getTime() - vidHappened));
        println("vdu: " + vidDuration);
        println("edu: " + eventDur);
        println("loc0: " + eventLoc0);
        println("loc1: " + eventLoc1 + "\n");
        */
         
        segments[i] = new VideoSegment( evt, eventDur );
    }
  }
  
  void add (VideoSegment _v) {
    segments = (VideoSegment[]) append( segments, _v );
  }
  
  VideoSegment get (int _i) {
    return (VideoSegment) segments[_i];
  }
  
  int length() {
    return segments.length;
  }
}


class VideoSegment {
  
  org.piecemaker.models.Event event;
  float duration;
  
  VideoSegment( org.piecemaker.models.Event _event, float _dur ) {
    this.event = _event;
    this.duration = _dur;
  }
  
  float relLength() {
    return duration;
  }
}

