
class EventSequence
{
    float x, y, width;
    ArrayList<EventLabel> labels;
    
    EventSequence ( ) 
    {
        labels = new ArrayList();
    }
    
    void setXY ( float xx, float yy )
    {
        x = xx;
        y = yy;
    }
    
    public void addEvent ( org.piecemaker.models.Event e )
    {
        labels.add( new EventLabel( e ) );
        width = max( width, textWidth( e.title ) );
        //this.height = labels.size() * 15;
    }
    
    void drawMe ()
    {
        fill( 255 );
        rect( x, 0, width, height );
        float ys = 0;
        for ( EventLabel l : labels )
        {
            l.x = x;
            l.y = y + ys;
            l.drawLabel();
            ys += 15;
        }
    }
}

public class EventLabel
{
    float x, y;
    org.piecemaker.models.Event event;
    boolean hover = false;
    
    EventLabel ( org.piecemaker.models.Event ev )
    {
        event = ev;
        Interactive.add( this );
    }
    
    void mouseEntered ()
    {
        hover = true;
        labelHoverText = event.title;
    }
    
    void mouseExited ()
    {
        hover = false;
    }
    
    void drawLabel ()
    {
        if ( labelHoverText != null && labelHoverText.equals(event.title) )
        {
            fill( 220 );
            rect( x, y-10, sequenceWidth, 15 );
        }
        fill( hover ? 0 : titleColors.get( event.title ) );
        if ( !event.getEventType().equals("scene") )
            textFont( lato8ital );
        else
            textFont( lato8reg );
        text( event.title.toUpperCase(), x+5, y );
    }
    
    boolean isInside ( float mx, float my )
    {
        float gx = slider.value * -(sequences.size() * sequenceWidth - width);
        mx -= gx;
        float tw = min( textWidth( event.title ), sequenceWidth );
        tw = sequenceWidth;
        float th = g.textSize;
        return mx > x && mx < x+10+tw && my > y-th*1.5 && my < y+th;
    }
}


public class Slider
{
    float x, y, width, height;
    float valueX = 0, value;
    
    Slider ( float xx, float yy, float ww, float hh ) 
    {
        x = xx; y = yy; width = ww; height = hh;
        valueX = x;
        
        Interactive.add( this );
    }
    
    void setValue ( float v )
    {
        value = v > 1 ? 1 : v;
        value = value < 0 ? 0 : value;
        valueX = map( value, 0, 1, x, x+width-height );
    }
    
    void mouseDragged ( float mx, float my )
    {
        valueX = mx - height/2;
        
        if ( valueX < x ) valueX = x;
        if ( valueX > x+width-height ) valueX = x+width-height;
        
        value = map( valueX, x, x+width-height, 0, 1 );
    }

    void draw () 
    {
        noStroke();
        
        fill( 100 );
        rect(x, y, width, height);
        
        fill( 120 );
        rect( valueX, y, height, height );
    }
}
