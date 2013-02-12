
class VideoSegmentList {
  
  VideoSegment[] segments;
  PVector[] positions;
  org.piecemaker.models.Event[] sceneEvents;
  org.piecemaker.models.Event[] pathEvents;

  VideoSegmentList( org.piecemaker.models.Event[] _events ) {
    
    this.sceneEvents = new org.piecemaker.models.Event[0];
    this.pathEvents = new org.piecemaker.models.Event[0];
    
    //-------------------------------------------------------------
    // FILTER ALL EVENTS
    
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
    
    for (int i=0; i<sceneEvents.length; i++) {
      org.piecemaker.models.Event evt = sceneEvents[i];
        
        // current event
        float eventLoc0 = (evt.getHappenedAt().getTime() - vidHappened) / videoDuration;
  
        // next event
        float eventLoc1 = 0;
        if (i<sceneEvents.length-1) eventLoc1 = (sceneEvents[i+1].getHappenedAt().getTime() - vidHappened) / videoDuration;
        else eventLoc1 = 1;
  
        float eventDur = eventLoc1 - eventLoc0;
         
        segments[i] = new VideoSegment( evt, eventDur, eventLoc0, eventLoc1);
    }
    
    
    //-------------------------------------------------------------
    // POSITION (DATA) EVENTS
    
    for (int i=0; i<pathEvents.length; i++) {
      org.piecemaker.models.Event evt = pathEvents[i];
      String positionsFile = evt.description.substring(7,evt.description.length());
      positionsFile = positionsFile.substring(0,positionsFile.indexOf('"'));
      String[] pathData = loadStrings( DATA_URL + positionsFile);
      
      positions = new PVector[0];
      println("3D positions " + pathData.length);
      
      // match first position with first scene marker in the video
      float firstMarkerRel = (firstEvent.getHappenedAt().getTime() - video.getHappenedAt().getTime()) / (video.getDuration()*1000);
      int startIndex = floor( firstMarkerRel * pathData.length );
      
      // TESTING OUTPUTS ------
      /*
      for (int j=0; j<pathData.length; j++) {
        float[] f = parseFloat(split(pathData[j], " "));
        PVector v = new PVector(f[0],f[1],f[2]);
        
        if (j<250 && j>100) {
          if (j==startIndex) println("\t" + v);
          else println(v);
        }
      }
      */
      // ----------------------
      
      
      for (int j=startIndex; j<pathData.length; j++) {
        float[] f = parseFloat(split(pathData[j], " "));
        PVector v = new PVector(f[0],f[1],f[2]);
        
        if (positions.length > 1) {
          float l = positions[positions.length-2].dist(v);
          traveledTotal += l;
        }
        this.positions = (PVector[]) append( this.positions, v );
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
      
      //println(i + "\t" + i0 + "\t" + i1 + "\t" + (positions.length-1) );
      
      // add positions from i0 to i1 to the current video segment
      
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
    
    if (positions.length > 1) {
      float l = positions[positions.length-2].dist(_p);
      this.traveled += l / traveledTotal;
    }
    
    this.positions = (PVector[]) append( this.positions, _p );
    
  }
  
  float relLength() {
    return duration;
  }
}

