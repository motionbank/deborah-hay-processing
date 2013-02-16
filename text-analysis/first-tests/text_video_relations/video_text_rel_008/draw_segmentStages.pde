void drawSegmentStages() {
  pushMatrix();
  translate(100,100);
  
  noFill();
  stroke(0);
  strokeWeight(1);
  
  
  int n = floor(255/float(videoSegments.length()));
  
  //float sf = 50;
  float x = 0;
  float y = 0;
  float s = 150;
  float gap = 20;
  
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);
    
    pushMatrix();
    translate(x,y);
    rect(0,0,s,s);

    beginShape();
    for( int j=0; j<vSeg.positions.length; j++) {
      PVector v = vSeg.positions[j];
      if (v.mag() != 0) vertex(v.x/12*s,v.y/12*s);
    }
    endShape();
    
    popMatrix();
    
    x += s+gap;
    if (x+s > width-100) {
      y += s+gap;
      x = 0;
    }
  }
  
  popMatrix();
}
