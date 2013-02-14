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
}
