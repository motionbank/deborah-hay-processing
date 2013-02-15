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
  
  float getTotalAverage() {
    return (camLeft.total + camRight.total + camCenter.total) /3;
  }
  
  int[] lengthAll() {
    int[] ar = new int[3];
    ar[0] = camLeft.length();
    ar[1] = camRight.length();
    ar[2] = camCenter.length();
    return ar;
  }
}
