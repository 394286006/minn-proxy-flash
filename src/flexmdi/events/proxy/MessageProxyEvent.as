package flexmdi.events.proxy
{
	import flash.events.Event;
	
	public class MessageProxyEvent extends Event
	{
		public static var MESSAGE_PROXY:String="messageProxy";
		
		private var _data:Object;
		
		public function MessageProxyEvent(type:String,_data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._data=_data;
		}
		
		public function set data(da:Object):void{
			this._data=da;
		}
		
		public function get data():Object{
			return this._data;
		}
	}
}