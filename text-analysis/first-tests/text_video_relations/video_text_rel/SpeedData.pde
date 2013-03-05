class SpeedData {
  
  ArrayList<Float> data = new ArrayList<Float>();
  float total = 0;
  float average = -1;
  
  SpeedData(String[] _data, int _startIndex) {
        
    for ( int j = _startIndex; j<_data.length; j++ ) {
      this.data.add( parseFloat(_data[j]) );
    }
  }
  
  SpeedData() {
  }
  
  void add (float _v) {
    this.data.add(_v);
  }
  
  float get (int _i) {
    return data.get(_i);
  }
  
  float getAverage() {
    float _a = 0.0;
    for (int i=0; i<data.size(); i++) {
      _a += data.get(i);
    }
    _a /= data.size();
    return _a; 
  }
  
  int length () {
    return data.size();
  }
  
  
}
