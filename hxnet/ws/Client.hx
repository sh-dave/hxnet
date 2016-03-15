package hxnet.ws;

import haxe.io.Bytes;
import js.html.ArrayBuffer;

#if js
class Client {
	var onText : String -> Void;
	var onBinary : Bytes -> Void;
	var socket : js.html.WebSocket;

	public var disconnectedHandler(default, default):String->Void;
	public var connectedHandler(default, default):Bool->String->Void;

	public function new( onText : String -> Void, onBinary : Bytes -> Void ) {
		this.onText = onText;
		this.onBinary = onBinary;
	}

	public function connect( hostname : String, port : Int ) {
		if (socket != null) {
			socket.close(0, 'force closing due to connect() call');
		}

		socket = new js.html.WebSocket('ws://${hostname}:${port}');
		socket.binaryType = js.html.BinaryType.ARRAYBUFFER;
		socket.onmessage = function( line ) {
			// TODO (DK) is this efficient?
			var buffer : ArrayBuffer = cast line.data;
			var bytes = Bytes.ofData(buffer);
			var message = bytes.toString();

			if (onText != null) {
				onText(message);
			}
		}

		if (connectedHandler != null) {
			connectedHandler(true, null);
		}
	}

	//public function update( timeout : Float = 1 ) {
	//}

	public function sendText( text : String ) {
		socket.send(Bytes.ofString(text).getData());
	}

	public function sendBinary( bytes : Bytes ) {
		socket.send(bytes.getData());
	}

	public function close() {
		socket.close(0, 'close requested');
	}
}
#end
