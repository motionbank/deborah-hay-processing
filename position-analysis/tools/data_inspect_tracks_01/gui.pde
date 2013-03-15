public class InvisibleInteractiveArea
{
    float x, y, width, height;
    float pressedX, pressedY;
    boolean on = false;
    
    InvisibleInteractiveArea ( float xx, float yy, float ww, float hh )
    {
        x = xx;
        y = yy;
        width = ww;
        height = hh;
        
        Interactive.add( this );
    }
    
    void mouseEntered ()
    {
        on = true;
    }
    
    void mouseExited ()
    {
        on = false;
    }
    
    void mousePressed ( float mx, float my )
    {
        Interactive.send( this, "clickedArea", mx-x, my-y );
    }
    
    void mouseDragged ( float mx, float my, float dx, float dy )
    {
        Interactive.send( this, "draggedArea", mx-x, my-y );
    }
    
    void mouseScrolled ( float v )
    {
        Interactive.send( this, "scrolledArea", v );
    }
    
    void draw ()
    {
        if ( on )
        {
//            noFill();
//            stroke( 255, 0, 0 );
//            rect( x, y, width, height );
        }
    }
}

public class MultiSlider
{
    float x,y,width,height;
    float pressedX, pressedY;
    float pressedXLeft, pressedYLeft, pressedXRight, pressedYRight;
    boolean on = false;
    
    SliderHandle left, right, activeHandle;
    
    float values[];
    
    MultiSlider ( float xx, float yy, float ww, float hh )
    {
        this.x = xx; this.y = yy; this.width = ww; this.height = hh;
        
        left  = new SliderHandle( x, y, height, height );
        right = new SliderHandle( x+width-height, y, height, height );
        
        values = new float[]{0,1};
        
        Interactive.add( this );
    }
    
    void set ( float v1, float v2 )
    {
        left.x  = map( v1, 0, 1, x, x+width-left.width );
        right.x = map( v2, 0, 1, x, x+width-right.width );
        values[0] = v1;
        values[1] = v2;
        Interactive.send( this, "leftValueChanged",  values[0] );
        Interactive.send( this, "rightValueChanged", values[1] );
    }
    
    void mouseEntered ()
    {
        on = true;
    }
    
    void mouseExited ()
    {
        on = false;
    }
    
    void mousePressed ( float mx, float my )
    {
        if ( left.isInside( mx, my ) )       activeHandle = left;
        else if ( right.isInside( mx, my ) ) activeHandle = right;
        else                                 activeHandle = null;
        
        pressedX = mx;
        pressedXLeft  = left.x;
        pressedXRight = right.x;
    }
    
    void mouseDragged ( float mx, float my )
    {
        float vx = mx - left.width/2;
        vx = constrain( vx, x, x+width-left.width );
        
        if ( activeHandle == left )
        {
            if ( vx > right.x - (left.width / 2) ) 
            {
                if ( vx + (right.width / 2) < x + width - right.width )
                {
                    right.x = vx + (right.width / 2);
                    values[1] = map( right.x, x, x+width-left.width, 0, 1 );
                    Interactive.send( this, "rightValueChanged", values[1] );
                }
                else
                {
                    vx = right.x - left.width;
                }
            }
            values[0] = map( vx, x, x+width-left.width, 0, 1 );
            
            Interactive.send( this, "leftValueChanged", values[0] );
        }
        else if ( activeHandle == right )
        {
            if ( vx < left.x + (left.width / 2) )
            {
                if ( vx - (left.width / 2) > x )
                {
                    left.x = vx - (left.width / 2);
                    values[0] = map( left.x, x, x+width-left.width, 0, 1 );
                    Interactive.send( this, "leftValueChanged", values[0] );
                }
                else
                {
                    vx = left.x + left.width;
                }
            }
            values[1] = map( vx, x, x+width-left.width, 0, 1 );
            
            Interactive.send( this, "rightValueChanged", values[1] );
        }
        else // dragging in between handles
        {
            float dx = mx-pressedX;
            
            if ( pressedXLeft + dx >= x && pressedXRight + dx <= x+(width-right.width) )
            {
                values[0] = map( pressedXLeft + dx,  x, x+width-left.width, 0, 1 );
                left.x = pressedXLeft + dx;
                
                values[1] = map( pressedXRight + dx, x, x+width-left.width, 0, 1 );
                right.x = pressedXRight + dx;
                
                Interactive.send( this, "leftValueChanged",  values[0] );
                Interactive.send( this, "rightValueChanged", values[1] );
            }
        }
        
        if ( activeHandle != null ) activeHandle.x = vx;
    }
    
    void draw ()
    {
        noStroke();
        fill( col1 );
        rect( x, y, width, height );
        fill( on ? 200 : 220 );
        rect( left.x, left.y, right.x-left.x+right.width, right.height );
    }
    
    public boolean isInside ( float mx, float my )
    {
        return left.isInside(mx,my) || right.isInside(mx,my) || Interactive.insideRect( left.x, left.y, (right.x+right.width)-left.x, height, mx, my );
    }
}

class SliderHandle
{
    float x,y,width,height;
    
    SliderHandle ( float xx, float yy, float ww, float hh )
    {
        this.x = xx; this.y = yy; this.width = ww; this.height = hh;
    }
    
    void draw ()
    {
        rect( x, y, width, height );
    }
    
    public boolean isInside ( float mx, float my )
    {
        return Interactive.insideRect( x, y, width, height, mx, my );
    }
}

public class Slider
{
    float x, y, width, height;
    float valueX = 0, value;
    
    Slider ( float xx, float yy, float ww, float hh ) 
    {
        x = xx; 
        y = yy; 
        width = ww; 
        height = hh;
        
        valueX = x;
    
        Interactive.add( this );
    }
    
    void mouseDragged ( float mx, float my )
    {
        valueX = mx - height/2;
        
        if ( valueX < x ) valueX = x;
        if ( valueX > x+width-height ) valueX = x+width-height;
        
        value = map( valueX, x, x+width-height, 0, 1 );
        
        Interactive.send( this, "valueChanged", value );
    }
    
    public void draw ()
    {
        noStroke();
        
        fill( 100 );
        rect( x, y, width, height );
        
        fill( 120 );
        rect( valueX, y, height, height );
    }
}
