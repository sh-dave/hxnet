package hxnet.tcp;

#if flash
import flash.net.Socket;
#else
import sys.net.Socket;
#end
import haxe.io.Bytes;

class Connection implements hxnet.interfaces.Connection
{

	public function new(socket:Socket)
	{
		this.socket = socket;
	}

	public function isOpen()
	{
		return socket != null;
	}

	public function writeBytes(bytes:Bytes):Bool
	{
		try
		{
#if flash
			// if (writeLength) socket.writeInt(bytes.length);
			for (i in 0...bytes.length)
			{
				socket.writeByte(bytes.get(i));
			}

			socket.flush();
#else
			// if (writeLength) socket.output.writeInt32(bytes.length);
			socket.output.writeBytes(bytes, 0, bytes.length);
#end
		}
		catch (e:Dynamic)
		{
			#if debug
			trace("Error writing to socket: " + e);
			#end
			return false;
		}
		return true;
	}

	public function close()
	{
		socket.close();
		socket = null;
	}

	private var socket:Socket;

}
