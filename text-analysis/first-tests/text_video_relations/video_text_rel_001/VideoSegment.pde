class VideoSegmentList {
  
  VideoSegment[] segments;

  VideoSegmentList() {
    segments = new VideoSegment[0];
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

