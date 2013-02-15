void drawPositionsOnStage() {
  pushMatrix();
  translate(100,100);
  
  noFill();
  stroke(0);
  strokeWeight(1);
  
  
  int n = floor(255/float(videoSegments.length()));
  
  float sf = 50;
  /*
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);

    noStroke();
    
    
    for( int j=0; j<vSeg.positions.length; j++) {
      //float m = (vSeg.movements.camLeft.get(j) + vSeg.movements.camCenter.get(j) + vSeg.movements.camRight.get(j)) / 3;
      //if (j>20) println(m);
      PVector v = vSeg.positions[j];
      //fill(255,0,0);
      //ellipse( v.x*sf, v.y*sf, m*200, m*200 );
      ellipse( v.x*sf, v.y*sf, 200, 200 );
    }
    
  }
  */
  
  pushStyle();
  strokeJoin(ROUND);
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);
    int c = n*i;
    //if (c >= 250) c = 0;
    //stroke(color(c));
    stroke(255,0,0,80);
    
    noFill();
    beginShape();
    for( int j=0; j<vSeg.positions.length; j++) {
      float m = (vSeg.movements.camLeft.get(j) + vSeg.movements.camCenter.get(j) + vSeg.movements.camRight.get(j)) / 3;
      PVector v = vSeg.positions[j];
      strokeWeight(m*10);
      if (v.mag() != 0) vertex(v.x*sf,v.y*sf);
    }
    endShape();
  }
  popStyle();
  
  
  for( int i=0; i<videoSegments.length(); i++) {
    VideoSegment vSeg = videoSegments.get(i);
    
    int c = n*i;
    //if (c >= 250) c = 0;
    //stroke(color(c));
    //stroke(n*i);
    stroke(0);
    strokeWeight(1);
    noFill();
    beginShape();
    for( int j=0; j<vSeg.positions.length; j++) {
      PVector v = vSeg.positions[j];
      if (v.mag() != 0) vertex(v.x*sf,v.y*sf);
    }
    endShape();
  }
  
  
  popMatrix();
}
