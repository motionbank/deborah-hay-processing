class MovementData {
  
  int[] camLeft   = new int[0];
  int[] camRight  = new int[0];
  int[] camCenter = new int[0];
  
  MovementData(String _t, int _startIndex) {
    
    String[] parts = _t.split("_");
    String path = "movements/" + parts[1] + "_" + parts[0] + "_";
    
    int[] left   = int( loadStrings( path + "CamLeft/imageDifferences.txt" ) );
    int[] right  = int( loadStrings( path + "CamRight/imageDifferences.txt" ) );
    int[] center = int( loadStrings( path + "CamCenter/imageDifferences.txt" ) );
    
    for (int i=_startIndex; i<left.length; i++) {
      this.camLeft   = (int[]) append( this.camLeft, left[i] );
      this.camRight  = (int[]) append( this.camRight, right[i] );
      this.camCenter = (int[]) append( this.camCenter, center[i] );
    }
    
    println(">>>>>>>> movement " + camLeft.length + " " + camCenter.length + " " + camRight.length);
  }
}
