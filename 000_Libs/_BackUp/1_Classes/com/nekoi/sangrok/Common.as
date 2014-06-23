package com.nekoi.sangrok{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.IEventDispatcher;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.fscommand;
	import flash.utils.setTimeout;


	public class Common{
		public static var pageNum:Number;
		public static var viewPage:Number;
		public static var loadStr:String;
		public static var maxPageNum:Number;
		public static var maxViewPage:Number;
		public static var makeStr:String;
		public static var sliceStr:String;
		public static var firstPage:Number;
		public static var contentArray:Array;
		public static var recMode:Boolean;
		public static var eBookPageArray:Array;
		public static var webCheck:Boolean;
		public static var titleText:String;
		public static var lessonText:String;
		public static var isPlayer:Number;
		public static var homeFirstOpen:Boolean = false;
		public static var alertMsg:String;
		public static var homeToSendPage:Number;
		public static var masterVolume:Number;
		public static var contentsData:Array;
		public static var contentsDelay:Number;
		public static const CONTENTS_LOAD_COMPLETE:String = "contentsLoadComplete";
		public static const CONTENTS_DISPOSE:String = "contentsDispose";
		public static const OPEN_CONTENTS:String = "openContents";
		public static const CLOSE_CONTENTS:String = "closeContents";
		public static const PAGE_MOVE_TO_CONTENTS:String = "pageMove";
		public static const CONECT_CLOSE:String = "conectClose";
		public static const WINDOW_FULL:String = "fullMode";
		public static const WINDOW_MIDDLE:String = "middleMode";
		public static const FULL_SCREEN:String = "fullScreen";
		public static const NORMAL_SCREEN:String = "normalScreen";
		public static const PROGRAM_END_ALERT:String = "exitAlert";
		public static const SELECT_PAGE_NUMBER:String = "selectPageNumber";
		public static const POPUP_CLOSE:String = "popupClose";
		public static const VOLUME:String = "volume";
		private static var obj:Object;
		public static var eventArray:Array;

		public function Common() {
			// constructor code
		}

		public static function set mc(_mc:Object):void{
			obj = _mc;
		}
		/*
		함수 : titlebar
		파라메터 : "exit" or "resize" or "min"
		titlebarMin --> 리턴값 titlebarMin
		titlebarExit --> 리턴값 : 없음/그냥 종료됨
		titlebarResize --> 리턴값(full/middle)
		*/

		public static function dispatchEvent(e:Event):void
		{
			if (eventArray != null)
			{			
				var t_len:uint = eventArray.length
				for (var i:uint = 0; i < t_len; i ++)
				{
					if(e.type == eventArray[i][0])
						eventArray[i][1](e);
				}
			}
		}

		public static function addEventListener(str:String,fn:Function):void{
			if(eventArray == null) eventArray = new Array();
			for(var i = 0 ; i < eventArray.length ; i++){
				if(eventArray[i][0] == str){
					eventArray[i][0] = str;
					eventArray[i][1] = fn;
					return;
				}
			}
			eventArray.push(new Array(str,fn));
		}

		public static function removeEventListener(str:String,fn:Function):void{
			if(eventArray == null) eventArray = new Array();
			for (var i = 0 ; i < eventArray.length ; i++){
				if(eventArray[i][0] == str){
					eventArray.splice(i,1);
				}
			}
		}


		public static function dxrCallTitlebar(type:String,str:String = null):void {
			trace("common.dxr",type,str)
			if (homeFirstOpen == true) {
				if (str == "exit") {
					obj.dispatchEvent(new Event(Common.CONECT_CLOSE));
				}
			}
			var dataStr:String;
			switch (type) {
				case "resize" :
					dataStr = "titlebarResize";
					break;
				case "min" :
					dataStr = "titlebarMin";
					break;
				case "exit" :
					dataStr = "titlebarExit";
					break;
				case "file" :
					if (webCheck == true) {

					} else {
						fscommand("openFile", str);
					}
					return;
					break;
				case "alert" :
					if (webCheck == true) {

					} else {
						fscommand("alert", str);
					}
					return;
					break;
				case "openURL" :
					if (webCheck == true) {

					} else {
						trace("open",str)
						fscommand("openURL", str);
						setTimeout(Common.openURL, 500);
					}
					return;
					break;
				case "capture" :
					fscommand("capture", str);
				break;

			}
			if (webCheck == true) {

			} else {
				var returnSize:String = ExternalInterface.call(dataStr);
				Common.received(returnSize);
			}
		}

		public static function openURL():void {
			Common.dxrCallTitlebar("min");
		}

		public static function exitAlert():void{
			obj.dispatchEvent(new Event(Common.PROGRAM_END_ALERT));
		}

		public static function nextGo(xNum:Number):void{
			Common.homeToSendPage = xNum;
			obj.dispatchEvent(new Event(Common.SELECT_PAGE_NUMBER));
		}

		public static function received(str:String):void {
			switch (str) {
				case "titlebarfull" :
					obj.dispatchEvent(new Event(Common.WINDOW_FULL));
					break;
				case "titlebarmiddle" :
					obj.dispatchEvent(new Event(Common.WINDOW_MIDDLE));
					break;
			}
		}
	}
}