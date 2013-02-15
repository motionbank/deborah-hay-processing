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
  
  
  pushStyle();
  strokeJoin(ROUND);
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);
    
    pushMatrix();
    translate(x,y);
    stroke(0);
    strokeWeight(1);
    rect(0,0,s,s);
    
    pushStyle();
    stroke(255,0,0,80);
    
    noFill();
    beginShape();
    for( int j=0; j<vSeg.positions.length(); j++) {
      float m = (vSeg.movements.camLeft.get(j) + vSeg.movements.camCenter.get(j) + vSeg.movements.camRight.get(j)) / 3;
      PVector v = vSeg.positions.get(j);
      strokeWeight(m*10);
      if (v.mag() != 0) vertex(v.x/12*s,v.y/12*s);
    }
    endShape();
    popStyle();
    popMatrix();
    
    x += s+gap;
    if (x+s > width-100) {
      y += s+gap;
      x = 0;
    }
  }
  popStyle();
  
  
  x = 0;
  y = 0;
  
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);
    
    pushMatrix();
    translate(x,y);

    beginShape();
    for( int j=0; j<vSeg.positions.length(); j++) {
      PVector v = vSeg.positions.get(j);
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
