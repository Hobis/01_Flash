/**
	@Name: MovieClip Util
	@Author: Hobis Jung(jhb0b@naver.com)
	@Blog: http://blog.naver.com/jhb0b
	@Date: 2011-02-05

*/
package hb.utils
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.ColorMatrixFilter;

	import com.dncompute.graphics.GraphicsUtil;
	import com.dncompute.graphics.ArrowStyle;

	public final class MC_Util
	{
		public function MC_Util()
		{
		}

		// :: 무비클립의 마지막 번호 반환
		public static function setButtonMode(target:MovieClip, b:Boolean,
			type:String = null, handler:Function = null):void
		{
			target.mouseChildren = !b;
			target.tabEnabled = !b;
			target.buttonMode = b;

			if (b)
			{
				if ((type != null) && handler != null)
					target.addEventListener(type, handler);
			}
			else
			{
				if ((type != null) && handler != null)
					target.removeEventListener(type, handler);
			}
		}

		// :: 무비클립의 마지막 번호 반환
		public static function getFileName(url:String):String
		{
			var t_rv:String = null;
			t_rv = decodeURI(url);
			var t_startIndex:int = t_rv.lastIndexOf('/') + 1;
			var t_endIndex:int = t_rv.lastIndexOf('swf') - 1;
			t_rv = t_rv.substring(t_startIndex, t_endIndex);

			return t_rv;
		}

		// :: 무비클립의 마지막 번호 반환
		public static function getLastIndex(name:String, token:String = '_'):int
		{
			var t_rv:int = name.lastIndexOf(token) + 1;
			t_rv = int(name.substr(t_rv));
			return t_rv;
		}

		// :: 무비클립 라인 그리기
		public static function drawLine(canvas:MovieClip,
			fromX:Number, fromY:Number,
			toX:Number, toY:Number,
			color:uint = 0x5F9E45):void
		{
			canvas.graphics.clear();
			canvas.graphics.lineStyle(4, color, 1);
			canvas.graphics.moveTo(fromX, fromY);
			canvas.graphics.lineTo(toX, toY);
		}

		// :: 무비클립 라인 그리기
		public static function drawLine_shape(canvas:Shape,
			fromX:Number, fromY:Number,
			toX:Number, toY:Number,
			color:uint = 0x5F9E45):void
		{
			canvas.graphics.clear();
			canvas.graphics.lineStyle(4, color, 1);
			canvas.graphics.moveTo(fromX, fromY);
			canvas.graphics.lineTo(toX, toY);
		}

		// :: 무비클립 라인 그리기
		public static function drawLine3(g:Graphics,
			fromX:Number, fromY:Number,
			toX:Number, toY:Number,
			color:uint = 0x5F9E45):void
		{
			g.clear();
			g.lineStyle(4, color, 1);
			g.moveTo(fromX, fromY);
			g.lineTo(toX, toY);
		}


/*
import com.dncompute.graphics.ArrowStyle;

//Create a display object to draw into and set the colors
var shape:Shape = new Shape();
shape.graphics.lineStyle(1,0x999999);
shape.graphics.beginFill(0x000000);

//Set the arrow style
var style:ArrowStyle = new ArrowStyle();
style.shaftThickness = 5;
style.headWidth = 40;
style.headLength = 60;
style.shaftPosition = .25;
style.edgeControlPosition = .75;

//Draw an arrow from 30,30 to 100,100
GraphicsUtil.drawArrow(shape.graphics,
		new Point(30,30),new Point(100,100),
		style
		);
*/
		private static var __style:ArrowStyle = null;

		// :: 무비클립 라인 그리기 2
		public static function drawLine2(canvas:MovieClip,
			fromX:Number, fromY:Number,
			toX:Number, toY:Number,
			color:uint = 0x5F9E45):void
		{
			if (__style == null)
			{
				__style = new ArrowStyle();
				__style.shaftThickness = 10;
				__style.headWidth = 40;
				__style.headLength = 30;
				__style.shaftPosition = 0;
				__style.edgeControlPosition = .75;
			}

			canvas.graphics.clear();
			canvas.graphics.lineStyle(4, color, 1);
			canvas.graphics.beginFill(color);

			GraphicsUtil.drawArrow(canvas.graphics,
					new Point(fromX, fromY),
					new Point(toX, toY), __style);
		}

		// :: 무비클립 라인 그리기 a
		public static function drawLine_a(canvas:MovieClip,
			fromX:Number, fromY:Number,
			toX:Number, toY:Number,
			color:uint = 0x5F9E45):void
		{
			if (__style == null)
			{
				__style = new ArrowStyle();
				__style.shaftThickness = 2;
				__style.headWidth = 10;
				__style.headLength = 6;
				__style.shaftPosition = 0;
				__style.edgeControlPosition = .75;
			}

			canvas.graphics.clear();
			canvas.graphics.lineStyle(4, color, 1);
			canvas.graphics.beginFill(color);

			GraphicsUtil.drawArrow(canvas.graphics,
					new Point(fromX, fromY),
					new Point(toX, toY), __style);
		}

		// :: 무비클립 마우스 롤오버, 아웃, 다운, 업 공통 핸들러
		public static function moo(event:MouseEvent):void
		{
			var t_mc:MovieClip = MovieClip(event.currentTarget);

			switch (event.type)
			{
				case MouseEvent.ROLL_OVER:
				{
					t_mc.gotoAndStop(2);
					break;
				}
				case MouseEvent.ROLL_OUT:
				{
					t_mc.gotoAndStop(1);
					break;
				}
				case MouseEvent.MOUSE_DOWN:
				{
					t_mc.gotoAndStop(3);
					break;
				}
				case MouseEvent.MOUSE_UP:
				{
					t_mc.gotoAndStop(2);
					break;
				}
			}
		}

		// :: 무비클립 비활성화 (채도 죽이기)
		public static function setDesat(target:MovieClip, isDesat:Boolean = true):void
		{
			if (isDesat)
				target.filters = [__cmf_desaturation];
			else
				target.filters = [__cmf_normal];
		}

		// :: 무비클립 비활성화 (노멀)
		public static function setEnable(target:MovieClip, b:Boolean, isAndDesat:Boolean = false):void
		{
			target.mouseEnabled = b;

			if (isAndDesat)
				setDesat(target, !b);
		}

		// :: 무비클립 보이고 안보이고
		public static function setVisible(target:MovieClip, b:Boolean):void
		{
			target.visible = b;
		}

		private static const __cmf_desaturation:ColorMatrixFilter = new ColorMatrixFilter
		(
			[
				0.308600008487701, 0.609399974346161, 0.0820000022649765, 0, 0,
				0.308600008487701, 0.609399974346161, 0.0820000022649765, 0, 0,
				0.308600008487701, 0.609399974346161, 0.0820000022649765, 0, 0,
				0, 0, 0, 1, 0
			]
		);

		private static const __cmf_normal:ColorMatrixFilter = new ColorMatrixFilter
		(
			[
				1, 0, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 1, 0, 0,
				0, 0, 0, 1, 0
			]
		);

	}
}
