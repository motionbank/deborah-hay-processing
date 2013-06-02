
var express 	= require('express'),
	app 		= express(),
	fs 			= require("fs");

app.use( express.bodyParser() );

app.use( function(req, res, next) {
	var oneof = false;
	if (req.headers.origin) {
		res.header('Access-Control-Allow-Origin', req.headers.origin);
		oneof = true;
	}
	if (req.headers['access-control-request-method']) {
    	res.header('Access-Control-Allow-Methods', req.headers['access-control-request-method']);
		oneof = true;
	}
	if (req.headers['access-control-request-headers']) {
		res.header('Access-Control-Allow-Headers', req.headers['access-control-request-headers']);
		oneof = true;
	}
	if (oneof) {
		res.header('Access-Control-Max-Age', 60 * 60 * 24 * 365);
	}
    // intercept OPTIONS method
    if (oneof && req.method == 'OPTIONS') {
		res.send(200);
    } else {
		next();
	}
});

app.post( '/save-frame', function (req, res) {

	var name = req.body.name;
	var data = req.body.imageData;
	var dataType = 'png';
	var base64Data = data.replace( /^data:image\/(png|jpeg);base64,/, "" );
	var buf = new Buffer(base64Data, 'base64');
	var tmpPth = __dirname + '/output/' + name + '.' + dataType;
	fs.writeFileSync( tmpPth, buf, 'binary' );

	res.send('OK');
});

var port = 55441;
app.listen( port, function() {
	console.log( "Listening on " + port );
});