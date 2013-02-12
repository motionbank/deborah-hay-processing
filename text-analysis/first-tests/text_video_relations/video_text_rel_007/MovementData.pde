class MovementData {
  
  int[] camLeft;
  int[] camRight;
  int[] camCenter;
  
  MovementData(String _t, int _startIndex) {
    
    String[] parts = _t.split("_");
    String path = "movements/" + parts[1] + "_" + parts[0] + "_";
    
    this.camLeft   = int( loadStrings( path + "CamLeft/imageDifferences.txt" ) );
    this.camRight  = int( loadStrings( path + "CamRight/imageDifferences.txt" ) );
    this.camCenter = int( loadStrings( path + "CamCenter/imageDifferences.txt" ) );
    
    println(">>>>>>>> movement " + camLeft.length + " " + camCenter.length + " " + camRight.length);
  }
}
