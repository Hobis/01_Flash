/**
	@Name: FPSTimer
	@Author: Hobis Jung(jhb0b@naver.com)
	@Blog: http://blog.naver.com/jhb0b
	@Encoding: EditPlus(UTF-8 + BOM)
	@Date: 11-07-01
	@Using:
	{

		import flash.events.MouseEvent;
		import hb.frame.FPSTimer;

		function p_onTimer(fpst:FPSTimer):void
		{
			trace('onTimer');
			trace('fpst.currentFrame: ' + fpst.currentCount);
			trace('fpst.repeatCount: ' + fpst.repeatCount);
			trace('fpst.running: ' + fpst.running);
		}

		function p_onTimerEnd(fpst:FPSTimer):void
		{
			trace('onTimerEnd');
			trace('fpst.currentFrame: ' + fpst.currentCount);
			trace('fpst.repeatCount: ' + fpst.repeatCount);
			trace('fpst.running: ' + fpst.running);
		}

		var m_fpst:FPSTimer = null;
		var m_is:Boolean = false;

		this.m_fpst = new FPSTimer(1, 100);
		this.m_fpst.onTimer = this.p_onTimer;
		this.m_fpst.onTimerEnd = this.p_onTimerEnd;
		this.m_fpst.start();


		this.stage.addEventListener(MouseEvent.CLICK,
			function(event:MouseEvent):void
			{
				m_fpst.pause();
			}
		);


	}
*/
package hb.frame
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class FPSTimer
	{
		// :: Constructor
		public function FPSTimer(delayFrame:int, repeatCount:int = 0)
		{
			this.delayFrame = delayFrame;
			this.repeatCount = repeatCount;
		}

		// :: EnterFrame
		private function p_enterFrame(event:Event):void
		{
			if (this.m_nowFrame >= this.delayFrame)
			{
				this.m_nowFrame = 0;
				this.m_currentCount ++;

				if (this.onTimer != null)
				{
					this.onTimer(this);
				}

				if ((this.m_currentCount >= this.repeatCount) && (this.repeatCount > 0))
				{
					this.stop();

					if (this.onTimerEnd != null)
					{
						this.onTimerEnd(this);
					}

				}

			}
			else
			{
				this.m_nowFrame ++;
			}
		}

		// :: Start
		public function start():void
		{
			if (!this.m_running)
			{
				this.m_nowFrame = 0;
				this.m_currentCount = 0;

				__m_useSprite.addEventListener(Event.ENTER_FRAME, this.p_enterFrame);

				this.m_running = true;
			}
		}

		// :: Stop
		public function stop():void
		{
			if (this.m_running)
			{
				__m_useSprite.removeEventListener(Event.ENTER_FRAME, this.p_enterFrame);

				this.m_running = false;
			}
		}

		// :: Pause (Toggle)
		public function pause():void
		{
			if (this.m_running)
			{
				if (this.m_pause)
				{
					__m_useSprite.addEventListener(Event.ENTER_FRAME, this.p_enterFrame);

					this.m_pause = false;
				}
				else
				{
					__m_useSprite.removeEventListener(Event.ENTER_FRAME, this.p_enterFrame);

					this.m_pause = true;
				}
			}
		}

		// ::
		public function get running():Boolean
		{
			return this.m_running;
		}

		// ::
		public function get currentCount():int
		{
			return this.m_currentCount;
		}

		// ::
		public function get nowFrame():int
		{
			return this.m_nowFrame;
		}


		private static var __m_useSprite:Sprite = new Sprite();
		private var m_running:Boolean = false;
		private var m_pause:Boolean = false;

		private var m_currentCount:int;
		private var m_nowFrame:int;

		public var repeatCount:int;
		public var delayFrame:int;

		public var name:String = null;

		public var onTimer:Function = null;
		public var onTimerEnd:Function = null;

	}

}