/**
	@name : DisposeSupporter  ver 1.0.5
	@author : jungheebum [jhb0b@naver.com]
	@date : 2008-09-05
	@comments :
	{
		This class is for improving the performance of Flash Player Garbage Collection tool.
		Just by using a simple application of performance importance.
	}
	@using :
	{

		import hb.utils.DisposeSupporter;

		// - Detail clear at DisplayObjectContainer
		DisposeSupporter.containerDetailClear(container, true, true);
		// - Detail clear at DisplayObject
		DisposeSupporter.displayObjectDispose(container, true, true);
		// - Simple clear at DisplayObject
		DisposeSupporter.containerClear(container);
		// - Garbage Collection Call
		DisposeSupporter.gc();

		// - Detail clear at Loader
		DisposeSupporter.loaderDispose(loader, true, true);
		// - Detail clear at Bitmap
		DisposeSupporter.bitmapDispose(bimap);
		// - Detail clear at Bitmap
		DisposeSupporter.simpleButtonDispose(simpleButton, true, true);
		// - Detail clear at shape
		DisposeSupporter.shapeDispose(shape);

	}
*/
package hb.utils
{

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Shape;
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.net.LocalConnection;

	public final class DisposeSupporter
	{
		public function DisposeSupporter()
		{
		}

		public static var isTrace:Boolean = true;

		private static function p_trace(v:String):void
		{
			if (isTrace)
			{
				trace('# DisposeSupporter  : ' + v);
			}
		}

		// :: Loader optimized in garbage collection
		public static function loaderDispose(target:Loader, isSub:Boolean = false, isDetail:Boolean = false):void
		{
			var t_do:DisplayObject = target.content;

			if (t_do != null)
			{
				displayObjectDispose(t_do, isSub, isDetail);

				target.unload();

				p_trace('loaderDispose');
			}
		}

		// :: Bitmap object disposed
		public static function bitmapDispose(target:Bitmap):void
		{
			try
			{
				if (target.bitmapData != null)
					target.bitmapData.dispose();

				p_trace('bitmapDispose');
			}
			catch (e:Error)
			{
			}
		}

		// :: SimpleButton
		public static function simpleButtonDispose(target:SimpleButton, isSub:Boolean = false, isDetail:Boolean = false):void
		{

			if (target.upState != null)
				displayObjectDispose(target.upState, isSub, isDetail);
			if (target.overState != null)
				displayObjectDispose(target.overState, isSub, isDetail);
			if (target.downState != null)
				displayObjectDispose(target.downState, isSub, isDetail);
			if (target.hitTestState != null)
				displayObjectDispose(target.hitTestState, isSub, isDetail);

			//trace('button '+target.upState);
			//trace('button '+target.overState);
			//trace('button '+target.downState);
			//trace('button '+target.hitTestState);

			p_trace('simpleButtonDispose');

		}

		public static function shapeDispose(target:Shape):void
		{
			target.graphics.clear();

			p_trace('shapeDispose');

		}

		public static function displayObjectDispose(target:DisplayObject, isSub:Boolean = false, isDetail:Boolean = false):void
		{
			if (isSub)
			{
				if (target is DisplayObjectContainer)
				{
					if (isDetail)
					{
						containerDetailClear(DisplayObjectContainer(target));
					}
					else
					{
						containerClear(DisplayObjectContainer(target));
					}
				}
			}

			if (target is Bitmap)
			{
				bitmapDispose(Bitmap(target));
			}
			else if (target is Loader)
			{
				loaderDispose(Loader(target), isSub, isDetail);
			}
			else if (target is MovieClip)
			{
				MovieClip(target).gotoAndStop(1);
			}
			else if (target is SimpleButton)
			{
				simpleButtonDispose(SimpleButton(target), isSub, isDetail);
			}
			else if (target is Shape)
			{
				shapeDispose(Shape(target));
			}

			p_trace('displayObjectDispose');

		}

		// :: DisplayObjectContainer of removed childs
		public static function containerClear(target:DisplayObjectContainer, isSub:Boolean = false):void
		{
			var i:int = target.numChildren;
			var t_do:DisplayObject = null;

			try
			{
				while (i--)
				{
					t_do = target.getChildAt(0);

					if (isSub)
					{
						if (t_do is DisplayObjectContainer)
							containerClear(DisplayObjectContainer(t_do), isSub);
					}

					target.removeChild(t_do);
				}
			}
			catch (e:Error)
			{
			}

		}

		// :: DisplayObjectContainer of removed childs strong
		public static function containerDetailClear(target:DisplayObjectContainer, isSub:Boolean = false, isDetail:Boolean = false):void
		{
			var i:int = target.numChildren;
			var t_do:DisplayObject = null;

			try
			{
				while (i--)
				{
					t_do = target.getChildAt(0);

					displayObjectDispose(t_do, isSub, isDetail);

					target.removeChild(t_do);
				}
			}
			catch (e:Error)
			{
			}

		}

		public static function gc():void
		{
			if (Capabilities.isDebugger)
			{
				System.gc();
			}
			else
			{
				try
				{
				   new LocalConnection().connect('foo');
				   new LocalConnection().connect('foo');
				}
				catch (e:Error)
				{
				}

			}

		}

	}

}