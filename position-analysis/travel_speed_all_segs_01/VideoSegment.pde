
class VideoSegmentList {
  
  VideoSegment[] segments;
  
  float mAvgTotal = -1;
  float speedAvgTotal = -1;

  VideoSegmentList( VideoData _vd ) {
    
    segments = new VideoSegment[_vd.sceneEvents.length];
    
    //-------------------------------------------------------------
    // CREATE VIDEO SEGMENTS
    
    for (int i=0; i<_vd.sceneEvents.length; i++) {
      org.piecemaker.models.Event evt = _vd.sceneEvents[i];
        
        // current event
        float eventLoc0 = (evt.getHappenedAt().getTime() - _vd.firstMarkerTime) / _vd.duration;
  
        // next event
        float eventLoc1 = 0;
        if (i < _vd.sceneEvents.length-1) eventLoc1 = (_vd.sceneEvents[i+1].getHappenedAt().getTime() - _vd.firstMarkerTime) / _vd.duration;
        else eventLoc1 = 1;
  
        float eventDur = eventLoc1 - eventLoc0;
         
        segments[i] = new VideoSegment( evt, eventDur, eventLoc0, eventLoc1);
    }
    
    
    //-------------------------------------------------------------
    // POSITION & MOVEMENT PER SEGMENT
    
    int num = 0;
    int i0 = 0;
    
    println("seg length " + _vd.file.id + " " + segments.length);
    
    
    
    /*
     *   position and movement data should have the same amount of values
     */
     
    PositionData ps = _vd.positions;
    //MovementData ms = _vd.movements;
    SpeedData    ss = _vd.speeds;
    //int[] la = ms.lengthAll();
    //println("mov data " + la[0] + " " + la[1] + " " + la[2] + " / pos data " + ps.length() );
    
    for (int i=0; i<segments.length; i++) {
      VideoSegment s = segments[i];
      
      int                                                 i1 = i0 + round(s.duration * ps.length());
      if (i == segments.length-1 || i1 > ps.length()-1)   i1 = ps.length()-1;
      if (i0 > ps.length()-1)                             i0 = ps.length()-1;
      
      //println(i + "\t" + i0 + "\t" + i1 + "\t" + (positions.length-1) );
      
      // add positions and movements from i0 to i1 to the current video segment
      for (int j=i0; j<=i1; j++) {
        s.positions.add( ps.get(j) );
        //s.movements.camLeft.add( ms.camLeft.get(j) );
        //s.movements.camRight.add( ms.camRight.get(j) );
        //s.movements.camCenter.add( ms.camCenter.get(j) );
        s.speeds.add( ss.get(j) );
      }
      num += s.positions.length();
      
      i0 = i1 + 1;
      
      s.speeds.checkEmpty();
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
  

  float getSpeedTotalAverage() {
    
    if (speedAvgTotal == -1){
      speedAvgTotal = 0.0;
      
      for (int i=0; i<this.segments.length; i++) {
        speedAvgTotal += segments[i].speeds.getAverage();
      }
      speedAvgTotal /= this.segments.length;
      return speedAvgTotal;
    }
    else return speedAvgTotal;
  }
}


class VideoSegment {
  
  org.piecemaker.models.Event event;
  
  PositionData positions = new PositionData();
  SpeedData    speeds    = new SpeedData();
  
  float duration;
  float start;
  float end;
  
  VideoSegment( org.piecemaker.models.Event _event, float _dur, float _s, float _e ) {
    this.event = _event;
    this.duration = _dur;
    this.start = _s;
    this.end = _e;
  }
  
  float relLength() {
    return duration;
  }
}

