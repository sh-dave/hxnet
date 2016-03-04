package hxnet.base;

import hxnet.interfaces.Protocol;

class Factory implements hxnet.interfaces.Factory
{
	public function new(protocol:Class<Protocol>, ?args:Array<Dynamic>)
	{
		this.protocol = protocol;
		this.args = args;
	}

	public function buildProtocol():Protocol
	{
		return Type.createInstance(protocol, args == null ? [] : args);
	}

	private var protocol:Class<Protocol>;
	private var args:Array<Dynamic>;
}
