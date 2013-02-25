class MovementData {
  
  IntListObject camLeft   = new IntListObject();
  IntListObject camRight  = new IntListObject();
  IntListObject camCenter = new IntListObject();

  MovementData(String _t, int _startIndex) {
    
    String[] parts = _t.split("_");
    String path = "movements/" + parts[1] + "_" + parts[0] + "_";
    
    int[] left   = int( loadStrings( path + "CamLeft/imageDifferences.txt" ) );
    int[] right  = int( loadStrings( path + "CamRight/imageDifferences.txt" ) );
    int[] center = int( loadStrings( path + "CamCenter/imageDifferences.txt" ) );
    
    for (int i=_startIndex; i<left.length; i++) {
      this.camLeft.add( left[i] );
      this.camRight.add( right[i] );
      this.camCenter.add( center[i] );
    }
  }
  
  MovementData() {
  }
  
  int length() {
    return camLeft.length();
  }
  
  float getTotal() {
    return (camLeft.total + camRight.total + camCenter.total) / 3.0f;
  }
  
  float getTotalAverage() {
    return (camLeft.average() + camRight.average() + camCenter.average()) / 3.0f;
  }
  
  float getAverage(int _i) {
    return (camLeft.get(_i) + camRight.get(_i) + camCenter.get(_i) ) /3.0f;
  }
  
  float getRangeAverage(int _i, int range){
    
    float v = 0.0;
    float skip = 0;
    
    for( int i=0; i<range; i++) {
      int n = i+_i;
      if (n<this.length()) v += this.getAverage(i+_i);
      else skip++;
    }
    v /= range-skip;
    return v;
  }
  
  float getHighestFromRange(int _i, int range){
    
    float v = 0.0;
    
    for( int i=0; i<range && i+_i<this.length(); i++) {
      float n = this.getAverage(i+_i);
      if (v < n) v = n;
    }
    return v;
  }
  
  int[] lengthAll() {
    int[] ar = new int[3];
    ar[0] = camLeft.length();
    ar[1] = camRight.length();
    ar[2] = camCenter.length();
    return ar;
  }
}
