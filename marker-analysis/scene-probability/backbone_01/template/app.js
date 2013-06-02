
jQuery(function(){
	new App(AppConfig);
});

var App = (function(){

	// --------------------------
	//	private variables
	// --------------------------
	
	var app = null;
	var pm = null;
	var sketch = null;

	var piece;
	var video, videos, videoClusters;
	var eventClusters;

	var conf;

	// --------------------------
	//	private functions
	// --------------------------

	var init = function () {
		pm = new PieceMakerApi({
    		api_key: conf.pieceMaker.apiKey,
    		baseUrl: conf.onLocalhost ? 'http://localhost:3000' : conf.pieceMaker.remoteLocation
		});
		var tryFindSketch = function () {
	        sketch = Processing.getInstanceById( getProcessingSketchId() );
	        if ( !sketch ) return setTimeout( tryFindSketch, 100 );
	        sketchLoaded();
	    };
	    tryFindSketch();
	}

	var sketchLoaded = function () {
		sketch.setApp( app );
		pm.loadPieces( piecesLoaded );
	}

	var piecesLoaded = function (data) {
		pm.loadPiece( data.pieces[0].id, pieceLoaded );
	}

	var pieceLoaded = function (p) {
		piece = p;
		pm.loadVideosForPiece(p.id, videosLoaded);
	}

	var videosLoaded = function (data) {
		videos = data.videos;
		videoClusters = [];
		eventClusters = [];
		for ( var i = 0, k = data.total; i < k; i++ ) {
			var v = videos[i];

			if ( v.title.indexOf("_sync") === -1 ) continue;

			v.recorded_at = new Date( v.recorded_at_float );
			v.happened_at = v.recorded_at;
			v.finished_at = new Date( v.happened_at.getTime() + v.duration * 1000.0 );
			for ( var n = 0, l = videoClusters.length; n < l; n++ ) {
				if ( videoClusters[n].intersects(v) ) {
					videoClusters[n].add(v);
					break;
				}
			}
			var vc = new App.TimeCluster( v );
			videoClusters.push( vc );
		}
		videoClusters.sort(function(a,b){
			var d = a.start - b.start;
			if ( d < 0 ) return -1;
			if ( d > 0 ) return 1;
			return 0; 
		});
		clustersBuilt();
	}

	var clustersBuilt = function () {
		var sel = document.createElement('ul');
		sel.setAttribute('id','video-cluster-selection');
		for ( var i = 0, k = videoClusters.length; i < k; i++ ) {
			if ( videoClusters[i].events.length <= 1 ) continue;
			var opt = document.createElement('li');
			opt.setAttribute('data-cluster-id',i);
			var videoTitles = opt.innerHTML = videoClusters[i].toString();
			if ( i == k-1 ) {
				opt.setAttribute('class','last');
			}
			jQuery(opt).click(function(){
				var opt = jQuery(this);
				var vcId = opt.data('cluster-id');
				if ( opt.hasClass('selected') ) {
					opt.removeClass('selected');
					videoClusterDeselected( vcId );
				} else {
					opt.addClass('selected');
					videoClusterSelected( vcId );
				}
			});
			sel.appendChild( opt );
			// if ( videoTitles.indexOf("Janine") !== -1 ) {
			// 	jQuery(opt).addClass('selected');
			// 	videoClusterSelected( i );
			// }
		}
		document.getElementById('content').appendChild(sel);
	}

	var videoClusterDeselected = function (which) {
		var vc = videoClusters[which];
		vc.selected = false;
		selectedVideoClustersToSketch();
	}

	var videoClusterSelected = function (which) {
		var vc = videoClusters[which];
		if ( !eventClusters[which] ) {
			pm.loadEventsBetween( vc.start, vc.end, function (data) {
				var events = [];
				for ( var i = 0, k = data.total; i < k; i++ ) {
					var e = data.events[i];
					if ( e.event_type == 'scene' || e.event_type == 'scenefaux' ) {
						e.happened_at = new Date( e.happened_at_float );
						e.finished_at = new Date( e.happened_at_float + e.duration * 1000 );
						events.push( e );
					}
				}
				events.sort(function(a,b){
					var d = a.happened_at - b.happened_at;
					if ( d < 0 ) return -1;
					if ( d > 0 ) return 1;
					return 0;
				});
				eventClusters[which] = events;
				videoClusterSelected( which );
			});
			return;
		}
		vc.selected = true;
		selectedVideoClustersToSketch();
	}

	var selectedVideoClustersToSketch = function () {
		var selectedClusters = [], events = [];
		for ( var i = 0, k = videoClusters.length; i < k; i++ ) {
			if ( videoClusters[i].selected ) {
				selectedClusters.push( videoClusters[i] );
				events.push( eventClusters[i] );
			}
		}
		sketch.resetClusters( selectedClusters, events );
	}

	var dateToString = function (date) {
		var y = date.getFullYear();
		var m = date.getMonth()+1;
		if ( m < 10 ) m = '0'+m;
		var d = date.getDate();
		if ( d < 10 ) d = '0'+d;
		var h = date.getHours();
		if ( h < 10 ) h = '0'+h;
		var mi = date.getMinutes();
		if ( mi < 10 ) mi = '0'+mi;
		return y+'-'+m+'-'+d+' '+h+':'+mi;
	}

	// --------------------------
	//	class App
	// --------------------------
	
	var App = function ( appConf ) {
		app = this;
		conf = appConf;

		init();
	}
	App.prototype = {
		saveFrame : function ( name ) {
			if ( sketch && sketch.externals.canvas ) {
				var frameDataURI = sketch.externals.canvas.toDataURL("image/png");
				//var win = window.open( frameDataURI, name );
				jQuery.ajax({
					url : 'http://127.0.0.1:55441/save-frame',
					type : 'post',
					data : {
						name: name,
						imageData: frameDataURI
					},
					success: function () {
						console.log("Y");
					},
					error: function (err) {
						console.log( err );
					}
				});
			}
		}
	}

	// --------------------------
	//	class TimeCluster
	// --------------------------

	App.TimeCluster = (function(){
		var TimeCluster = function () {
			this.events = [];
			this.start = null;
			this.end = null;
			this.titles = [];
			if ( arguments.length == 1 && 
				 typeof arguments[0] == 'object' && 
				 'happened_at' in arguments[0] ) {
				this.add( arguments[0] );
			}
		}
		TimeCluster.prototype = {
			intersects : function ( event ) {
				return !(event.finished_at < this.start || event.happened_at > this.end);
			},
			add : function ( event ) {
				if ( !this.start || event.happened_at < this.start )
					this.start = new Date( event.happened_at.getTime() );
				if ( !this.end || event.finished_at > this.end )
					this.end = new Date( event.finished_at.getTime() );
				this.events.push( event );
				if ( this.titles.indexOf(event.title) === -1 ) {
					this.titles.push(event.title);
				}
			},
			toString : function () {
				return dateToString(this.start) + ' - ' + dateToString(this.end) + ' ' + this.titles.join(', ');
			}
		}
		return TimeCluster;
	})();

	return App;
})();