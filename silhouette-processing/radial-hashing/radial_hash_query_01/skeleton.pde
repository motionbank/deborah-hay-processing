public class Skeleton
{
    float x, y;
    
    Point2D[] points;
    Bone2D[] bones;
    
    final int HEAD = 0, NECK = 1, CHEST = 2, PELVIS = 3, HIP_LEFT = 4, 
              HIP_RIGHT = 5, KNEE_LEFT = 6, KNEE_RIGHT = 7, ANKLE_LEFT = 8, ANKLE_RIGHT = 9, 
              TOES_LEFT = 10, TOES_RIGHT = 11, SHOULDER_LEFT = 12, SHOULDER_RIGHT = 13, ELBOW_LEFT = 14, 
              ELBOW_RIGHT = 15, WRIST_LEFT = 16, WRIST_RIGHT = 17, HAND_LEFT = 18, HAND_RIGHT = 19;
    
    Skeleton ( float _x, float _y )
    {
        x = _x;
        y = _y;
        
        Interactive.add( this );
        
        points = new Point2D[]{
            new Point2D(this,0,-450), new Point2D(this,0,-300), new Point2D(this,0,-200), new Point2D(this,0,-100), new Point2D(this,-85,0),
            new Point2D(this,85,0), new Point2D(this,-100,200), new Point2D(this,100,200), new Point2D(this,-100,400), new Point2D(this,100,400),
            new Point2D(this,-150,450), new Point2D(this,150,450), new Point2D(this,-100,-300), new Point2D(this,100,-300), new Point2D(this,-200,-200),
            new Point2D(this,200,-200), new Point2D(this,-250,-50), new Point2D(this,250,-50), new Point2D(this,-300,0), new Point2D(this,300,0),
        };
        for ( Point2D p : points )
        {
            p.x /= 2; p.y /= 2;
        }
        bones = new Bone2D[]{
            new Bone2D(points[HEAD],points[NECK]),
            new Bone2D(points[NECK],points[CHEST]),
            new Bone2D(points[SHOULDER_RIGHT],points[SHOULDER_LEFT]),
            new Bone2D(points[NECK],points[SHOULDER_LEFT]),
            new Bone2D(points[SHOULDER_LEFT],points[ELBOW_LEFT]),
            new Bone2D(points[ELBOW_LEFT],points[WRIST_LEFT]),
            new Bone2D(points[WRIST_LEFT],points[HAND_LEFT]),
            new Bone2D(points[NECK],points[SHOULDER_RIGHT]),
            new Bone2D(points[SHOULDER_RIGHT],points[ELBOW_RIGHT]),
            new Bone2D(points[ELBOW_RIGHT],points[WRIST_RIGHT]),
            new Bone2D(points[WRIST_RIGHT],points[HAND_RIGHT]),
            new Bone2D(points[CHEST],points[PELVIS]),
            new Bone2D(points[PELVIS],points[HIP_LEFT]),
            new Bone2D(points[HIP_LEFT],points[HIP_RIGHT]),
            new Bone2D(points[HIP_LEFT],points[KNEE_LEFT]),
            new Bone2D(points[KNEE_LEFT],points[ANKLE_LEFT]),
            new Bone2D(points[ANKLE_LEFT],points[TOES_LEFT]),
            new Bone2D(points[PELVIS],points[HIP_RIGHT]),
            new Bone2D(points[HIP_RIGHT],points[KNEE_RIGHT]),
            new Bone2D(points[KNEE_RIGHT],points[ANKLE_RIGHT]),
            new Bone2D(points[ANKLE_RIGHT],points[TOES_RIGHT]),
        };
        
        Interactive.on( points[NECK], "valueUpdated", this, "neckValueUpdated" );
        Interactive.on( new Object[]{ points[SHOULDER_LEFT], points[SHOULDER_RIGHT] }, "valueUpdated", this, "shoulderValueUpdated" );
    }
    
    void neckValueUpdated ()
    {
        Point2D c = centerBetween( points[SHOULDER_LEFT], points[SHOULDER_RIGHT] );
        c = points[NECK].clone().sub( c );
        points[SHOULDER_LEFT].add( c );
        points[SHOULDER_RIGHT].add( c );
    }
    
    void shoulderValueUpdated ()
    {
        Point2D c = centerBetween( points[SHOULDER_LEFT], points[SHOULDER_RIGHT] );
        c = points[NECK].clone().sub( c );
        points[SHOULDER_LEFT].add( c );
        points[SHOULDER_RIGHT].add( c );
    }
    
    void drawSkeleton ( PGraphics pg )
    {
        pg.noStroke();
        pg.fill( 200 );
        
        pg.ellipse( x+points[HEAD].x, y+points[HEAD].y, 70, 80 );
        
        drawBoxBetween( pg, points[HEAD], points[NECK], 30 );
        drawBoxBetween( pg, points[SHOULDER_LEFT], points[SHOULDER_RIGHT], 30 );
        
        drawBoxBetween( pg, centerBetween(points[SHOULDER_LEFT], points[SHOULDER_RIGHT]), points[CHEST], 100 );
        
        drawBoxBetween( pg, points[SHOULDER_LEFT], points[ELBOW_LEFT], 30 );
        drawBoxBetween( pg, points[ELBOW_LEFT], points[WRIST_LEFT], 25 );
        drawBoxBetween( pg, points[WRIST_LEFT], points[HAND_LEFT], 20 );
        
        drawBoxBetween( pg, points[SHOULDER_RIGHT], points[ELBOW_RIGHT], 30 );
        drawBoxBetween( pg, points[ELBOW_RIGHT], points[WRIST_RIGHT], 25 );
        drawBoxBetween( pg, points[WRIST_RIGHT], points[HAND_RIGHT], 20 );
        
        drawBoxBetween( pg, points[CHEST], points[PELVIS], 100 );
        drawBoxBetween( pg, centerBetween(points[HIP_LEFT], points[HIP_RIGHT]), points[PELVIS], 100 );
        drawBoxBetween( pg, points[HIP_LEFT], points[HIP_RIGHT], 30 );
        
        drawBoxBetween( pg, points[HIP_LEFT], points[KNEE_LEFT], 35 );
        drawBoxBetween( pg, points[KNEE_LEFT], points[ANKLE_LEFT], 25 );
        drawBoxBetween( pg, points[ANKLE_LEFT], points[TOES_LEFT], 20 );
        
        drawBoxBetween( pg, points[HIP_RIGHT], points[KNEE_RIGHT], 35 );
        drawBoxBetween( pg, points[KNEE_RIGHT], points[ANKLE_RIGHT], 25 );
        drawBoxBetween( pg, points[ANKLE_RIGHT], points[TOES_RIGHT], 20 );
        
        for ( int i = 0, k = bones.length; i < k; i++ )
        {
            bones[i].drawBone( pg );
        }
        for ( int i = 0, k = points.length; i < k; i++ )
        {
            points[i].drawPoint( pg );
        }
        
        pg.fill( 180 );
        pg.noStroke();
        pg.ellipse( x, y, 5, 5 );
    }
    
    void drawBoxBetween ( PGraphics pg, Point2D a, Point2D b, float s )
    {
        float r = atan2( a.y-b.y, a.x-b.x );
        pg.pushMatrix();
            pg.translate( x+b.x, y+b.y );
            pg.rotate( r );
            pg.rect( 0, -(s/2), dist(b.x, b.y, a.x, a.y), s );
        pg.popMatrix();
    }
    
    float[] getBoundingBox ()
    {
        float xmin = Float.MAX_VALUE, ymin = Float.MAX_VALUE;
        float xmax = Float.MIN_VALUE, ymax = Float.MIN_VALUE;
        
        for ( Point2D p : points )
        {
            xmin = xmin > (x+p.x) ? x+p.x : xmin;
            ymin = ymin > (y+p.y) ? y+p.y : ymin;
            xmax = xmax < (x+p.x) ? x+p.x : xmax;
            ymax = ymax < (y+p.y) ? y+p.y : ymax;
        }
        
        return new float[]{ xmin, ymin, xmax, ymax, xmin+(xmax-xmin)/2, ymin+(ymax-ymin)/2 };
    }
    
    Point2D centerBetween ( Point2D a, Point2D b )
    {
        return new Point2D( this, a.x + (b.x - a.x) / 2, a.y + (b.y - a.y) / 2 );
    }
    
    void mouseDragged ( float mx, float my )
    {
        x = mx; y = my;
    }
    
    boolean isInside ( float mx, float my )
    {
        return dist( mx, my, x, y ) < 10;
    }
}

