class EventGroup
{
    ArrayList<org.piecemaker.models.Event> events;
    
    long startTime = -1, endTime = -1, duration = -1;
    
    void addEvent ( org.piecemaker.models.Event e )
    {
        if ( events == null ) events = new ArrayList();
        events.add( e );
        Collections.sort( events, new Comparator<org.piecemaker.models.Event>(){
            public int compare( org.piecemaker.models.Event e1, org.piecemaker.models.Event e2 ) {
                return e1.getHappenedAt().compareTo(e2.getHappenedAt());
            }
        });
        
        startTime = events.get( events.size()-1 ).getHappenedAt().getTime();
        endTime   = events.get( 0 ).getHappenedAt().getTime();
        duration  = endTime - startTime;
    }
}
