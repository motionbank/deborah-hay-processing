class PositionData {
  
  org.piecemaker.models.Event dataEvent;
  ArrayList<PVector> positions = new ArrayList<PVector>();
  String[] data;
  float total = 0;
  
  Point2D[] point2D = null;
  
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
  
  PVector getAverage() {
    float x = 0.0;
    float y = 0.0;
    float z = 0.0;
    float s = this.positions.size();
    
    for (int i=0; i<s; i++) {
      PVector v = this.positions.get(i);
      x += v.x;
      y += v.y;
      z += v.z;
    }
    x /= s;
    y /= s;
    z /= s;
    println("========= " + s + " " + x + " " + y + " " + z);
    return new PVector(x,y,z);
  }
  
  PVector getLast () {
    PVector v = new PVector(0,0);
    for (int i=this.length()-1; i>0;i--) {
      v = this.get(i);
      if (v.mag() > 0) break;
    }
    return v;
  }
  
  Point2D[] getPoint2D() {
    if (point2D == null) {
      
      point2D = new Point2D[positions.size()];
      
      for (int i=0; i<point2D.length;i++) {
        PVector v = this.get(i);
        point2D[i] = new Point2D(v.x,v.y);
      }
    }
    
    return point2D;
  }
  
  int length () {
    return positions.size();
  }
  
  
}
