
//------------------------------------------------------- DisplayObject
abstract class DisplayObject {
  public PVector position;
  public float   rotation;
  public color   fillColor;
  public float   scaleFactor = 1;
  DisplayObject() {
    position     = new PVector();
    rotation     = 0;
    fillColor    = color(255);
  }

  public void setPosition(float x, float y)   { this._setPosition(x,y); }
  public void setPosition(int x, int y)       { this._setPosition(float(x),float(y)); }
  private void _setPosition(float x, float y) { this.position.set(x,y,0.0); } 

  private void transform() {
    translate(this.position.x, this.position.y);
    scale(scaleFactor);
  }

  public void draw() {

  }

  public void setup() {
    
  }
}



//------------------------------------------------------- CircleDrawer < DisplayObject
class CircleDrawer extends DisplayObject {
  private float[] radiusAr;
  float radiusBase = 100;
  int   steps      = 30;
  float angleStart = 0;
  float angleEnd   = TWO_PI;
  float angleRange = TWO_PI;

  CircleDrawer() {
    
  }
  
  public void setRange( float s, float e) {
    this.angleStart = s;
    this.angleEnd   = e;
    this.angleRange = this.angleEnd - this.angleStart;
    if (this.angleRange > TWO_PI)  this.angleRange = TWO_PI;
    if (this.angleRange < -TWO_PI) this.angleRange = -TWO_PI;
    println(angleRange);
  }
  
  public void setSegmentRadius( float[] v ) {
    this.radiusAr = v;
    this.steps = v.length;
  }
  
  public void clearSegmentRadius() {
    this.radiusAr = null;
  }

  public void draw() {
    pushMatrix();
    super.transform();
    
    float angle = angleRange / steps;
    fill(this.fillColor);
    
    beginShape();
      vertex(0,0); // center
      //this.drawSegment(angleStart,radiusBase); // start
      
      for (int i=0; i<steps-1; i++) {
        float r = (radiusAr == null) ? radiusBase : radiusAr[i];
        this.drawSegment(i*angle+angleStart,r);
      }
      
      this.drawSegment(angleEnd, (radiusAr == null) ? radiusBase : radiusAr[steps-1] ); // end
    endShape(CLOSE);
    
    popMatrix();
  }
  private void drawSegment (float a, float r) { vertex( cos(a)*r, sin(a)*r); }
}

