
    MouseJoint mouseJoint;
    Vec2 clickedPoint;
    
    void mousePressed ()
    {
        Vec2 p = physics.screenToWorld( new Vec2( mouseX, mouseY ) );
        
        Vec2 d = new Vec2(0.001f, 0.001f);
        AABB aabb = new AABB( p.sub(d), p.add(d) );
    
        // query the world for overlapping shapes.
        Shape shapes[] = physics.getWorld().query(aabb, 10);
        Body body = null;
        for (int j = 0; j < shapes.length; j++)
        {
            Shape shape = shapes[j];
            if (shape != null && !shape.m_body.isStatic())
            {
                boolean inside = shape.testPoint( shape.m_body.getXForm(), p );
                if (inside)
                {
                    body = shape.m_body;
                    break;
                }
            }
        }
        if ( shapes.length > 0 )
        {
            body = shapes[0].m_body;
        }
    
        if ( body != null ) {
            MouseJointDef md = new MouseJointDef();
            md.body1 = physics.getWorld().getGroundBody();
            md.body2 = body;
            md.target = p;
            md.maxForce = 100 * body.m_mass;
            mouseJoint = (MouseJoint) physics.getWorld().createJoint(md);
            body.wakeUp();
        }
    }
    
    void mouseReleased ()
    {
        if ( mouseJoint != null) {
            physics.getWorld().destroyJoint( mouseJoint );
            mouseJoint = null;
        }
    }
    
    void mouseDragged ()
    {
        Vec2 p = physics.screenToWorld( new Vec2( mouseX, mouseY ) );
        
        if ( mouseJoint != null )
        {
            mouseJoint.setTarget(p);
        }
    }
    
 void keyPressed ()
 {
     switch ( key )
     {
         case ' ':
             Joint joint = physics.getWorld().getJointList();
            do {
                
                if ( joint.getClass() == DistanceJoint.class )
                {
                    DistanceJoint dJoint = (DistanceJoint)joint;
                    dJoint.m_length = 2;
                }
                
            } while ( (joint = joint.getNext()) != null ); // joints
            Body body = physics.getWorld().getBodyList();
            do // loop thru bodies
            {
                Shape shape = body.getShapeList();
                
                if ( shape != null && shape.getType() == ShapeType.CIRCLE_SHAPE )
                {
                    CircleShape circle = (CircleShape) shape;
                    circle.m_radius = 0.0;
                }
                
            } while ( (body = body.getNext()) != null ); // bodies ..
            break;
        case '-':
            treeWeightThresholdLow++;
            if ( treeWeightThresholdLow > treeWeightThresholdHigh ) treeWeightThresholdLow = treeWeightThresholdHigh;
            break;
        case '+':
            treeWeightThresholdLow--;
            if ( treeWeightThresholdLow <= 0 ) treeWeightThresholdLow = 0;
            break;
        case 'p':
            treeWeightThresholdHigh++;
            if ( treeWeightThresholdHigh > maxTreeWeight ) treeWeightThresholdHigh = maxTreeWeight;
            break;
        case 'm':
            treeWeightThresholdHigh--;
            if ( treeWeightThresholdHigh <= treeWeightThresholdLow ) treeWeightThresholdHigh = treeWeightThresholdLow;
            break;
     }
 }
