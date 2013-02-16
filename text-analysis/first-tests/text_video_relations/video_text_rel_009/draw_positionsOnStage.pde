void drawPositionsOnStage() {
  pushMatrix();
  translate(100,100);
  
  noFill();
  stroke(0);
  strokeWeight(1);
  
  int steps = 10;
  
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
  
  
  /*
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
    for( int j=0; j<vSeg.positions.length(); j++) {
      float m = (vSeg.movements.camLeft.get(j));// + vSeg.movements.camCenter.get(j) + vSeg.movements.camRight.get(j)) / 3.0f;
      if (i==0) println("m: " + m);
      PVector v = vSeg.positions.get(j);
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
    for( int j=0; j<vSeg.positions.length(); j++) {
      PVector v = vSeg.positions.get(j);
      if (v.mag() != 0) vertex(v.x*sf,v.y*sf);
    }
    endShape();
  }
  */
  
  
  PositionData ps = videoData.positions;
  
  pushStyle();
  strokeJoin(ROUND);
  noFill();
  
  for( int i=0; i<ps.length(); i+=1) {
    PVector v = ps.get(i);
    //float m = videoData.movements.getHighestFromRange(i,steps);
    float m = videoData.movements.getAverage(i);
    fill(255,0,0,20);
    noStroke();
    if (v.mag() != 0) ellipse(v.x*sf,v.y*sf,m*5.0f,m*5.0f);
  }
  popStyle();
  
  
  beginShape();
  stroke(0);
  strokeWeight(1);
  noFill();
  
  for( int i=0; i<ps.length(); i++) {
    PVector v = ps.get(i);
    if (v.mag() != 0) vertex(v.x*sf,v.y*sf);
  }
  endShape();
  
  PVector v = ps.getFirst();
  stroke(0,0,255);
  strokeWeight(2);
  ellipse(v.x*sf,v.y*sf,10,10);
  
  v = ps.getLast();
  stroke(0,255,0);
  strokeWeight(2);
  ellipse(v.x*sf,v.y*sf,10,10);
  
  popMatrix();
}
