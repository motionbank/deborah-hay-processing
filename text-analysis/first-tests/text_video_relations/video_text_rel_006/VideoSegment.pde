
class VideoSegmentList {
  
  VideoSegment[] segments;
  PVector[] positions;
  org.piecemaker.models.Event[] sceneEvents;
  org.piecemaker.models.Event[] pathEvents;

  VideoSegmentList( org.piecemaker.models.Event[] _events ) {
    
    this.sceneEvents = new org.piecemaker.models.Event[0];
    this.pathEvents = new org.piecemaker.models.Event[0];
    
    // EVENTS
    for (int i=0; i<_events.length; i++) {
      org.piecemaker.models.Event evt = _events[i];
      
      if (evt.getEventType().equals("scene") || evt.getEventType().equals("scenefaux")) {
        // 
        sceneEvents = (org.piecemaker.models.Event[]) append( sceneEvents, evt );
      }
      else if (evt.getEventType().equals("data")) {
        pathEvents = (org.piecemaker.models.Event[]) append( pathEvents, evt );
      }
    }
    
    segments = new VideoSegment[sceneEvents.length];
    
    //-------------------------------------------------------------
    // SCENE EVENTS
    
    org.piecemaker.models.Event firstEvent = sceneEvents[0];
    org.piecemaker.models.Event lastEvent = sceneEvents[sceneEvents.length-1];
    
    long vidHappened = firstEvent.getHappenedAt().getTime();
    videoDuration = lastEvent.getHappenedAt().getTime() - firstEvent.getHappenedAt().getTime();
    //long vidHappened = video.getHappenedAt().getTime();
    
    
    for (int i=0; i<sceneEvents.length; i++) {
      org.piecemaker.models.Event evt = sceneEvents[i];
      
        //float vidDuration = video.getDuration()*1000;
        //float vidDuration = events[events.length-1].getHappenedAt().getTime() - vidHappened;
        
        
        // current event
        //float eventLoc0 = map( evt.getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        float eventLoc0 = (evt.getHappenedAt().getTime() - vidHappened) / videoDuration;
  
        // next event
        float eventLoc1 = 0;
        //if (i<events.length-1) eventLoc1 = map( events[i+1].getHappenedAt().getTime() - video.getHappenedAt().getTime(), 0, video.getDuration()*1000, 0, 1 );
        if (i<sceneEvents.length-1) eventLoc1 = (sceneEvents[i+1].getHappenedAt().getTime() - vidHappened) / videoDuration;
        else eventLoc1 = 1;
  
        float eventDur = eventLoc1 - eventLoc0;
        
        
        /*
                println(evt.title);

        println("eha: " + evt.getHappenedAt().getTime());
        println("vha: " + vidHappened);
        println("dif: " + (evt.getHappenedAt().getTime() - vidHappened));
        println("vdu: " + vidDuration);
        println("edu: " + eventDur);
        println("loc0: " + eventLoc0);
        println("loc1: " + eventLoc1 + "\n");
        */
         
        segments[i] = new VideoSegment( evt, eventDur, eventLoc0, eventLoc1);
    }
    
    
    //-------------------------------------------------------------
    // PATH EVENTS
    
    for (int i=0; i<pathEvents.length; i++) {
      org.piecemaker.models.Event evt = pathEvents[i];
      String pathFile = evt.description.substring(7,evt.description.length());
      pathFile = pathFile.substring(0,pathFile.indexOf('"'));
      String[] pathData = loadStrings( "http://lab.motionbank.org/dhay/data/" + pathFile);
      
      positions = new PVector[pathData.length];
      println("3D positions " + pathData.length);
      
      for (int j=0; j<positions.length; j++) {
        float[] f = parseFloat(split(pathData[j], " "));
        PVector v = new PVector(f[0],f[1],f[2]);
        positions[j] = v;
        traveledTotal += v.mag();
      }
      
      println("3- positions " + positions.length);
    }
    
    println("total movement " + traveledTotal);
    
    //-------------------------------------------------------------
    // POSITION PER SEGMENT
    
    int num = 0;
    int i0 = 0;
    
    println("seg length " + segments.length);
    
    for (int i=0; i<segments.length; i++) {
      VideoSegment s = segments[i];
      int i1 = i0 + round(s.duration * positions.length);
      if (i == segments.length-1 || i1 > positions.length-1) i1 = positions.length-1;
      if (i0 > positions.length-1) i0 = positions.length-1;
      
      println(i + "\t" + i0 + "\t" + i1 + "\t" + (positions.length-1) );
      
      for (int j=i0; j<=i1; j++) {
        s.addPosition( positions[j] );
      }
      num += s.positions.length;
      
      i0 = i1 + 1;
    }
    println("-- positions " + num);
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
  PVector[] positions = new PVector[0];
  float duration;
  float start;
  float end;
  float traveled = 0;
  
  VideoSegment( org.piecemaker.models.Event _event, float _dur, float _s, float _e ) {
    this.event = _event;
    this.duration = _dur;
    this.start = _s;
    this.end = _e;
    
  }
  
  void addPosition (PVector _p) {
    this.positions = (PVector[]) append( this.positions, _p );
    this.traveled += _p.mag() / traveledTotal;
  }
  
  float relLength() {
    return duration;
  }
}

