package hxnet.ws;

import haxe.io.Bytes;

#if js
class Client {
	var onText : String -> Void;
	var onBinary : Bytes -> Void;
	var socket : js.html.WebSocket;

	public function new( onText : String -> Void, onBinary : Bytes -> Void ) {
		this.onText = onText;
		this.onBinary = onBinary;
	}

	public function connect( hostname : String, port : Int ) {
		if (socket != null) {
			socket.close(0, 'force closing due to connect() call');
		}

		socket = new js.html.WebSocket('ws://${hostname}:${port}');
		socket.onmessage = function( line ) {
			trace('xxx');
			trace(line);
			trace(line.data);

			//var message = haxe.Json.parse(line.data);
			//trace(message);
//
			//if (onText != null) {
				//onText(message);
			//}
		}
	}

	public function update( timeout : Float = 1 ) {
	}

	public function sendText( text : String ) {
		socket.send(Bytes.ofString(text).getData());
	}

	public function close() {
		socket.close(0, 'close requested');
	}
}
#end
