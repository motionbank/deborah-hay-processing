void drawSegmentStages() {
  
  pushMatrix();
  translate(100,100);
  
  //int n = floor(255/float(videoSegments.length()));
  
  //float sf = 50;
  float x = 0;
  float y = 0;
  float s = 140;
  
  float gap = 30;
  int steps = 10;
  float sf = 2.5;
  
  VideoObject vid = videos.get(0);
  
  
  pushStyle();
  strokeJoin(ROUND);
  
  for( int i=0; i<vid.segments.length(); i++) {
    VideoSegment vSeg = vid.segments.get(i);
    
    pushMatrix();
    translate(x,y);
    
    pushStyle();
    fill(255,0,0,20);
    noStroke();
    
    Point2D[] hull = new Point2D[vSeg.positions.length()+1];
    int num = nearHull2D( vSeg.positions.getPoint2D(), hull );
    
    beginShape();
    for( int j=0; j<hull.length; j+=1) {
      Point2D p = hull[j];
      if ( p == null ) break;
      else vertex(p.x/12*s,p.y/12*s);
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
  
  popMatrix();
  
}
