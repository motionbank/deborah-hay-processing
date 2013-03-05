void drawSegmentStages() {
  
  
  
  //int n = floor(255/float(videoSegments.length()));
  
  //float sf = 50;
  float x = 0;
  float y = 0;
  float s = 140;
  
  float gap = 30;
  float sf = 2.5;
  
  VideoObject vid = videos.get(idx);
  
  pushStyle();
  fill(0);
  textAlign( LEFT );
  textSize(30);
  text(vid.data.file.title, 48, 40 );
  textSize(10);
  text(TITLE,48,60);
  popStyle();
  
  pushMatrix();
  translate(100,100);
  
  pushStyle();
  strokeJoin(ROUND);
  
  
  float steps = 5;
  
  
  for( int i=0; i<vid.segments.length(); i++) {
    VideoSegment vSeg = vid.segments.get(i);
    
    pushMatrix();
    translate(x,y);
    
    fill(0);
    textAlign(LEFT);
    //text(textSegments.get(i).marker,0,20);
    text(textSegments.get(i).marker,0,-5);
    
    stroke(200);
    strokeWeight(1);
    for(int j=1; j<=steps; j++) {
      line(s/steps*j,0,s/steps*j,s);
      line(0,s/steps*j,s,s/steps*j);
    }
    
    pushStyle();
    stroke(255,0,0);
    strokeWeight(3);
    noFill();
    
    float lastPx = 0.0;
    float lastPy = 0.0;
    
    beginShape();
    for( int j=0; j<vSeg.positions.length(); j++) {
      PVector p = vSeg.positions.get(j);
      float px = floor(p.x/12*steps);
      float py = floor(p.y/12*steps);
      if (px > steps-1) px = steps-1;
      if (py > steps-1) py = steps-1;
      if (px < 0) px = 0;
      if (py < 0) py = 0;
      //ellipse(px * s/3 + s/6,py * s/3 + s/6,10,10);
      if (px != lastPx || py != lastPy) vertex(px * s/steps + s/(steps*2.0),py * s/steps + s/(steps*2.0));
      lastPx = px;
      lastPy = py;
    }
    endShape();
    
    noFill();
    stroke(0);
    strokeWeight(1);
    rect(0,0,s,s);
    
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
  
  /*
  // POSITION PATH
  
  for( int i=0; i<vid.segments.length(); i++) {
    VideoSegment vSeg = vid.segments.get(i);
    TextSegment tSeg = textSegments.get(i);
    
    pushMatrix();
    translate(x,y);
    
    fill(0);
    textAlign(LEFT);
    text(tSeg.marker,0,-6);
    
    noFill();
    stroke(0);
    strokeWeight(1);
    rect(0,0,s,s);
    
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
  */
  
  popMatrix();
  
}
