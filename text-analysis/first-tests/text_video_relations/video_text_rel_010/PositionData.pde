class PositionData {
  
  org.piecemaker.models.Event dataEvent;
  ArrayList<PVector> positions = new ArrayList<PVector>();
  String[] data;
  float total = 0;
  
  PositionData(String[] _data, int _startIndex) {
    
    this.data = _data;
    
    for ( int j = _startIndex; j<data.length; j++ ) {
      float[] f = parseFloat(split(data[j], " "));
      PVector v = new PVector(f[0],f[1],f[2]);
      
      this.add(v);
    }
  }
  
  PositionData() {
  }
  
  void add (PVector _p) {
    if (positions.size() > 1) {
      this.total += positions.get(positions.size()-2).dist(_p);
    }
    this.positions.add(_p);
  }
  
  PVector get (int _i) {
    return positions.get(_i);
  }
  
  PVector getFirst () {
    PVector v = new PVector(0,0);
    for (int i=0; i<this.length();i++) {
      v = this.get(i);
      if (v.mag() > 0) break;
    }
    return v;
  }
  
  PVector getLast () {
    PVector v = new PVector(0,0);
    for (int i=this.length()-1; i>0;i--) {
      v = this.get(i);
      if (v.mag() > 0) break;
    }
    return v;
  }
  
  int length () {
    return positions.size();
  }
  
  
}
