void keyPressed() {
  println(keyCode);
  
  if (key == 's') {
    saveFrame("image_difference_variance3_" + performers.get(performerIndex).name + ".png");
  }
  
  
  if (key == 'f') {
    drawFill = !drawFill;
    drawFrame = true;
  }
  
  if (keyCode == UP) {
    drawFrame = true;
    performerIndex += 1;
    if (performerIndex > 2) performerIndex = 0;
  }
  
  if (keyCode == RIGHT) {
    drawFrame = true;
    drawMode += 1;
    if (drawMode > 3) drawMode = 0;
    println("drawMode " + drawMode);
  }
  
  if (keyCode == LEFT) {
    drawFrame = true;
    drawMode -= 1;
    if (drawMode < 0) drawMode = 3;
    println("drawMode " + drawMode);
  }
}
