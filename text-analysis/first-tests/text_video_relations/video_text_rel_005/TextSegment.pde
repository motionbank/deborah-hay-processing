class TextSegmentList {
  
  TextSegment[] segments;

    TextSegmentList() {
      segments = new TextSegment[0];
    }
    
    void add( TextSegment _t ) {
      segments = (TextSegment[]) append( segments, _t );
    }
    
    TextSegment get(int _i) {
      return (TextSegment) segments[_i];
    }
  
    int length() {
      return segments.length;
    }
} 


class TextSegment {

    String text = "";
    String marker = "";
    int startIndex = 0;
    int endIndex = 0;
    int length = 0;

    Counter<String> words;

    TextSegment( String _marker, String _text, int _si) {

        this.marker = _marker;
        this.text = _text;
        this.startIndex = _si;
        this.length = split(_text, " ").length;
        
        // if text tag is empty the length is 1. manual correction for now
        if (this.length == 1) this.length = 0;
        
        this.endIndex = _si + this.length;

        // count body parts
        this.words = new Counter<String>();

        for ( String w : new WordIterator(this.text) ) {
            this.words.note(w);
        }
    }
    
    float relLength() {
      if (this.length > 0) return float(this.length) / float(nttfLength);
      else return 0;
    }
}