class Bone2D
{
    Point2D from;
    Point2D to;
    
    Bone2D ( Point2D f, Point2D t )
    {
        from = f; 
        to = t;
    }
    
    void drawBone ( PGraphics pg )
    {
        pg.line( from.x, from.y, to.x, to.y );
    }
}

public class Point2D
{
    float x, y, wh = 5;
    boolean hover;
    
    Skeleton skeleton;
    
    Point2D ( Skeleton s, float _x, float _y )
    {
        x = _x; y = _y;
        skeleton = s;
        Interactive.add( this );
    }
    
    void mouseEntered ()
    {
        hover = true;
    }
    
    void mouseExited ()
    {
        hover = false;
    }
    
    void mouseDragged ( float mx, float my )
    {
        x = mx-skeleton.x;
        y = my-skeleton.y;
        
        Interactive.send( this, "valueUpdated" );
    }
    
    void drawPoint ( PGraphics pg )
    {
        pg.fill( hover ? color( 255,0,0 ) : 0 );
        pg.ellipse( x+skeleton.x, y+skeleton.y, 5, 5 );
    }
    
    Point2D clone ()
    {
        return new Point2D( skeleton, x, y );
    }
    
    Point2D sub ( Point2D other )
    {
        x -= other.x;
        y -= other.y;
        
        return this;
    }
    
    Point2D add ( Point2D other )
    {
        x += other.x;
        y += other.y;
        
        return this;
    }
    
    Point2D set ( Point2D other )
    {
        x = other.x;
        y = other.y;
        
        return this;
    }
    
    boolean isInside ( float mx, float my )
    {
        return dist( mx-skeleton.x, my-skeleton.y, x, y ) < wh;
    }
}
