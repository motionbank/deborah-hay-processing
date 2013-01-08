
class VideoSegmentList {
  
  VideoSegment[] segments;

  VideoSegmentList( org.piecemaker.models.Event[] _events ) {
    
    segments = new VideoSegment[0];
    
    // EVENTS
    for (int i=0; i<_events.length; i++) {
      org.piecemaker.models.Event evt = _events[i];
  
      if (evt.getEventType().equals("scene")) {
        long vidHappened = video.getHappenedAt().getTime();
        float vidDuration = video.getDuration()*1000;
        //float vidDuration = events[events.length-1].getHappenedAt().getTime() - vidHappened;
        
        
        // current event
        //float eventLoc0 = map( evt.getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        float eventLoc0 = (evt.getHappenedAt().getTime() - vidHappened) / vidDuration;
  
        // next event
        float eventLoc1 = 0;
        //if (i<events.length-1) eventLoc1 = map( events[i+1].getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        if (i<_events.length-1) eventLoc1 = (_events[i+1].getHappenedAt().getTime() - vidHappened) / vidDuration;
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
         
        this.add( new VideoSegment( evt, eventDur ) );
      }
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

