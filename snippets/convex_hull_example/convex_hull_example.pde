/** 
 *    Motion Bank research, http://motionbank.org/
 *
 *    Processing 2.0
 *    fjenett 20130305
 */
 
 Point2D[] pointsClicked;
 
 void setup ()
 {
     size( 500, 500 );
 }
 
 void draw ()
 {
     background( 255 );
     noFill();
     
     if ( pointsClicked != null && pointsClicked.length > 2 )
     {
         for ( Point2D p : pointsClicked )
         {
             ellipse( p.x, p.y, 5, 5 );
         }
         
         Point2D[] hull = new Point2D[pointsClicked.length+1];
         int num = nearHull2D( pointsClicked, hull );
         
         beginShape();
         for ( Point2D p : hull )
         {
             if ( p == null ) break;
             vertex( p.x, p.y );
         }
         endShape();
     }
 }
 
 void mousePressed ()
 {
     if ( pointsClicked == null )
     {
         pointsClicked = new Point2D[0];
     }
     pointsClicked = (Point2D[])append( pointsClicked, new Point2D( mouseX, mouseY ) );
 }
