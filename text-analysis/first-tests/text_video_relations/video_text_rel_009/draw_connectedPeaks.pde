class PeakConfig {
  
  ConfigObject drawText       = new ConfigObject(true);
  ConfigObject drawVidSegDur  = new ConfigObject(true);
  ConfigObject drawTraveled   = new ConfigObject(true);
  ConfigObject drawMovement   = new ConfigObject(true);
  
  PeakConfig() {
    
  }
}


void drawConnectedPeaks() {
  
  float graphY = floor(height/3*2);
  float graphX = 100;
  float y = 0;
  float x = 0;
  float graphWidth = floor(width-200);
  float maxH = 1600;
  
  float num = textSegments.length()+1;
  
  
  pushMatrix();
  pushStyle();
  
  translate(graphX,graphY);
  
  stroke(0);
  strokeWeight(1);
  line(0,0,graphWidth,0);
  
  y = 0;
  
  for (int i=0; i<num-1; i++) {
    fill(0);
    noStroke();
    x = (i+1) * graphWidth/(num-1);
    ellipse(x,y,3,3);
  }
  
  for (int i=0; i<textSegments.length(); i++) {
     TextSegment tSeg = textSegments.get(i);
     x = (i+1) * graphWidth/(num-1);
     
     pushMatrix();
     fill(0);
     translate(x-5,10);
     rotate(PI/3);
     textAlign(LEFT);
     text("" + (i+1) + ". " + tSeg.marker, 0, 0);
     popMatrix();
  }
  
  
  //-----------------------------
  // TEXT SEGMENTS
  
  if (peakConfig.drawText.isTrue()) {
    beginShape();
    
    stroke(255,0,0);
    strokeWeight(1);
    if (drawFill) fill(255,0,0,100);
    else noFill();
    
    vertex(0,0);
    
    for (int i=0; i<textSegments.length(); i++) {
       TextSegment tSeg = textSegments.get(i);
       
       y = -(tSeg.relLength() * maxH);
       x = (i+1) * graphWidth/(num-1);
       
       pushStyle();
       fill(255,0,0);
       noStroke();
       ellipse(x,y,3,3);
       
       popStyle();
       
       vertex(x,y);
    }
    vertex(graphWidth,0);
    
    endShape();
  }
  
  //-----------------------------
  // VIDEO SEGMENTS
  
  // rel length
  
  if (peakConfig.drawVidSegDur.isTrue()) {
    beginShape();
    
    stroke(0,0,255);
    strokeWeight(1);
    if (drawFill) fill(0,0,255,100);
    else noFill();
    
    vertex(0,0);
    
    for (int i=0; i<videoSegments.length(); i++) {
       VideoSegment vSeg = videoSegments.get(i);
       
       y = -(vSeg.duration * maxH);
       x = (i+1) * graphWidth/(num-1);
       
       pushStyle();
       fill(0,0,255);
       noStroke();
       ellipse(x,y,3,3);
       popStyle();
       
       vertex(x,y);
    }
    vertex(graphWidth,0);
    
    endShape();
  }
  
  // travaled
  
  if (peakConfig.drawTraveled.isTrue()) {
    beginShape();
    
    stroke(0,255,0);
    strokeWeight(1);
    if (drawFill) fill(0,255,0,100);
    else noFill();
    
    vertex(0,0);
    
    for (int i=0; i<videoSegments.length(); i++) {
       VideoSegment vSeg = videoSegments.get(i);
       
       y = -( (vSeg.positions.total / videoData.positions.total) * maxH );
       x = (i+1) * graphWidth/(num-1);
       
       pushStyle();
       fill(0,255,0);
       noStroke();
       ellipse(x,y,3,3);
       popStyle();
       
       vertex(x,y);
    }
    vertex(graphWidth,0);
    
    endShape();
  }
  
  
  // movement
  
  if (peakConfig.drawMovement.isTrue()) {
    beginShape();
    
    stroke(255,255,0);
    strokeWeight(1);
    if (drawFill) fill(255,255,0,100);
    else noFill();
    
    vertex(0,0);
    
    for (int i=0; i<videoSegments.length(); i++) {
       VideoSegment vSeg = videoSegments.get(i);
       
       y = -( (vSeg.movements.getTotalAverage() / videoData.movements.getTotalAverage()) * maxH );
       x = (i+1) * graphWidth/(num-1);
       
       pushStyle();
       fill(255,255,0);
       noStroke();
       ellipse(x,y,3,3);
       popStyle();
       
       vertex(x,y);
    }
    vertex(graphWidth,0);
    
    endShape();
  }
  
  
  popStyle();
  popMatrix();
  
  // legende
  pushMatrix();

  translate(48, 60);
  
  textAlign(LEFT);
  rectMode(CORNER);
  
  fill(255,0,0,100);
  stroke(255,0,0);
  strokeWeight(1);
  rect(0,0,10,10);  
  
  fill(0,0,255,100);
  stroke(0,0,255);
  strokeWeight(1);
  rect(0,25,10,10);  
  
  fill(0,255,0,100);
  stroke(0,255,0);
  strokeWeight(1);
  rect(0,50,10,10);
  
  fill(255,255,0,100);
  stroke(255,255,0);
  strokeWeight(1);
  rect(0,75,10,10);
  
  fill(0);
  translate(20,5);
  text("text segment length relative to total text length",0,5);
  text("video segment duration relative to total video duration",0,30);
  text("distance travaled per video segment relative to total distance travaled",0,55);
  text("movement per video segment relative to total movement during the performance",0,80);
  
  popMatrix();
  
  text("1 - 4:", width-300, 65 );
  text("toggle graphs", width-180, 65 );
}
