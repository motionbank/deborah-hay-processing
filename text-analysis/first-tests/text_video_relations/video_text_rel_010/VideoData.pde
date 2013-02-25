class VideoData {
  
  MovementData                     movements;
  PositionData                     positions;
  
  org.piecemaker.models.Event[]    sceneEvents;
  org.piecemaker.models.Event[]    dataEvents;
  org.piecemaker.models.Event      firstEvent;
  org.piecemaker.models.Event      lastEvent;
  
  float                            duration = 0;
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
    
    org.piecemaker.models.Event dataEvent = dataEvents[0];
    String positionsFile = dataEvent.description.substring(7,dataEvent.description.length());
    positionsFile = positionsFile.substring(0,positionsFile.indexOf('.')) + "_interpolated.txt";
    String[] positionData = loadStrings( DATA_URL + positionsFile);
    
    this.performer = positionsFile.substring(0,positionsFile.indexOf('_'));
    
    
    this.numFrames = positionData.length;
    
    float firstMarkerRel = (firstEvent.getHappenedAt().getTime() - file.getHappenedAt().getTime()) / (file.getDuration()*1000);
    this.firstMarkerIndex = floor( firstMarkerRel * numFrames );
    
    
    //-------------------------------------------------------------
     
    this.positions = new PositionData( positionData, this.firstMarkerIndex );
    
    this.movements = new MovementData( file.title, this.firstMarkerIndex );
    
    // check if positions is too long
    if (this.positions.length() - this.movements.length() == 1) this.positions.positions.remove(this.positions.positions.size()-1);
    
  }
}
