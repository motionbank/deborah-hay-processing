void drawConvexSingles() {
  
  
  
  //int n = floor(255/float(videoSegments.length()));
  
  //float sf = 50;
  float x = 0;
  float y = 0;
  float s = 140;
  
  float gap = 30;
  float sf = 2.5;
  
  VideoObject vid = videos.get(idx);
  
  Point2D[] hullTotal = new Point2D[vid.data.positions.length()+1];
  int numberTotal = nearHull2D( vid.data.positions.getPoint2D(), hullTotal );
  
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
  
  pushMatrix();
  translate(x,y);
  
  fill(0);
  textAlign(LEFT);
  text("Performance",0,-6);
  
  for( int i=0; i<vid.segments.length(); i++) {
    VideoSegment vSeg = vid.segments.get(i);
    
    
    fill(255,0,0,50);
    noStroke();
    
      Point2D[] hull = new Point2D[vSeg.positions.length()+1];
      int number = nearHull2D( vSeg.positions.getPoint2D(), hull );
      
      beginShape();
      for( int k=0; k<number; k+=1) {
        Point2D p = hull[k];
        if ( p == null ) break;
        else vertex(p.x/12*s,p.y/12*s);
      }
      endShape();
      
      noFill();
      stroke(0,0,255);
      strokeWeight(2);
      
      
  }
  
  beginShape();
  noFill();
  stroke(0,0,255);
  strokeWeight(1);
  for( int k=0; k<numberTotal; k+=1) {
    Point2D p = hullTotal[k];
    if ( p == null ) break;
    else vertex(p.x/12*s,p.y/12*s);  
  }
  endShape();
  
  noFill();
  stroke(0);
  strokeWeight(1);
  rect(0,0,s,s);
  
  popMatrix();
  
  x = s + gap;
  y = 0;
  
  
  for( int i=0; i<vid.segments.length(); i++) {
    VideoSegment vSeg = vid.segments.get(i);
    TextSegment tSeg = textSegments.get(i);
    
    pushMatrix();
    translate(x,y);
    
    fill(0);
    textAlign(LEFT);
    text((i+1) + ": " + tSeg.marker,0,-6);
    
    
      Point2D[] hull = new Point2D[vSeg.positions.length()+1];
      int number = nearHull2D( vSeg.positions.getPoint2D(), hull );
      
      fill(255,0,0,50);
      noStroke();
      
      beginShape();
      for( int k=0; k<number; k+=1) {
        Point2D p = hull[k];
        if ( p == null ) break;
        else vertex(p.x/12*s,p.y/12*s);
      }
      endShape();
      
      noFill();
      stroke(0,0,255);
      strokeWeight(1);
      
      beginShape();
      for( int k=0; k<numberTotal; k+=1) {
        Point2D p = hullTotal[k];
        if ( p == null ) break;
        else vertex(p.x/12*s,p.y/12*s);
      }
      endShape();
    
    
    noFill();
    stroke(0);
    strokeWeight(1);
    rect(0,0,s,s);
    
    popMatrix();
    
    x += s+gap;
    if (x+s > width-100) {
      y += s+gap;
      x = 0;
    }
  }
  
  
  
  popMatrix();
  
}
