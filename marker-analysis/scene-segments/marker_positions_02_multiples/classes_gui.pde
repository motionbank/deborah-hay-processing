
public class Listbox
{
    float x, y, width, height;
    
    ArrayList items;
    int itemHeight = 20;
    int listStartAt = 0;
    int hoverItem = -1;
    int lastItemClicked = -1;
    
    float valueY = 0;
    boolean hasSlider = false;
    
    Listbox ( float xx, float yy, float ww, float hh ) 
    {
        x = xx; y = yy;
        valueY = y;
        
        width = ww; height = hh;
        
        Interactive.add( this );
        if ( interfaceFont == null ) interfaceFont = createFont( "Open Sans", 11 );
    }
    
    public void addItem ( String item )
    {
        if ( items == null ) items = new ArrayList();
        items.add( item );
        
        hasSlider = items.size() * itemHeight > height;
    }
    
    public void mouseMoved ( float mx, float my )
    {
        if ( mx < x || mx > (x+width-20) ) return;
        
        hoverItem = listStartAt + int((my-y) / itemHeight);
    }
    
    public void mouseExited ( float mx, float my )
    {
        hoverItem = -1;
    }
    
    void mouseDragged ( float mx, float my )
    {
        if ( !hasSlider ) return;
        if ( mx < (x+width-20) ) return;
        
        valueY = my-10;
        valueY = constrain( valueY, y, y+height-20 );
        
        update();
    }
    
    void mouseScrolled ( float step )
    {
        if ( mouseX > x && mouseY > y && mouseX < x+width && mouseY < y+height )
        {
            valueY += step;
            valueY = constrain( valueY, y, y+height-20 );
        
            update();
        }
    }
    
    void update ()
    {
        float totalHeight = items.size() * itemHeight;
        float itemsInView = height / itemHeight;
        float listOffset = map( valueY, y, y+height-20, 0, totalHeight-height );
        
        listStartAt = int( listOffset / itemHeight );
    }
    
    public void mousePressed ( float mx, float my )
    {
        if ( hasSlider && mx > (x+width-20) ) return;
        
        int item = listStartAt + int( (my-y) / itemHeight);
        lastItemClicked = item;
        itemClicked( this, item, items.get(item) );
    }

    void draw ()
    {
        noStroke();
        
        int colBack = 190;
        int colSel = 210;
        int colHigh = 230;
        
        fill( colBack );
        rect( x,y,this.width,this.height );
        
        if ( items != null )
        {
            for ( int i = 0; i < int(height/itemHeight) && i < items.size(); i++ )
            {
                stroke( colBack );
                
                fill( (i+listStartAt) == hoverItem || (i+listStartAt) == lastItemClicked ? colSel : colHigh );
                rect( x, y + (i*itemHeight), this.width-1, itemHeight );
                
                noStroke();
                fill( 0 );
                textFont( interfaceFont );
                textAlign( LEFT );
                text( items.get(i+listStartAt).toString(), x+5, y+(i+1)*itemHeight-5 );
            }
        }
        
        if ( hasSlider )
        {
            
            noStroke();
            
            fill( colBack );
            rect( x+width-20, y, 20, height );
               
            stroke( colBack );
            fill( colHigh );
            rect( x+width-20, valueY, 19, 19 );
            
            line( x+width-20, y, x+width-20, y+height );
        }
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

public class CheckBox
{
    boolean checked;
    float x, y, width, height;
    String label;
    float padx = 7;
    
    CheckBox ( String l, float xx, float yy, float ww, float hh )
    {
        label = l;
        x = xx; y = yy; width = ww; height = hh;
        Interactive.add( this );
    }
    
    void mouseReleased ()
    {
        checked = !checked;
    }
    
    void draw ()
    {
        noStroke();
        fill( 200 );
        rect( x, y, width, height );
        if ( checked )
        {
            fill( 80 );
            rect( x+2, y+2, width-4, height-4 );
        }
        fill( 255 );
        textAlign( LEFT );
        text( label, x+width+padx, y+height );
    }
    
    // this is a special inside test that includes the label text
    
    boolean isInside ( float mx, float my )
    {
        return Interactive.insideRect( x,y,width+padx+textWidth(label), height, mx, my );
    }
}
