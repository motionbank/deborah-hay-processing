void drawPerformerSegments () {
  
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
  fill(0);
  textAlign( LEFT );
  textSize(30);
  text(pv.name, 48, 40 );
  textSize(10);
  text(TITLE,48,60);
  popStyle();
  
  
  
  pushMatrix();
  
  translate(100,120);
  
  
  for (int i=0; i<26; i++) {
    
    pushMatrix();
    
    translate(gx,gy);
    
    fill(0);
    textAlign(LEFT);
    //text(textSegments.get(i).marker,0,20);
    text(textSegments.get(i).marker,0,-5);
    
    noFill();
    
    stroke(200);
    strokeWeight(1);
    
    
    // grid
    for (int j=0; j<pv.length(); j++) {
      x = j*(size/pv.length());
      //line(x,30,x,size);
      line(x,0,x,size);
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
      float m1 = v.segments.getSpeedTotalAverage();
      if(i==25) println("++++++++ " + textSegments.get(i).marker + m0 + " " + m1);
      y = map( m0-m1, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      //y = map( m0, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      float m0 = s.positions.total;
      float m1 = v.data.positions.total;
      y = map( m0/m1, 0, 1, 0, -size*3) + size;
      //y = map( m0, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    
    endShape();
    
    /*
    beginShape();
    pushStyle();
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject vid = pv.get(j);
      VideoSegment s = vid.segments.get(i);
      PVector v = s.positions.getAverage();
      println("++++++++ " + v.x + v.y);
      v.mult(size);
      float vx = v.x/12;
      float vy = v.y/12;
      if (j ==0) fill(0,255,0);
      else if (j==pv.length()-1) fill(0,0,255,50);
      else fill(255,0,0,50);
      ellipse(vx,vy,10,10);
      vertex(vx,vy);
    }
    popStyle();
    endShape();
    
    rect(0,0,size,size);
    */
    
    
    popMatrix();
    
    gx += size+gap;
    if (gx+size > width-100) {
      gy += size+gap;
      gx = 0;
    }
  }
  
  popMatrix();
}
