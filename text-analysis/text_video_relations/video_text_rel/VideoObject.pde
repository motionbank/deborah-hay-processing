class VideoObjectList {

    ArrayList<VideoObject> videos = new ArrayList<VideoObject>();

    VideoObjectList() {
    }

    void add ( org.piecemaker.models.Video _video, org.piecemaker.models.Event[] _events ) {
        println("- - - - creating video object: " + _video.id );
        this.videos.add( new VideoObject( _video, _events ) );
        println("- - - - video object created: " + _video.id );
    }

    VideoObject get (int _i) {
        return this.videos.get(_i);
    }

    int length() {
        return videos.size();
    }

    void sort() {
        java.util.Collections.sort( videos, new java.util.Comparator () {
            public int compare ( Object a, Object b ) {
                Date _a = ((VideoObject)a).data.firstEvent.getHappenedAt();
                Date _b = ((VideoObject)b).data.firstEvent.getHappenedAt();
                return _a.compareTo( _b );
            }
        }
        );
    }
}


class VideoObject {

    VideoData data;
    VideoSegmentList segments;

    VideoObject(org.piecemaker.models.Video _video, org.piecemaker.models.Event[] _events) {
        this.data = new VideoData(_video, _events);
        this.segments = new VideoSegmentList( this.data );
    }
}


class PerformerVideosList {

    ArrayList<PerformerVideos> performerVideos = new ArrayList<PerformerVideos>();

    PerformerVideosList() {
    }

    boolean has (String _name) {
        boolean b = false;
        for (PerformerVideos p : performerVideos) {
            if (p.name.equals(_name)) b = true;
        }
        return b;
    }

    void add (String _name) {
        this.performerVideos.add( new PerformerVideos( _name ) );
    }

    void add (String _name, VideoObject _video) {
        PerformerVideos v = new PerformerVideos( _name );
        v.add(_video); 
        this.performerVideos.add( v );
    }

    PerformerVideos get (int _i) {
        return performerVideos.get(_i);
    }

    PerformerVideos get (String _s) {
        PerformerVideos v = null;

        for (int i=0; i<performerVideos.size(); i++) {
            PerformerVideos v0 = performerVideos.get(i);
            if (v0.name.equals(_s)) {
                v = v0;
                break;
            }
        }
        return v;
    }

    int length() {
        return performerVideos.size();
    }

    void sort ()
    {
        for ( PerformerVideos pv : performerVideos )
        {
            pv.sort();
        }
    }
}


class PerformerVideos {

    String name = "";
    ArrayList<VideoObject> videos = new ArrayList<VideoObject>();

    PerformerVideos(String _name) {
        this.name = _name;
    }

    void add ( VideoObject _video ) {
        this.videos.add( _video );
    }

    VideoObject get (int _i) {
        return videos.get(_i);
    }

    int length() {
        return videos.size();
    }

    void sort ()
    {
        java.util.Collections.sort( videos, new java.util.Comparator(){
            public int compare ( Object a, Object b ) {
                return ((VideoObject)a).data.firstEvent.getHappenedAt().compareTo( ((VideoObject)b).data.firstEvent.getHappenedAt() );
            }
        });
    }
}

