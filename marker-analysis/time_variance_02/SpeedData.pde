class SpeedData {
  
  ArrayList<Float> data = new ArrayList<Float>();
  float total = 0;
  float average = -1;
  float minValue = Float.MAX_VALUE;
  float maxValue = Float.MIN_VALUE; 
  
  SpeedData(String[] _data, int _startIndex) {
        
    for ( int j = _startIndex; j<_data.length; j++ ) {
      float f = parseFloat(_data[j]);
      this.data.add( f );
      minValue = min( minValue, f );
      maxValue = max( maxValue, f );
    }
  }
  
  SpeedData() {
  }
  
  void add (float _v) {
    this.data.add(_v);
    minValue = min( minValue, _v );
    maxValue = max( maxValue, _v );
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
  
  void checkEmpty(){
    if (data.size() < 50) {
      data = new ArrayList<Float>();
      data.add(0.0);
    }
  }
  
  float[] toFloatArray(){
      float[] ar = new float[data.size()];
      for (int i=0; i<ar.length; i++) {
         ar[i] = data.get(i); 
      }
      return ar;
  }
  
}
