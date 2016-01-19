package flexmdi.managers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;

	public class ProxyMessageManager
	{
		private  var dispe:EventDispatcher=null;
		private  static var instance:ProxyMessageManager=null;
		public function ProxyMessageManager()
		{
			dispe=FlexGlobals.topLevelApplication as EventDispatcher;
		}
		
		public static function getInstance():ProxyMessageManager{
			if(instance==null)
				instance=new ProxyMessageManager();
			return instance;
		}
		
		public  function dispacher(evt:Event):Boolean{
			return dispe.dispatchEvent(evt);
		}
		public function addEventListener(type:String,listener:Function):void{
			 dispe.addEventListener(type,listener,false,0,false);
		}
		public function removeEventListener(type:String,listener:Function):void{
			dispe.removeEventListener(type,listener);
		}
	}
}