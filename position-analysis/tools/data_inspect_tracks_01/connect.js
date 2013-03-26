
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
            api_key: "a79c66c0bb4864c06bc44c0233ebd2d2b1100fbe",
            baseUrl: ( onLocalhost ? 'http://localhost:3000' : 'http://notimetofly.herokuapp.com' )
        });
        
        pm.loadPieces(app.piecesLoaded);
    }
    App.prototype = {
        piecesLoaded : function ( data ) {
            if ( data.total == 1 ) {
                piece = data.pieces[0];
                pm.loadVideosForPiece( piece.id, app.videosLoaded );
            }
        },
//        pieceLoaded : function ( p ) {
//            if ( p ) {
//                piece = p;
//                pm.loadVideosForPiece( piece.id, app.videosLoaded );
//            }
//        },
        videosLoaded : function ( data ) {
            if ( data && data.total && data.total > 0 ) {
                videos = data.videos;
                var sel = document.createElement('select');
                for ( var i = 0, k = videos.length; i < k; i++ ) {
                    var opt = document.createElement('option');
                    opt.setAttribute('value',videos[i].id);
                    opt.innerHTML = videos[i].title;
                    sel.appendChild( opt );
                }
                jQuery(sel).change(function(){
                    var videoId = jQuery(this).val();
                    pm.loadVideo( videoId, app.videoLoaded );
                });
                var selBlock = jQuery( '#video-selection' ).get(0);
                selBlock.appendChild( sel );
            }
            pm.loadVideo( 80, app.videoLoaded );
        },
        videoLoaded : function ( v ) {
            video = v;
            pm.loadEventsForVideo( video.id, app.eventsLoaded );
        },
        eventsLoaded : function ( data ) {
            if ( data.total > 0 ) {
                var eventsRaw = data.events;
                var dataEvent = null;
                for ( var i = 0, k = eventsRaw.length; i < k; i++ ) {
                    if ( eventsRaw[i].event_type == 'data' ) {
                        dataEvent = eventsRaw[i];
                        break;
                    }
                }
                if ( dataEvent ) {
                    dataEvent.happened_at = new Date( dataEvent.happened_at_float );
                    dataEvent.data = eval( '(' + dataEvent.description + ')' );
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_25fps.txt' ) );
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_alt.txt' ) );
//                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_left_wrist.txt' ) );
                    app.loadDataEvent( dataEvent, dataEvent.data.file );
                    app.loadDataEvent( dataEvent, dataEvent.data.file.replace( '.txt', '_com.txt' ) );
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
