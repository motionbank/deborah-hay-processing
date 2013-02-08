class EventGroup
{
    ArrayList<Event> events;
    
    long startTime = -1, endTime = -1, duration = -1;
    
    void addEvent ( Event e )
    {
        if ( events == null ) events = new ArrayList();
        events.add( e );
        Collections.sort( events, new Comparator<Event>(){
            public int compare( Event e1, Event e2 ) {
                return e1.getHappenedAt().compareTo(e2.getHappenedAt());
            }
        });
        
        startTime = events.get( events.size()-1 ).getHappenedAt().getTime();
        endTime   = events.get( 0 ).getHappenedAt().getTime();
        duration  = endTime - startTime;
    }
}

class GraphBar extends ActiveElement
{
    boolean absolute = false;
    
    long minimum = Long.MAX_VALUE, maximum = Long.MIN_VALUE, median, sum, mean;
    long[] values;
    int total;
    String label;
    
    GraphBar ( float x, float y, float w, float h, String label ) {
        super( x, y, w, h );
        this.label = label;
    }
    
    void add ( long value )
    {
        minimum = Math.min( value, minimum );
        maximum = Math.max( value, maximum );
        total++;
        sum += value;
        mean = sum / total;
        
        if ( values == null ) 
        {
            values = new long[]{value};
        }
        else 
        {
            long[] tmp = new long[total];
            System.arraycopy( values, 0, tmp, 0, values.length );
            tmp[total-1] = value;
            values = tmp;
        }
        Arrays.sort(values);
        median = values[values.length/2];
    }
    
    void draw ()
    {
        noStroke(); fill( 245 );
        rect( x, y, width, height );
        
        if ( !absolute ) drawRelative();
        else             drawAbsolute();
        
        pushMatrix();
        translate( x+width-2,y+height-2 );
        rotate( -radians(90) );
        fill( 170 );
        textSize( 8 );
        text( label.toUpperCase(), 0,0 );
        popMatrix();
    }
    
    void drawRelative ()
    {
        float v = (minimum / (float)maximum) * height;
        fill(220); noStroke();
        rect( x, y, width, height - v );
        stroke( 255, 0, 0 );
        line( x, y + height - v, x+width, y + height - v );
        
        stroke( 0, 255, 0 );
        v = (mean / (float)maximum) * height;
        line( x, y + height - v, x+width, y + height - v );
        
        stroke( 0, 0, 255 );
        v = (median / (float)maximum) * height;
        line( x, y + height - v, x+width, y + height - v );
    }
    
    void drawAbsolute()
    {
        
    }
}
