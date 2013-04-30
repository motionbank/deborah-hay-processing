void drawPerformerPerformances () {
  
  float graphY = floor(height/3*2);
  float graphX = 100;
  float y = 0;
  float x = 0;
  float gx = 0;
  float gy = 0;
  float graphWidth = floor(width-200);
  float graphHeight = floor(height-200);
  float maxH = 1600;
  float gap = 60;
  float size = 250;
  
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
  
  
  for (int i=0; i<pv.length(); i++) {
    VideoObject vid = pv.get(i);
    
    pushMatrix();
    
    translate(gx,gy);
    
    fill(0);
    textAlign(LEFT);
    //text(textSegments.get(i).marker,0,20);
    text(vid.data.file.title,0,-5);
    
    noFill();
    
    stroke(200);
    strokeWeight(1);
    
    /*
    // grid
    for (int j=0; j<pv.length(); j++) {
      x = j*(size/pv.length());
      //line(x,30,x,size);
      line(x,0,x,size);
    }
    */
    
    
    stroke(0);
    
    pushStyle();
    beginShape();
    stroke(0,50);
    strokeWeight(1);
    
    
    
    for (int j=0; j<vid.segments.length(); j++) {
      VideoSegment s = vid.segments.get(j);
      PVector v = s.positions.getAverage();
      v.mult(size);
      float vx = v.x/12;
      float vy = v.y/12;    
      vertex(vx,vy);     
    }
    endShape();  
      
    CircleDrawer c = new CircleDrawer();
    
    for (int j=0; j<vid.segments.length(); j++) {
      VideoSegment s = vid.segments.get(j);
      PVector v = s.positions.getAverage();
      v.mult(size);
      float vx = v.x/12;
      float vy = v.y/12;
      if (j ==0) fill(0,255,0);
      else if (j==pv.length()-1) fill(0,0,255);
      else fill(255,0,0,50);
      
      
      vertex(vx,vy);
      
      pushStyle();
      stroke(255,0,0,100);
      ellipse(vx,vy,20,20);
      fill(0);
      textAlign(CENTER);
      text(j,vx,vy+5);
      /*
      c = new CircleDrawer();
      c.radiusBase = 10;
      c.setRange(-HALF_PI, j/float(vid.segments.length())*TWO_PI -HALF_PI);
      //c.setRange(-HALF_PI, PI);
      c.setPosition(vx,vy);
      c.fillColor = color(255,0,0,100);
      noStroke();
      c.draw();
      */
      popStyle();
      
      
    }
    popStyle();
    
    
    stroke(0,50);
    rect(0,0,size,size);
    
    
    
    popMatrix();
    
    gx += size+gap;
    if (gx+size > width-100) {
      gy += size+gap;
      gx = 0;
    }
  }
  
  popMatrix();
}
