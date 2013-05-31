class VideoData {
  
  PositionData                     positions;
  SpeedData                        speeds;
  
  org.piecemaker.models.Event[]    sceneEvents;
  org.piecemaker.models.Event[]    dataEvents;
  org.piecemaker.models.Event      firstEvent;
  org.piecemaker.models.Event      lastEvent;
  
  float                            duration = 0.0;
  long                             firstMarkerTime = 0;
  int                              firstMarkerIndex = 0;
  int                              numFrames = 0;
  
  org.piecemaker.models.Video      file;
  
  String                           performer ="";
  
  
  VideoData( org.piecemaker.models.Video _video, org.piecemaker.models.Event[] _events ) {
    
    this.sceneEvents = new org.piecemaker.models.Event[0];
    this.dataEvents = new org.piecemaker.models.Event[0];
    this.file = _video;
    
    
    //-------------------------------------------------------------
    // FILTER ALL EVENTS
    
    for (int i=0; i<_events.length; i++) {
      org.piecemaker.models.Event evt = _events[i];
      
      if (evt.getEventType().equals("scene") || evt.getEventType().equals("scenefaux")) {
        sceneEvents = (org.piecemaker.models.Event[]) append( sceneEvents, evt );
      }
      // should only have one data event
      else if (evt.getEventType().equals("data")) {
        dataEvents = (org.piecemaker.models.Event[]) append( dataEvents, evt );
      }
    }
        
    
    //-------------------------------------------------------------
    
    this.firstEvent = sceneEvents[0];
    this.lastEvent = sceneEvents[sceneEvents.length-1];
    this.firstMarkerTime = firstEvent.getHappenedAt().getTime();
    this.duration = lastEvent.getHappenedAt().getTime() - firstEvent.getHappenedAt().getTime();
    
    
    //-------------------------------------------------------------
    
    // load file here because we need the total amount of frames
    
    String[] parts = file.title.split("_");
    String path = LOCAL_DATA_PATH + SPEED_DATA_DIR + parts[1] + "_" + parts[0] + SPEED_DATA_FILE;
    
    org.piecemaker.models.Event dataEvent = dataEvents[0];
    String[] positionData = loadStrings( LOCAL_DATA_PATH + POSITION_DATA_DIR + parts[1] + "_" + parts[0] + POSITION_DATA_FILE);
    
    this.performer = parts[1];
    
    
    
    
    this.numFrames = positionData.length;
    
    float firstMarkerRel = (firstEvent.getHappenedAt().getTime() - file.getHappenedAt().getTime()) / (file.getDuration()*1000);
    this.firstMarkerIndex = floor( firstMarkerRel * numFrames );
    
    
    //-------------------------------------------------------------
    println("+ + + + + " + file.id + " " + file.title);
    this.positions = new PositionData( positionData, this.firstMarkerIndex );
    this.speeds = new SpeedData( loadStrings(path), this.firstMarkerIndex );
    //this.movements = new MovementData( file.title, this.firstMarkerIndex );
        
    // check if positions is too long
    //if ( this.movements.length() - this.positions.length() == 1) this.positions.positions.remove(this.positions.positions.size()-1);
    
  }
}
