void keyPressed() {
  println(keyCode);
  
  if (key == 's') {
    saveFrame(video.title + "_#####_3.png");
  }
  
  if (key == 'f') {
    drawFill = !drawFill;
    drawFrame = true;
  }
  
  if (key == '1') {
    peakConfig.drawText.toggle();
    drawFrame = true;
  }
  
  if (key == '2') {
    peakConfig.drawVidSegDur.toggle();
    drawFrame = true;
  }
  
  if (key == '3') {
    peakConfig.drawTraveled.toggle();
    drawFrame = true;
  }
  
  if (key == '4') {
    peakConfig.drawMovement.toggle();
    drawFrame = true;
  }
  
  if (keyCode == RIGHT) {
    drawFrame = true;
    drawMode += 1;
    if (drawMode >= 2) drawMode = 0;
    println("drawMode " + drawMode);
  }
}
