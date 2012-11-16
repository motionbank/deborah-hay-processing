 
 void buildPhraseNets ()
 {
     String theText = join( loadStrings( textFile ), "\n" );
     
     String[] nettypes = new String[]{
         PhraseNet.ON,
         PhraseNet.IN,
         PhraseNet.OVER,
         PhraseNet.ONTO,
         PhraseNet.TO,
         PhraseNet.ACROSS,
         PhraseNet.AT
     };
     
     /*nettypes = new String[]{
         PhraseNet.OF,
         PhraseNet.GENITIVE_CASE
     };*/
     
     /*nettypes = new String[]{
         PhraseNet.ED
     };*/
     
     for ( String type : nettypes )
     {
         Pattern patt = Pattern.compile( "(" + 
                                             "(" + PhraseNet.WORD2 + ")" + 
                                             "(" + type + ")" + 
                                             "(" + PhraseNet.WORD2 + ")" + 
                                         ")",
                                         Pattern.CASE_INSENSITIVE );
                                         
        Matcher matc = patt.matcher( theText );
         
        while ( matc.find() )
        {
            net.add( cleanString( matc.group(2) ), 
                     matc.group(3).trim().toLowerCase(), 
                     cleanString( matc.group(4) ) );
        }
    }
    
    //println( net.items.values().iterator().next().getTreeItems() );
 }
 
 HashMap<String, Body> bodies;
 void phraseNetPhysics ()
 {
    Body body = null;
    bodies = new HashMap<String, Body>();
    circleRadii = new HashMap<String, Float>();
    
    for ( PhraseItem item : net.items.values() )
    {
         float tWidth = textWidth( item.item );
         Vec2 pos = new Vec2( 20 + random(width-40), 20 + random(height-40) );
         int d = 40;
         body = physics.createRect( pos.x-(tWidth+d)/2, pos.y-d/2, pos.x+(tWidth+d)/2, pos.y+d/2 );
         //body = physics.createCircle( pos.x, pos.y, (tWidth+20)/2 );
         body.setUserData( item );
         
         circleRadii.put( item.item, physics.screenToWorld( (tWidth+20)/2.0 ) );
         
         maxConnections = int( max( maxConnections, item.getConnectionCount() ) );
         maxTreeWeight = int( max( maxTreeWeight, item.getTreeWeight() ) );
         
         bodies.put( item.item, body );
    }
    
    treeWeightThresholdHigh = maxTreeWeight;
    
    for ( String k : net.connections.keySet() )
    {
         Vector<PhraseConnection> vec = net.connections.get(k);
         PhraseConnection[] many = vec.toArray( new PhraseConnection[0] );
         
         for ( PhraseConnection connection : many )
         {
            DistanceJointDef jd = new DistanceJointDef();
            jd.body1 = bodies.get(connection.from.item);
            jd.body2 = bodies.get(connection.to.item);
            jd.body2.setXForm( jd.body1.getPosition().sub(new Vec2(0,0.1)), 0.0 ); // kuddle
            jd.length = 1;
            
            DistanceJoint joint = (DistanceJoint) jd.body1.getWorld().createJoint(jd);
            joint.setUserData( connection );
         }
     }
 }
