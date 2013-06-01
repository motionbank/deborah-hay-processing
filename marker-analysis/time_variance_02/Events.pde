void keyPressed() 
{
    if ( key != CODED )
    {
        switch ( key ) {
        case 's':
            saveFrame("abs_travel_speed3_" + performers.get(performerIndex).name + timestamp() + ".png");
            //saveFrame(timestamp() + ".png");
            break;
        case 'f':
            drawFill = !drawFill;
            drawFrame = true;
            break;
        default:
            println( "Key pressed: " + key );
        }
    } 
    else {
        switch ( keyCode )
        {
        case UP:
            drawFrame = true;
            //performerIndex += 1;
            //if (performerIndex >= performers.length()) performerIndex = 0;
            segIdx++;

            if (segIdx == 25) {
                idx++;
                segIdx = 0;

                if (idx == 7) {
                    performerIndex++;
                    idx = 0;
                }
            }
            break;
        case DOWN:
            drawFrame = true;
            //performerIndex += 1;
            //if (performerIndex >= performers.length()) performerIndex = 0;
            idx--;
            if (idx < 0) idx = videoIDs.length-1;
            break;
        default:
            println( "Key pressed, code: " + keyCode );
        }
    }
}

String timestamp() {
    return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

