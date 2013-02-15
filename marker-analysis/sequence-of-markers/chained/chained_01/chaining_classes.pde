
/**
 *    A Chain is a sequence of nodes in a certain order
 */
class Chain
{
    ArrayList<ChainNode> nodes;
    
    Chain ()
    {
        nodes = new ArrayList();
    }
    
    void add ( ChainNode n )
    {
        nodes.add( n );
    }
}

/**
 *    A ChainLink is a link between two nodes
 */
class ChainLink
{
    ChainNode from;
    ChainNode to;
    int total = 0;
    ChainLink inverse;
    
    ChainLink ( ChainNode fn, ChainNode tn )
    {
        from = fn;
        to = tn;
        total = 1;
        
        from.addLinkOut( this );
        to.addLinkIn( this );
    }
    
    void inc ()
    {
        total++;
    }
    
    void draw ()
    {
        float a = atan2( to.y-from.y, to.x-from.x );
        float d = dist( from.x, from.y, to.x, to.y );
    
        stroke( 0 );
        strokeWeight( total * 0.2 );
        noFill();
            
        pushMatrix();
            translate( from.x, from.y );
            rotate( a );
            if ( inverse != null )
            {
                translate( 0, 5 );
            }
            line( 0,0, d,0 );
            translate( d/2,0 );
            beginShape();
                vertex( 0, -5 );
                vertex( 5, 0 );
                vertex( 0, 5 );
            endShape();
        popMatrix();
    }
    
    public boolean equals ( Object other )
    {
        return from.equals( ((ChainLink)other).from ) && to.equals( ((ChainLink)other).to );
    }
    
    boolean isInverseOf ( ChainLink other )
    {
        return from.equals( other.to ) && to.equals( other.from );
    }
    
    boolean intersectsWith ( ChainLink other )
    {
        ChainNode p1 = from, p2 = to, p3 = other.from, p4 = other.to;
        double t  = ((p4.y - p3.y)*(p2.x - p1.x) - (p4.x - p3.x)*(p2.y - p1.y));
        double ua = ((p4.x - p3.x)*(p1.y - p3.y) - (p4.y - p3.y)*(p1.x - p3.x)) / t;
        double ub = ((p2.x - p1.x)*(p1.y - p3.y) - (p2.y - p1.y)*(p1.x - p3.x)) / t;
        
        boolean intersect = ua > 0 && ua < 1 && ub > 0 && ub < 1;
//        if ( intersect )
//        {
//            println(String.format("%s %s %s %s", p1, p2, p3, p4));
//            println( ua + " " + ub );
//        }
        return intersect;
    }
}

/**
 *    A ChainNode is a node that represents an event in the sequence
 */
public class ChainNode
{
    String label;
    int total = 0;
    float y = 0, x = 0;
    float orderSum = 0;
    int order = -1;
    boolean pressed;
    
    ArrayList<ChainLink> linksIn, linksOut;
    
    ChainNode ( String l )
    {
        label = l;
        //Interactive.add( this );
    }
    
    void inc ()
    {
        total++;
    }
    
    int getOrder ()
    {
        if ( order == -1 ) order = (int)round(orderSum/total);
        return order;
    }
    
    void setOrder( int i )
    {
        order = i;
    }
    
    void addLinkIn ( ChainLink ln )
    {
        addLink( ln, true );
    }
    
    void addLinkOut ( ChainLink ln )
    {
        addLink( ln, false );
    }
    
    void addLink ( ChainLink ln, boolean in )
    {
        ArrayList<ChainLink> links = in ? linksIn : linksOut;
        if ( links == null ) 
        {
            if ( in )
                links = linksIn = new ArrayList();
            else 
                links = linksOut = new ArrayList();
            
            links.add( ln );
            return;
        }
        for ( ChainLink lk : links )
        {
            if ( lk.equals( ln ) ) return;
        }
        links.add( ln );
    }
    
    void mousePressed ()
    {
        pressed = true;
    }
    
    void mouseReleased ()
    {
        pressed = false;
    }
    
    void mouseDragged ( float mx, float my, float dx, float dy )
    {
        x = mx;
        y = my;
    }
    
    void draw ()
    {
        drawLabel( label, x, y );
    }
    
    String toString ()
    {
        return String.format( "%s", label );
    }
    
    boolean isInside ( float mx, float my )
    {
        float txtWidth = textWidth( label ) / 2;
        float txtHeight = g.textSize / 2;
        return mx > x-txtWidth && mx < x+txtWidth && my > y-txtHeight && my < y+txtHeight;
    }
}

 void drawLabel ( String label, float x, float y )
 {
     color labelColor = 255;
     float txtWidth = textWidth( label );
     float txtHeight = g.textSize;
     
     stroke( 0 );
     
     pushMatrix();
        translate( x, y+txtHeight/2 );
        
        fill( labelColor );
        strokeWeight( 1 );
        beginShape();
        vertex(       -txtWidth/2,             -txtHeight-2 );
        vertex(        txtWidth/2,             -txtHeight-2 );
        bezierVertex(  txtWidth/2 + txtHeight, -txtHeight-2, 
                       txtWidth/2 + txtHeight,  txtHeight/2, 
                       txtWidth/2,              txtHeight/2 );
        vertex(       -txtWidth/2,              txtHeight/2  );
        bezierVertex( -txtWidth/2 - txtHeight,  txtHeight/2, 
                      -txtWidth/2 - txtHeight, -txtHeight-2, 
                      -txtWidth/2,             -txtHeight-2  );
        endShape(CLOSE);
        
        fill( 0 );
        textAlign( CENTER );
        text( label, 0,0 );
    popMatrix();
 }
