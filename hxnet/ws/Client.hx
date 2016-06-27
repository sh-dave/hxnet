package hxnet.ws;

#if (sys_html5 || sys_debug_html5)
import haxe.io.Bytes;
import js.html.ArrayBuffer;

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
			//socket.close(0, 'force closing due to connect() call');
			trace('still connected');
			return;
		}

		socket = new js.html.WebSocket('ws://${hostname}:${port}');
		socket.binaryType = js.html.BinaryType.ARRAYBUFFER;
		socket.onmessage = function( line ) {
			// TODO (DK) is this efficient?
			var buffer : ArrayBuffer = cast line.data;
			var bytes = Bytes.ofData(buffer);

			if (onText != null) {
				onText(bytes.toString());
			}

			if (onBinary != null) {
				onBinary(bytes);
			}
		}

		if (connectedHandler != null) {
			connectedHandler(true, null);
		}
	}

	public function sendText( text : String ) {
		socket.send(Bytes.ofString(text).getData());
	}

	public function sendBinary( bytes : Bytes ) {
		socket.send(bytes.getData());
	}

	public function close() {
		if (socket == null) {
			trace('no socket created');
			return;
		}

		socket.close(0, 'close requested');
	}
}
#end
