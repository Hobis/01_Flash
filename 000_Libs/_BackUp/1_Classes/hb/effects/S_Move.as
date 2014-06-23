/**
	@Name: Smooth Move [AS3.0]
	@Author: Hobis Jung (jhb0b@naver.com)
	@Date: 2011-01-29
	@Using:
	{
		import hb.effects.S_Move;

		var smove:S_Move = new S_Move();
		smove.move(rect_mc, 'x', 100, 0.2);
		smove.onMoveEnd = function()
		{
			trace('end');
		};
	}
*/
package hb.effects
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	// :: 하나만 쓰임
	public class S_Move
	{
		public function S_Move()
		{
		}

		/**
			@Params :
			{
				target - 타겟 디스플레이 오브젝트
				prop - 속성 이름
				toValue - 채인지포지션 넘버
				speed - 속도계수 0.01~0.99
			}
		*/
		public function move(target:DisplayObject, prop:String,
										toValue:Number, speed:Number):void
		{
			this.target = target;
			this.prop = prop,
			this.toValue = toValue,
			this.speed = speed,

			this.target.addEventListener(Event.ENTER_FRAME, this.movEenterFrame);
		}

		public function reset():void
		{
			this.stop();

			this.target = null;
			this.prop = null;
			this.toValue = 1;
			this.speed = .6;
		}

		public function stop():void
		{
			this.target.removeEventListener(Event.ENTER_FRAME, this.movEenterFrame);
		}

		private function movEenterFrame(event:Event):void
		{
			var t_dist:Number = this.toValue - this.target[this.prop];

			if (Math.abs(t_dist) < 1)
			{
				this.target.removeEventListener(Event.ENTER_FRAME, this.movEenterFrame);
				this.target[this.prop] = this.toValue;

				// 콜백 실행
				if (this.onMoveEnd != null)
					this.onMoveEnd();

				//trace('SMove Last: ' + this.target[this.prop]);
				return;
			}

			//trace('SMove Ing: ' + this.target[this.prop]);
			this.target[this.prop] = this.target[this.prop] + (t_dist * this.speed);
		}



		/////////////////////////////////////////////////////////////////////////////////////

		public var target:DisplayObject = null;
		public var prop:String = null;
		public var toValue:Number = 1;
		public var speed:Number = .6;

		// :: Move End CallBack
		public var onMoveEnd:Function = null;

	}

}
