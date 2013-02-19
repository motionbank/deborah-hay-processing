class PositionData {
  
  org.piecemaker.models.Event dataEvent;
  PVector[] positions = new PVector[0];
  String[] data;
  float total = 0;
  
  PositionData(String[] _data, int _startIndex) {
    
    this.data = _data;
    
    for ( int j = _startIndex; j<data.length; j++ ) {
      float[] f = parseFloat(split(data[j], " "));
      PVector v = new PVector(f[0],f[1],f[2]);
      
      if (positions.length > 1) {
        float l = positions[positions.length-2].dist(v);
        this.total += l;
      }
      this.positions = (PVector[]) append( this.positions, v );
    }
  }
  
  PVector get (int _i) {
    return positions[_i];
  }
  
  int length () {
    return positions.length;
  }
  
}
