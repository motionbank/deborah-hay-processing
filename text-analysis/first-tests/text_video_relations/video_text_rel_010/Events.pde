void keyPressed() 
{
    if ( key != CODED )
    {
        switch ( key ) {
            case 's':
                saveFrame("image_difference_variance3_" + performers.get(performerIndex).name + ".png");
                break;
            case 'f':
                drawFill = !drawFill;
                drawFrame = true;
                break;
            default:
                println( "Key pressed: " + key );
        }
    } else {
        switch ( keyCode )
        {
            case UP:
                drawFrame = true;
                performerIndex += 1;
                if (performerIndex > 2) performerIndex = 0;
                break;
            case RIGHT:
                drawFrame = true;
                drawMode += 1;
                if (drawMode > 3) drawMode = 0;
                println("drawMode " + drawMode);
                break;
           case LEFT:
                drawFrame = true;
                drawMode -= 1;
                if (drawMode < 0) drawMode = 3;
                println("drawMode " + drawMode);
                break;
           default:
               println( "Key pressed, code: " + keyCode );
               
        }
    }
}

