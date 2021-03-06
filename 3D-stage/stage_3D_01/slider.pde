
public class Slider
{
    float x, y, width, height;
    float valueX = 0, value;
    
    Slider ( float xx, float yy, float ww, float hh ) 
    {
        x = xx; y = yy; width = ww; height = hh;
        
        Interactive.add( this );
    }
    
    void setValue ( float v )
    {
        value = v;
        valueX = v*(width-height);
    }
    
    void mouseDragged ( float mx, float my )
    {
        valueX = mx - height/2;
        
        if ( valueX < 0 ) valueX = 0;
        if ( valueX > width-height ) valueX = width-height;
        
        value = map( valueX, 0, width-height, 0, 1 );
        
        updateCurrentFrame( value );
    }

    void drawSlider () 
    {
        noStroke();
        
        fill( 100 );
        rect( x, y, width, height );
        
        fill( 120 );
        rect( x+valueX, y, height, height );
    }
}

