void drawPerformerSegments () {
  
  float graphY = floor(height/3*2);
  float graphX = 100;
  float y = 0;
  float x = 0;
  
  float graphWidth = floor(width-200);
  float graphHeight = floor(height-200);
  float maxH = 1600;
  float gap = 30;
  float size = 140;
  
  float gx = 0;
  float gy = 0;
  
  float num = textSegments.length()+1;
  
  float valueAvg = 0.0;
  
  
  PerformerVideos pv = performers.get(performerIndex);
  println( "============== " + pv.name );
  
  pushStyle();
  fill(0);
  textAlign( LEFT );
  textSize(30);
  text(pv.name, 48, 40 );
  textSize(10);
  fill(0,0,255);
  //text("travel speed variance",48,60);
  text("traveled distance variance",48,60);
  fill(0);
  //text("\n(average travel speed per segment) - (average travel speed in each performance)",48,60);
  text("\ntotal distance traveled per segment minus the difference of the average across all performances",48,60);
  
  String st = "\n\ndistance traveled per performance:  ";
  for (int i=0; i<pv.length(); i++) {
    VideoObject v = pv.get(i);
    st += (i+1) +  ": " + floor(v.data.positions.total) + "m,  ";
  }
  
  
  
  
  popStyle();
  
  
  
  pushMatrix();
  
  translate(120,120);
  
  // explanation element
  
  stroke(150);
  strokeWeight(1);
  line(0,(size-30)/2 + 30,size,(size-30)/2 + 30);
  
  for (int j=0; j<pv.length(); j++) {
    VideoObject v = pv.get(j);
    valueAvg += v.data.positions.total;
    //valueAvg += v.segments.getSpeedTotalAverage();
    println("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& " + v.segments.getSpeedTotalAverage());
    
    x = j*(size/pv.length());
    stroke(200);
    strokeWeight(1);
    line(x,30,x,size);
    //line(x,0,x,size);
    stroke(255,0,0,50);
    line(x,(size-30)/2 + 30,-30,size-20);
    
    fill(255,0,0);
    textAlign(CENTER);
    text(j+1,x,(size-30)/2 + 30 -2);
  }
  
  valueAvg /= pv.length();
  println("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& valueAvg " + valueAvg);
  
  fill(255,0,0);
  textAlign(RIGHT);
  //text("average speed of\nperformance 1-7\nas x-axis",-15,size-5);
  text("average distance\ntraveled of\nperformance 1-7\nas x-axis",-15,size-5);
  
  gx = size + gap;
  
  for (int i=0; i<26; i++) {
    
    pushMatrix();
    
    translate(gx,gy);
    
    fill(0);
    textAlign(LEFT);
    text((i+1) + ": " + textSegments.get(i).marker,0,20);
    //text(textSegments.get(i).marker,0,-5);
    
    noFill();
    
    stroke(200);
    strokeWeight(1);
    
    
    // grid
    for (int j=0; j<pv.length(); j++) {
      x = j*(size/pv.length());
      line(x,30,x,size);
      //line(x,0,x,size);
    }
    
    
    
    stroke(0);
    strokeWeight(1);
    
    //beginShape();
    
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
    
    
    // AVERAGE MIDDLE LINE
    stroke(150);
    line(0,(size-30)/2 + 30,size,(size-30)/2 + 30);
    stroke(0,0,255);
    strokeWeight(3);
    
    /*
    beginShape();
    
    //println( "----- " + i );
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      
      float m0 = s.speeds.getAverage();
      float m1 = v.segments.getSpeedTotalAverage();
      //if(i<3 ) println("++++++++ " + i + " " + textSegments.get(i).marker + m0 + " " + m1);
      //y = map( m0-(m1-valueAvg), 0, 1, 0, size*10) + (size-30)/2 + 30;
      y = map( m0-m1, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      x = j*(size/pv.length());
      vertex(x,y);
      
      //println("seg: " + m0 + "  vid: " + (m1-valueAvg));
    }
    endShape();
    */
    
    
    beginShape();
    
    println( "----- " + i );
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject v = pv.get(j);
      VideoSegment s = v.segments.get(i);
      float m0 = (s.positions.total - (v.data.positions.total - valueAvg)) / v.data.positions.total;
      //float m1 = v.data.positions.total / v.segments.length();
      println("seg: " + s.positions.total + "  vid: " + (v.data.positions.total - valueAvg));
      y = map( m0, 0, 1, 0, size) + (size-30)/2 + 30;
      //y = map( m0, 0, 1, 0, -size*10) + (size-30)/2 + 30;
      x = j*(size/pv.length());
      vertex(x,y);
    }
    
    endShape();
    
    
    
    // ----------------------------------------------------
    // AVERAGE POSITION ON STAGE
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
    
    /*
    // ----------------------------------------------------
    // CONVEX HULLS
    pushStyle();
    
    fill(255,0,0,40);
    noStroke();
    
    for (int j=0; j<pv.length(); j++) {
      VideoObject vid = pv.get(j);
      VideoSegment s = vid.segments.get(i);
      
      Point2D[] hull = new Point2D[s.positions.length()+1];
      int number = nearHull2D( s.positions.getPoint2D(), hull );
      
      beginShape();
      for( int k=0; k<number; k+=1) {
        Point2D p = hull[k];
        if ( p == null ) break;
        else vertex(p.x/12*size,p.y/12*size);
      }
      endShape();
      
    }
    popStyle();
    
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
  
  st += "average: " + valueAvg + "m";
  
  fill(100);
  text(st,48,60);
}
