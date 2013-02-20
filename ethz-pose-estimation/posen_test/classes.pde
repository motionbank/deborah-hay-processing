class Pose3D
{
    boolean valid;
    int index;
    
    float[] x, y, z;
    
    PVector[] bbox;
    PVector center;
    
    Pose3D ( String l )
    {
        String[] vals = l.split(":");
        index = Integer.parseInt(vals[0]);
        valid = Integer.parseInt(vals[1]) != 0;
        
        if ( valid )
        {
            bbox = new PVector[]{
                new PVector( Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE ),
                new PVector( Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE )
            };
            
            vals = l.split(":")[2].split(",");
            
            x = new float[vals.length];
            y = new float[vals.length];
            z = new float[vals.length];
        
            for ( int i = 0; i < vals.length; i++ )
            {
                String[] vals2 = vals[i].trim().split(" ");
                if ( vals2.length >= 3 )
                {
                    x[i] = Float.parseFloat( vals2[0] ) * 100;
                    y[i] = Float.parseFloat( vals2[1] ) * 100;
                    z[i] = Float.parseFloat( vals2[2] ) * 100;
                    
                    bbox[0].x = min( x[i], bbox[0].x );
                    bbox[0].y = min( y[i], bbox[0].y );
                    bbox[0].z = min( z[i], bbox[0].z );
                    
                    bbox[1].x = max( x[i], bbox[1].x );
                    bbox[1].y = max( y[i], bbox[1].y );
                    bbox[1].z = max( z[i], bbox[1].z );
                }
            }
            
            PVector p = bbox[1].get();
            p.sub(bbox[0]);
            p.div(2);
            center = bbox[0].get();
            center.add(p);
        }
    }
    
    void drawCentered ()
    {
        pushMatrix();
        translate( -center.x, -center.y, -center.z );
        draw();
        popMatrix();
    }
    
    void draw ()
    {
        stroke( 255 );
        noFill();
        
        for ( int i = 0; i < x.length-1; i+=2 )
        {
            noStroke();
            fill( 255 );
            
            pushMatrix();
            translate( x[i], y[i], z[i] );
            box(3);
            popMatrix();
            
            pushMatrix();
            translate( x[i+1], y[i+1], z[i+1] );
            box(3);
            popMatrix();
            
            stroke( 255 );
            line( x[i], y[i], z[i], x[i+1], y[i+1], z[i+1] );
        }
    }
    
    public String toString ()
    {
        return x + " - " + y + " - " + z;
    }
}
