package hxnet.tcp;


#if flash
import flash.events.Event;
import flash.net.Socket;
#else
import sys.net.Host;
import sys.net.Socket;
#end
import haxe.io.Bytes;
import haxe.io.BytesInput;
import hxnet.interfaces.Protocol;

class Client implements hxnet.interfaces.Client
{

	public var protocol(default, set):Protocol;
	public var blocking(default, set):Bool = true;
	public var connected(get, never):Bool;
	public var disconnectedHandler(default, default):String->Void;
	public var connectedHandler(default, default):Bool->String->Void;

	public function new()
	{
		buffer = Bytes.alloc(8192);
	}

	public function connect(?hostname:String, port:Null<Int> = 12800)
	{
		try
		{
			client = new Socket();
#if flash
			client.addEventListener(Event.CONNECT, client_connectHandler);
			client.addEventListener(flash.events.IOErrorEvent.IO_ERROR, client_ioErrorHandler);
			client.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, client_securityErrorHandler);
			client.connect(hostname, port);
#else
			if (hostname == null) hostname = Host.localhost();
			client.connect(new Host(hostname), port);
			client.setBlocking(blocking);
#end
			// prevent recreation of array on every update
			readSockets = [client];

#if !flash
			if (protocol != null)
			{
				protocol.onConnect(new Connection(client));
			}

			if (connectedHandler != null) {
				// TODO (DK) can we actually be sure we're connected?
				connectedHandler(true, null);
			}
#end
		}
		catch (e:Dynamic)
		{
			trace(e);
			client = null;

			if (connectedHandler != null) {
				connectedHandler(false, Std.string(e));
			}
		}
	}

#if flash
	function client_connectHandler( _ ) {
		if (protocol != null) {
			protocol.onConnect(new Connection(client));
		}

		if (connectedHandler != null) {
			connectedHandler(true, null);
		}

		flashConnectedFlag = true;
	}

	function client_ioErrorHandler( event : flash.events.IOErrorEvent ) {
		flashConnectedFlag = false;

		if (connectedHandler != null) {
			connectedHandler(false, event.text);
		}
	}

	function client_securityErrorHandler( event : flash.events.SecurityErrorEvent ) {
		flashConnectedFlag = false;

		if (connectedHandler != null) {
			connectedHandler(false, event.text);
		}
	}
#end

	public function update(timeout:Float=0)
	{
		if (!connected) return;

		try
		{
#if flash
			readSocket(client);
#else
			if (blocking)
			{
				protocol.dataReceived(client.input);
			}
			else
			{
				var select = Socket.select(readSockets, null, null, timeout);
				for (socket in select.read)
				{
					readSocket(socket);
				}
			}
#end
		}
		catch (e:Dynamic)
		{
			//if (Std.is(e, haxe.io.Eof) #if flash || Std.is(e, flash.errors.IOError)) {
				if (protocol != null) {
					protocol.loseConnection(Std.string(e));
					protocol = null;
				}

				if (client != null) {
#if flash
					if (client.connected)
#end
						client.close();

					client = null;
				}

#if flash
				flashConnectedFlag = false;
#end
				if (disconnectedHandler != null) {
					disconnectedHandler(Std.string(e));
				}
			//}
		}
	}

	private function readSocket(socket:Socket)
	{
		var byte:Int = 0,
			bytesReceived:Int = 0,
			len = buffer.length;
		while (bytesReceived < len)
		{
			try
			{

				byte = #if flash socket.readByte() #else socket.input.readByte() #end;
			}
			catch (e:Dynamic)
			{
				// end of stream
                if (Std.is(e, haxe.io.Eof) || e == haxe.io.Error.Blocked #if flash || Std.is(e, flash.errors.EOFError) #end)
				{
					buffer.set(bytesReceived, byte);
					break;
				} else {
#if flash
					if (Std.is(e, flash.errors.IOError)) {
						throw e;
					}
#end
					var xxx = 666;
				}
			}

			buffer.set(bytesReceived, byte);
			bytesReceived += 1;
		}

		// check that buffer was filled
		if (bytesReceived > 0)
		{
			protocol.dataReceived(new BytesInput(buffer, 0, bytesReceived));// , bytesReceived);
		}
	}

	public function close()
	{
		if (client != null) {
#if flash
			client.removeEventListener(Event.CONNECT, client_connectHandler);
			client.removeEventListener(flash.events.IOErrorEvent.IO_ERROR, client_ioErrorHandler);
			client.removeEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, client_securityErrorHandler);

			if (client.connected)
#end
				client.close();

			client = null;
		}

		if (protocol != null) {
			protocol.loseConnection();
			protocol = null;
		}

#if flash
		flashConnectedFlag = false;
#end

		if (disconnectedHandler != null) {
			disconnectedHandler('close requested');
		}
	}

	private inline function get_connected():Bool
	{
		return client != null && protocol != null #if flash && flashConnectedFlag #end;
	}

	private function set_blocking(value:Bool):Bool
	{
		if (blocking == value) return value;
#if !flash
		if (client != null) client.setBlocking(value);
#end
		return blocking = value;
	}

	private function set_protocol(value:Protocol):Protocol
	{
		if (client != null && value != null)
		{
			value.onConnect(new Connection(client));
		}
		return protocol = value;
	}

	private var client:Socket;
	private var readSockets:Array<Socket>;
	private var buffer:Bytes;

#if flash
	var flashConnectedFlag = false;
#end
}
