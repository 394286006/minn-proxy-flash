package flexmdi.managers
{
	
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	import flexmdi.containers.MDICanvas;
	import flexmdi.containers.MDIWindow;
	import flexmdi.containers.PopWin;
	import flexmdi.events.MDIWindowEvent;
	import flexmdi.events.proxy.MessageProxyEvent;
	import flexmdi.events.winresize.WinResizeProxyEvent;
	
	import mx.accessibility.PanelAccImpl;
	import mx.collections.ArrayCollection;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.effects.Move;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.managers.PopUpManager;
	import mx.modules.IModule;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleLoader;
	import mx.modules.ModuleManager;
	
	import spark.components.TitleWindow;

	public class WindowProxy
	{
		//查看小图标
		[Embed(source='assets/images/pop.gif')]
		public  var popicon:Class;
		private var popmv:Move=new Move();
		private  var modules:ArrayCollection=new ArrayCollection();
		private static var _mdic:MDICanvas=null;
		private static var instance:WindowProxy=null;
		private var popwins:ArrayCollection=new ArrayCollection();
		private var minpopwins:ArrayCollection=new ArrayCollection();
		public function WindowProxy()
		{
		}
		
		public static function getInstance(_mdi:MDICanvas=null):WindowProxy{
			if(instance==null)
				instance=new WindowProxy();
			if(_mdi!=null)
				_mdic=_mdi;
			return instance;
		}
		
		public  function getModule(url:String,_mdi:MDICanvas,data:Object=null):MDIWindow{
			var win:MDIWindow=null;
			var ml:ModuleLoader=null;
			for(var i:int=0;i<modules.length;i++){
				if(modules[i].url==url){
					win=modules[i].win;
					ml=win.getElementAt(0) as ModuleLoader;
				}
				
			}
			if(win==null){
				win=new MDIWindow();
				win.setStyle("headerHeight",0);
				win.setStyle("dropShadowEnabled",false);
				win.setStyle("dropShadowColor",0x000000);
				win.setStyle("dropShadowVisible",false);
				win.horizontalScrollPolicy="off";
				win.verticalScrollPolicy="off";
				win.showControls=false;
				win.percentHeight=100;
				win.percentWidth=100;
			    ml=new ModuleLoader();
				ml.percentHeight=100;
				ml.percentWidth=100;
				ml.horizontalScrollPolicy="off";
				ml.verticalScrollPolicy="off";
				ml.addEventListener(ModuleEvent.READY,function(evt:ModuleEvent):void{
					modules.addItem({url:url,win:win});
//					Alert.show(ml.child.name);
					ml.child.addEventListener(FlexEvent.CREATION_COMPLETE,function():void{
						if(data!=null)
						   disP(new MessageProxyEvent(ml.child.name+MessageProxyEvent.MESSAGE_PROXY,data)); 
					});
				  win.addElement(ml);	
				  ml.child.height=win.height;
				  ml.child.width=win.width;
				  ml.applicationDomain=ApplicationDomain.currentDomain; 
				});
				win.addEventListener(CloseEvent.CLOSE,function():void{
					ml.unloadModule();
					win.removeAllElements();
					removeModuleUrl(url);
//					PopUpManager.removePopUp(win);
					_mdi.windowManager.remove(win);
				});
			     ml.loadModule(url);
				_mdi.windowManager.add(win);
				_mdi.windowManager.absPos(win,0,0);
			}else{
				if(data!=null)
				    disP(new MessageProxyEvent(ml.child.name+MessageProxyEvent.MESSAGE_PROXY,data)); 
//				Alert.show(ml.child.name);
				_mdi.windowManager.bringToFront(win);
			}
			
			
			return win;
		}
		
		public  function getPopWindow(url:String,_parent:DisplayObject,data:Object=null,inity:Number=100,initx:Number=380):PopWin{
			var win:PopWin=null;
			var ml:ModuleLoader=null;
		
			for(var i:int=0;i<popwins.length;i++){
				if(popwins[i].url==url)
					win=popwins[i].win;
			}
			if(win==null){
				win=new PopWin();
				win.titleIcon= popicon;
			    
//				win.controlBarVisible=true;
				ml=new ModuleLoader();
				ml.addEventListener(ModuleEvent.READY,function(evt:ModuleEvent):void{
					popwins.addItem({url:url,win:win});
					ml.child.addEventListener(FlexEvent.CREATION_COMPLETE,function():void{
						if(data!=null)
							disP(new MessageProxyEvent(ml.child.name+MessageProxyEvent.MESSAGE_PROXY,data)); 
						
					});
					win.addElement(ml);	
//					Alert.show(ml.child.name);
					win.title=ml.child.name;
//					win.height=ml.child.height+50;
//					Alert.show(win.height+'');
//					win.width=ml.child.width+60;
					ml.applicationDomain=ApplicationDomain.currentDomain; 
					win.initX=initx;
					win.initY=inity;
					popmv.xTo=initx;
					popmv.yTo=inity;
					popmv.target=win;
					popmv.play();
				});
				win.addEventListener(CloseEvent.CLOSE,function():void{
//					Alert.show('win outsize close');
					ml.unloadModule();
					win.removeAllElements();
					PopUpManager.removePopUp(win);
					removePopWinUrl(url);
//					Alert.show(minpopwins.getItemIndex(win).toString());
					removeMinPopWin(win);
				});
				win.addEventListener(WinResizeProxyEvent.WIN_RESTORE_RESIZE,function():void{
//					Alert.show("restore");
					removeMinPopWin(win);
					win.height=win.initH;
					win.width=win.initW;
					popmv.xTo=win.initX;
					popmv.yTo=win.initY;
					popmv.target=win;
					popmv.play();
				});
				win.addEventListener(WinResizeProxyEvent.WIN_MIN_RESIZE,function():void{
//					Alert.show('outsize win resize:'+win.measuredHeight);
//					win.title=ml.child.name;
//				   win.initX=win.x;
//				   win.initY=win.y;
					
				
				   win.initH=win.measuredHeight;
				   win.initW=win.measuredWidth;
				   win.height=40;
				   win.width=160;
//				   Alert.show(minpopwins.length+'');
				   popmv.xTo=280+160*(minpopwins.length)+2;
//				   Alert.show((280*(minpopwins.length+1)).toString());
				   popmv.yTo=45;
				   popmv.target=win;
				   popmv.play();
				   minpopwins.addItem(win);
				});
				ml.loadModule(url);
				PopUpManager.addPopUp(win,_parent);
				PopUpManager.centerPopUp(win);
				
				
//				_mdic.windowManager.add(win);
//				_mdic.windowManager.addCenter(win);
//				(_parent as MDICanvas).windowManager.addCenter(win);
//				PopUpManager.addPopUp(win,_parent):
//				_mdi.windowManager.add(win);
//				_mdi.windowManager.absPos(win,0,0);
			}else{
//				_mdic.windowManager.bringToFront(win);
//				PopUpManager.bringToFront(win);
//				(_parent as MDICanvas).windowManager.bringToFront(win);
			}
			
			
			return win;
			
		}
		
		
		private  function removeModuleUrl(url:String):void{
			for(var i:int=0;i<modules.length;i++){
				if(modules[i].url==url)
					modules.removeItemAt(i);
			}
		}
		
		private function removeMinPopWin(win:Object):void{
			if(minpopwins.getItemIndex(win)!=-1)
				minpopwins.removeItemAt(minpopwins.getItemIndex(win));
		}
		private  function removePopWinUrl(url:String):void{
			for(var i:int=0;i<popwins.length;i++){
				var o:Object=popwins.getItemAt(i);
				if(o.url==url){
					popwins.removeItemAt(i);
//					minpopwins.removeItemAt(minpopwins.getItemIndex(o.win));
				}
			}
		}
		
		public function clearWin():void{
			for(var i:int=0;i<modules.length;i++){
					var win:MDIWindow=modules[i].win;
//				win.close();
				
			}
		}
		
		private   function disP(event:Event):void{
			ProxyMessageManager.getInstance().dispacher(event);
		}
	}
}