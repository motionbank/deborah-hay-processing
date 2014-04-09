
var App = (function () {
    
    /*
     + private variables
     L + + + + + + + + + + + + */
     
    var app, sketch;
    var pm, pieces, piece, videos, video;
    
    /*
     + class definition
     L + + + + + + + + + + + + */
    
    var App = function ( s ) {
        
        app = this;
        sketch = s;
        onLocalhost = window.location.href.match(/^http:\/\/127\.0\.0\.1.*/) || 
                      window.location.href.match(/^http:\/\/localhost.*/)    ||
                      window.location.href.match(/^http:\/\/[^/]+\.local.*/);
        pm = new PieceMakerApi({
            api_key: "4d2452b3f3d2810eca691cf77a8fececd919323a",
            host: ( onLocalhost && false ? 'http://localhost:9292' : 'http://deborah-hay-pm2.herokuapp.com' )
        });
        
        pm.getGroup( 24, app.pieceLoaded );
    }
    App.prototype = {
        pieceLoaded : function ( p ) {
            piece = p;
            pm.listEventsOfType( piece.id, 'video', app.videosLoaded );
        },
        videosLoaded : function ( videos ) {
            if ( videos && videos.length > 0 ) {
                var sel = document.createElement('select');
                for ( var i = 0, k = videos.length; i < k; i++ ) {
                    var opt = document.createElement('option');
                    opt.setAttribute('value',videos[i].id);
                    opt.innerHTML = videos[i].fields.title;
                    sel.appendChild( opt );
                }
                jQuery(sel).change(function(){
                    var videoId = jQuery(this).val();
                    pm.getEvent( piece.id, videoId, app.videoLoaded );
                });
                var selBlock = jQuery( '#video-selection' ).get(0);
                selBlock.appendChild( sel );
            }
            
            pm.getEvent( piece.id, 69322, app.videoLoaded );
        },
        videoLoaded : function ( v ) {
            video = v;
            pm.listEventsBetween( piece.id, 
                                  video.utc_timestamp, 
                                  new Date( video.utc_timestamp + (video.duration * 1000.0) ), 
                                  app.eventsLoaded );
        },
        eventsLoaded : function ( eventsRaw ) {
            if ( eventsRaw.length > 0 ) {
                var dataEvent = null;
                for ( var i = 0, k = eventsRaw.length; i < k; i++ ) {
                    if ( eventsRaw[i].type == 'data' ) {
                        dataEvent = eventsRaw[i];
                        break;
                    }
                }
                if ( dataEvent ) {
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_25fps.txt' ) );
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_alt.txt' ) );
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_left_wrist.txt' ) );
                    app.loadDataEvent( dataEvent, dataEvent.fields['data-file'] );
                    //app.loadDataEvent( dataEvent, dataEvent.fields['data-file'].replace( '.txt', '_com.txt' ) );
                }
            }
        },
        loadDataEvent : function ( dataEvent, dataFile ) {
            jQuery.ajax({
                url: (onLocalhost ? 'http://moba-lab.local/' : 'http://lab.motionbank.org/') + 'dhay/data/' + dataFile,
                success: function ( resp ) {
                    app.eventDataLoaded( dataEvent, resp );
                },
                error: function () {
                    console.log( arguments );
                }
            });
        },
        eventDataLoaded : function ( event, data ) {
            var trackData = [];
            data = data.split("\n");
            for ( var i = 0, k = data.length; i < k; i++ ) {
                var v = data[i].split( " " );
                if ( v[0] && v[1] && v[2] )
                    trackData.push( [parseFloat(v[0]), parseFloat(v[1]), parseFloat(v[2])] );
            }
            sketch.setData( trackData );
        }
    }
    return App;
})();
