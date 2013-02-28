void drawOnePerformer () {
  
  float graphY = floor(height/3*2);
  float graphX = 100;
  float y = 0;
  float x = 0;
  float gx = 0;
  float gy = 0;
  float graphWidth = floor(width-200);
  float graphHeight = floor(height-200);
  float maxH = 1600;
  float gap = 30;
  float size = 140;
  
  float num = textSegments.length()+1;
  
  
  PerformerVideos pv = performers.get(performerIndex);
  
  pushStyle();
  textAlign( LEFT );
  textSize(30);
  text(pv.name, 48, 40 );
  textSize(10);
  text(TITLE,48,60);
  popStyle();
  
  
  
  pushMatrix();
  
  translate(100,100);
  
  
  for (int i=0; i<26; i++) {
    
    pushMatrix();
    
    translate(gx,gy);
    
    fill(0);
    textAlign(LEFT);
    text(textSegments.get(i).marker,0,20);
    
    noFill();
    
    stroke(200);
    strokeWeight(1);
    
    for (int j=0; j<pv.length(); j++) {
      x = j*(size/pv.length());
      line(x,30,x,size);
    }
    
    
    stroke(0);
    strokeWeight(1);
    
    beginShape();
    
    /*
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      float m0 = s.movements.getTotalAverage();
      float m1 = v.segments.getMovementTotalAverage();
      y = map( m0/m1, 0, 1, 0, -size*3) + size;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    */
    
    /*
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      float m0 = s.duration;
      //float m1 = v.data.duration;
      //println("++++++++ " + m0 + " " + m1);
      y = map( m0, 0, 1, 0, -size*3) + size;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    */
    
    stroke(200);
    line(0,(size-30)/2 + 30,size,(size-30)/2 + 30);
    stroke(0);
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      float m0 = s.speeds.getAverage();
      float m1 = v.data.speeds.getAverage();
      if(i==0) println("++++++++ " + textSegments.get(i).marker + m0 + " " + m1);
      y = map( m0-m1, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    
    endShape();
    
    popMatrix();
    
    gx += size+gap;
    if (gx+size > width-100) {
      gy += size+gap;
      gx = 0;
    }
  }
  
  popMatrix();
}
