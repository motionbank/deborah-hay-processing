void keyPressed() {
  println(keyCode);
  
  if (key == 's') {
    saveFrame(video.title + "_#####_3.png");
  }
  
  if (keyCode == RIGHT) {
    drawFrame = true;
    drawMode += 1;
    if (drawMode >= 2) drawMode = 0;
    println("drawMode " + drawMode);
  }
}
