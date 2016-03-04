package hxnet.interfaces;

interface Client
{
	public function connect(?hostname:String, ?port:Null<Int>, ?callback:Bool->String->Void):Void;
	public function update(timeout:Float=1):Void;
	public function close():Void;
}
