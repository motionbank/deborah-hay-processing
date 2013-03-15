
void updateCurrentFrame( float v )
{
    currentFrame = (int)(v*ps3D[0].length);
}

void initGui ()
{
//        gui = new ArrayList<GuiItem>();

//    GuiButton button = new GuiButton(this);
//    button.set(new Object(){
//        PVector position = new PVector(20,20);
//        PVector size = new PVector(20,20);
//        boolean autoRender = false;
//    });
//    button.addListener( new GuiListener () {
//        public void bang ( GuiEvent evt ) {
//            println( "bang" );
//        }
//    });
//    gui.add( button );

//    slider = new GuiSlider(this).setValue(0);
//    slider.set(
//        "position", new PVector(5,5),
//        "size", new PVector(width-10, 20)
//    );
//    slider.setAutoRender(false);
//    slider.setMinMax(0,ps2DC.length);
//    slider.addListener(new GuiListener(){
//        public void changed ( GuiEvent evt )
//        {
//            int nextFrame = (int)((GuiSlider)evt.item).value();
//            currentFrame = nextFrame;
//        }
//    });
//    gui.add( slider );
//    
//    GuiSlider s = new GuiSlider(this).setValue(tailLength);
//    s.set(
//        "position", new PVector(5,30),
//        "size", new PVector(width-10, 20)
//    );
//    s.setAutoRender(false);
//    s.setMinMax(0,120000);
//    s.addListener(new GuiListener(){
//        public void changed ( GuiEvent evt )
//        {
//            tailLength = (int)((GuiSlider)evt.item).value();
//        }
//    });
//    gui.add( s );
}
