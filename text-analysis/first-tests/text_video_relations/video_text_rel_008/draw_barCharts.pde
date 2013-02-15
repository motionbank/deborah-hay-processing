void drawBarCharts () {
  
  float maxL = 700;
  
   float segHeight = 20;
    float x = 0;
    float y = 0;
    float sw = width/5;
    float sh = textSegments.length() * segHeight;
    
    for (int i=0; i<textSegments.length(); i++) {
        
        TextSegment tSeg = textSegments.get(i);
        
        y = i * segHeight + 120;
        x = sw*2;
        
        pushStyle();
        
        noStroke();
        
        if (i%2 == 1) {
          fill(240);
          rect(50,y, width, segHeight);
        }
        
        // marker
        fill(0);
        textAlign(LEFT);
        text(tSeg.marker, 50, y+13);
        
        float h = segHeight - 2;
        
        // text seg
        x = sw;
        fill(255,0,0);
        float w = maxL*tSeg.relLength();
        rect(x, y+1, w, (h/3)-1);
        textAlign(RIGHT);
        
      //if ( i >= skipStartMarker ) {
        VideoSegment vSeg = videoSegments.get(i - skipStartMarker);
        
        // video seg
        //y += h + 1;
        x = sw;
        fill(0,0,255);
        w = maxL*vSeg.relLength();
        rect(x, y+1 + (h/3), w, (h/3)-1);
        textAlign(RIGHT);
        //text(vSeg.relLength(), x - 10, y);
        
        // traveled total
        x = sw;
        w = maxL* (vSeg.traveled / videoData.positions.total);
        fill(0,255,0);
        rect(x, y+1 + (h/3*2), w, (h/3)-1);
        
        
        // traveled vid diff
        x = sw*3;
        w = maxL*( (vSeg.traveled / videoData.positions.total) - vSeg.relLength() );
        if (w>0) fill(0,255,0);
        else fill(0,0,255);
        rect(x,y+1, w,h);
        
        // traveled text diff
        x = sw*4;
        w = maxL*( (vSeg.traveled / videoData.positions.total) - tSeg.relLength() );
        if (w>0) fill(0,255,0);
        else fill(255,0,0);
        rect(x,y+1, w,h);
        
        // difference
        w = maxL*(vSeg.relLength()-tSeg.relLength());
        x = sw*2;
        if (w>0) fill(0,0,255);
        else fill(255,0,0);
        rect(x,y+1, w,h);
        
        
        /*
        // left total
        x = sw*2;
        w = maxL* (vSeg.movements.camLeft.total / videoData.movements.camLeft.total);
        fill(0);
        rect(x,y+1, w,h);
        
        // center total
        w = maxL* (vSeg.movements.camCenter.total / videoData.movements.camCenter.total);
        x = sw*3;
        fill(0);
        rect(x,y+1, w,h);
        
        // right total
        x = sw*4;
        w = maxL* (vSeg.movements.camRight.total / videoData.movements.camRight.total);
        fill(0);
        rect(x,y+1, w,h);
        */
        
      /*} 
      else {
        // difference pseudo
        w = -maxL*tSeg.relLength();
        x = sw*2;
        fill(255,0,0);
        rect(x,y+1, w,h);
      }
      */
      popStyle();
    }
    
    stroke(0);
    strokeWeight(3);
    line(50,117,width,117);
    
    
    
    pushMatrix();
    translate(sw,90);
    textAlign( LEFT );
    fill(255,0,0);
    text( "text", 0, 0);
    fill(0,0,255);
    text( "video", 0, 12);
    fill(0,255,0);
    text( "distance", 0, 24);
    popMatrix();
    
    textAlign( LEFT );
    fill(0);
    text( "MARKER", 50, 90);
    textAlign(CENTER);
    //text( "TEXT - VIDEO", sw*2, 90);
    text( "CAM LEFT", sw*2, 90);
    //text( "VIDEO - DISTANCE", sw*3, 90);
    text( "CAM CENTER", sw*3, 90);
    //text( "TEXT - DISTANCE", sw*4, 90);
    text( "CAM RIGHT", sw*4, 90);
    
    /*
    y = segHeight * textSegments.length() + 150;
    x = sw*2;
    fill(100);
    textAlign( LEFT );
    text("Relation of the individual \ntext and video segments \nto the total length of the \nvideo and text respectively", x,y);
    x = sw*3;
    text("Defference between the \nlength of the matching \ntext and video segments", x,y);
    */
}
