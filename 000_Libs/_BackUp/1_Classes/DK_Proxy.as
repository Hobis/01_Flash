package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import hb.utils.SimpleSound;
	import hb.utils.DebugUtil;
	import com.nekoi.sangrok.Common;

	public final class DK_Proxy
	{
		// :: 사운드 효과 플레이
		public static function se_over():void
		{
			SimpleSound.loadPlay(SE_OVER, null, true);
		}

		public static function se_select():void
		{
			SimpleSound.loadPlay(SE_SELECT, null, true);
		}

		public static function se_miss():void
		{
			SimpleSound.loadPlay(SE_MISS, null, true);
		}

		public static function se_clear():void
		{
			SimpleSound.loadPlay(SE_CLEAR);
		}

		public static function se_yes():void
		{
			SimpleSound.loadPlay(SE_YES);
		}

		public static function se_no():void
		{
			SimpleSound.loadPlay(SE_NO);
		}

		public static function se_yes_g():void
		{
			SimpleSound.loadPlay(SE_YES_G);
		}

		public static function se_no_g():void
		{
			SimpleSound.loadPlay(SE_NO_G);
		}

		public static function se_great():void
		{
			SimpleSound.loadPlay(SE_GREATE);
		}

		public static function se_try_again():void
		{
			SimpleSound.loadPlay(SE_TRY_AGAIN);
		}

		// :: 문자열 처음,끝 공백제거
		public static function getWhiteSpaceClear(target:String, type:String = 'end', changeStr:String = ''):String
		{
			var t_rv:String = target;
			var t_regBegin:RegExp = new RegExp('^\\s*');
			var t_regEnd:RegExp = new RegExp('\\s*$');

			if (type == 'begin')
				t_rv = t_rv.replace(t_regBegin, changeStr);
			else if (type == 'end')
				t_rv = t_rv.replace(t_regEnd, changeStr);
			else if (type == 'beginEnd')
			{
				t_rv = t_rv.replace(t_regBegin, changeStr);
				t_rv = t_rv.replace(t_regEnd, changeStr);
			}

			return t_rv;
		}

		// :: 배열에서 값이 있는지 여부
		public static function getIsContains(target:Array, value:Object):Boolean
		{
			var t_rv:Boolean = false;

			var t_la:int, i:int;

			t_la = target.length;

			for (i = 0; i < t_la; i ++)
			{
				if (target[i] == value)
				{
					t_rv = true;
					break;
				}
			}

			return t_rv;
		}

		// :: 배열 요소가 순서대로 같은지 여부 (1차원배열만 길이도 같아야 됨)
		public static function arrayEquals_1(aa:Array, ab:Array):Boolean
		{
			var t_rv:Boolean = false;

			if (aa == ab)
				t_rv = true;
			else
			{
				if (aa.length == ab.length)
				{
					var t_la:int = aa.length, i:int;
					for (i = 0; i < t_la; i ++)
					{
						t_rv = (aa[i] == ab[i]);

						if (!t_rv) break;
					}
				}
			}

			return t_rv;
		}

		// :: 배열 요소가 섞여 있어도 값이 개수만큼 같은지 여부
		public static function arrayIsEqual(aa:Array, ab:Array):Boolean
		{
			var t_rv:Boolean = false;

			var t_la:int, i:int;
			var t_lb:int, j:int;
			var t_bool:Boolean = false;
			var t_count:int = 0;

			t_la = aa.length;

			for (i = 0; i < t_la; i ++)
			{
				t_lb = ab.length;

				for (j = 0; j < t_lb; j ++)
				{
					if (aa[i] == ab[j])
						t_bool = true;
				}

				if (t_bool)
				{
					t_count ++;
					t_bool = false;
				}
			}

			if (t_count >= t_la)
				t_rv = true;

			return t_rv;
		}

		// :: 다중배열에서 배열이 아닌 원소의 총개수를 구하는 함수
		public static function getTotalLength(target:Array):uint
		{
			var t_rv:uint = 0;

			var t_len:uint = target.length, i:uint;
			var t_item:Object = null;

			for (i = 0; i < t_len; i ++)
			{
				t_item = target[i];

				if (t_item is Array)
					t_rv += arguments.callee(t_item);
				else
					t_rv ++;
			}

			return t_rv;
		}

		public static function delayToNextFrame(owner:MovieClip):void
		{
			if (owner.m_ef_len == undefined)
			{
				var t_frameRate:Number;

				if (owner.stage != null)
					t_frameRate = owner.stage.frameRate;
				else
					t_frameRate = 30;

				owner.m_ef_len = (isNaN(Common.contentsDelay) ? 2 : Common.contentsDelay) * t_frameRate;
				owner.m_ef_count = 0;
			}

			owner.addEventListener(Event.ENTER_FRAME,
				function(event:Event):void
				{
					var t_target:MovieClip = MovieClip(event.currentTarget);

					if (t_target.m_ef_count < t_target.m_ef_len)
					{
						t_target.m_ef_count ++;
					}
					else
					{

						t_target.removeEventListener(Event.ENTER_FRAME, arguments.callee);
						t_target.gotoAndStop(2);

						Common.dispatchEvent(new Event(Common.CONTENTS_LOAD_COMPLETE));

						t_target.m_ef_count = 0;
					}
				}
			);
		}


		// :: 사운드 효과 URL정보
		public static const BASE_URL:String ='contents/sound/';

		public static const SE_OVER:String = BASE_URL + 'se_over_0.mp3';
		//public static const SE_SELECT:String = BASE_URL + 'se_click_0.mp3';
		public static const SE_SELECT:String = BASE_URL + 'click.mp3';
		public static const SE_MISS:String = BASE_URL + 'se_failed_0.mp3';
		public static const SE_CLEAR:String = BASE_URL + 'se_stage_clear.mp3';
		public static const SE_YES:String = BASE_URL + 'yes.mp3';
		public static const SE_NO:String = BASE_URL + 'no.mp3';
		public static const SE_YES_G:String = BASE_URL + 'g_yes.mp3';
		public static const SE_NO_G:String = BASE_URL + 'g_no.mp3';
		public static const SE_GREATE:String = BASE_URL + 'se_great.mp3';
		public static const SE_TRY_AGAIN:String = BASE_URL + 'se_try_again.mp3';
	}
}
