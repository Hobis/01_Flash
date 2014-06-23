/**
	@Name: ���� ���� ���
	@Author: Hobis Jung
	@Date: 2011-01-30
	@Comment:
	{
		# �� Ŭ������ ���� ���常 ����մϴ�.
			��, �ѹ��� �Ѱ��� �������ϸ� ���ö���¡ �մϴ�.
	}
*/
package hb.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import hb.utils.DebugUtil;

	public final class SimpleSound
	{
		// :: ���� ����� �Ϸ� �Ǿ�����
		private function p_sc_soundComplete(event:Event):void
		{
			this.m_sc.removeEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);

			if (this.onSoundEnd != null)
			{
				this.onSoundEnd();
				this.onSoundEnd = null;
			}

			this.m_isPlaying = false;

			if (this.m_isAfterDispose)
			{
				var t_count:uint = 0;
				for each (var ss:SimpleSound in __instances)
				{
					// �ߺ��Ǵ� ���尡 ������ �ڿ��ݳ�
					if (ss == this)
					{
						ss.stop();
						__instances.splice(t_count, 1);

						//DebugUtil.test('__instances ���� ���ŵ� ��ü ��ȣ: ' + t_count);
						//DebugUtil.test('__instances ���� ���������ִ� ��ȣ: ' + __instances.length);
						break;
					}

					t_count ++;
				}
			}

			DebugUtil.test('SimpleSound->this.m_isPlaying: ' + this.m_isPlaying);
			DebugUtil.test('SimpleSound->__instances.length(���� �ִ� ���� ��ü ����): '
				+ __instances.length);
		}

		// :: ���� �ε尡 �Ϸ� �Ǿ�����.
		private function p_sound_loadComplete(event:Event):void
		{
			if (this.m_sc != null)
			{
				this.m_sc.removeEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);
				this.m_sc.stop();
			}

			this.m_sc = this.m_sound.play();
			this.m_sc.addEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);

			this.m_isPlaying = true;

			DebugUtil.test('����Ǵ� ���� ���� (m_request.url): ' + m_request.url);
		}

		private function p_sound_ioError(event:IOErrorEvent):void
		{
			DebugUtil.test('p_sound_ioError: ' + event);
		}

		public function SimpleSound()
		{
		}

		// :: ���� �ǽð����� ���ÿ��� �ε��Ͽ� ����ϱ�
		public function loadPlay(url:String):void
		{
			if
			(
				(this.m_request == null) ||
				(this.m_request.url != url)
			)
			{
				this.stop();

				this.m_request = new URLRequest(url);

				if (this.m_sound != null)
				{
					this.m_sound.removeEventListener(Event.COMPLETE, this.p_sound_loadComplete);
					this.m_sound.removeEventListener(IOErrorEvent.IO_ERROR, this.p_sound_ioError);
					try
					{
						this.m_sound.close();
					} catch (e:Error) {}
					this.m_sound = null
				}

				this.m_sound = new Sound();
				this.m_sound.addEventListener(Event.COMPLETE, this.p_sound_loadComplete);
				this.m_sound.addEventListener(IOErrorEvent.IO_ERROR, this.p_sound_ioError);
				this.m_sound.load(this.m_request);
			}
			else
			{
				this.p_sound_loadComplete(null);
			}
		}

		// :: ������� ���� ������ ����
		public function stop():void
		{
			if (this.m_sound != null)
			{
				this.m_request = null;
				try
				{
					this.m_sound.close();
				} catch (e:Error) {}

				if (this.m_sc != null)
				{
					this.m_sc.removeEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);
					this.m_sc.stop();
					this.m_sc = null;
				}
			}
		}

		// :: ������� ���� �Ͻ�����
		public function pause():void
		{
			if (this.m_sound != null)
			{
				if (this.m_isPlaying)
				{
					if (this.m_sc != null)
					{
						this.m_pausePosition = this.m_sc.position;
						this.m_sc.removeEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);
						this.m_sc.stop();
						this.m_sc = null;
					}
				}
			}
		}

		// :: �Ͻ��������� ���� �ٽ����
		public function resume():void
		{
			if (this.m_sound != null)
			{
				if (this.m_isPlaying)
				{
					if (this.m_sc != null)
					{
						if (!isNaN(this.m_pausePosition))
						{
							this.m_sc = this.m_sound.play(this.m_pausePosition);
							this.m_sc.addEventListener(Event.SOUND_COMPLETE, this.p_sc_soundComplete);
							this.m_pausePosition = NaN;
						}
					}
				}
			}
		}

		// :: ����� ������ ��ȯ
		public function get_position():Number
		{
			var t_rv:Number = NaN;

			if (this.m_sc != null)
			{
				t_rv = this.m_sc.position;
			}

			return t_rv;
		}


		private var m_sound:Sound = null;
		private var m_sc:SoundChannel = null;
		private var m_request:URLRequest = null;
		private var m_isPlaying:Boolean = false;
		private var m_isAfterDispose:Boolean = false;
		private var m_pausePosition:Number;

		public var onSoundEnd:Function = null;

		//private static var __instances:SimpleSound = null;
		private static var __instances:Vector.<SimpleSound> = null;

		// :: ���� �ε����� ���� ����
		public static function stop(index:int):void
		{
			if (__instances != null)
			{
				var t_ss:SimpleSound = __instances[index];

				if (t_ss != null)
				{
					t_ss.stop();

					DebugUtil.test('t_ss: ' + t_ss);
				}
			}
		}

		// :: ���� �ε����� �Ͻ�����
		public static function pause(index:int):void
		{
			if (__instances != null)
			{
				var t_ss:SimpleSound = __instances[index];

				if (t_ss != null)
				{
					t_ss.pause();

					DebugUtil.test('t_ss: ' + t_ss);
				}
			}
		}

		// :: ���� �ε����� �ٽ����
		public static function resume(index:int):void
		{
			if (__instances != null)
			{
				var t_ss:SimpleSound = __instances[index];

				if (t_ss != null)
				{
					t_ss.resume();

					DebugUtil.test('t_ss: ' + t_ss);
				}
			}
		}

		// :: ���� �÷���
		public static function loadPlay(
			url:String, onSoundEnd:Function = null, isOverlap:Boolean = false):void
		{
			var t_ss:SimpleSound = null;

			if (__instances == null)
			{
				__instances = new Vector.<SimpleSound>();

				t_ss = new SimpleSound();
				__instances.push(t_ss);
			}

			if (isOverlap)
			{
				t_ss = new SimpleSound();
				t_ss.m_isAfterDispose = true;
				t_ss.onSoundEnd = onSoundEnd;
				t_ss.loadPlay(url);

				__instances.push(t_ss);
			}
			else
			{
				t_ss = __instances[0];
				t_ss.onSoundEnd = onSoundEnd;
				t_ss.loadPlay(url);
			}


/*
			if (isOverlap)
			{
				for each (var o:SimpleSound in __instances)
				{
					o.onSoundEnd = onSoundEnd;
					o.loadPlay(url);
				}
			}
			else
			{
				__instances[0].
			}*/

//			if (__instance == null)
//			{
//				__instance = new SimpleSound();
//			}
//
//			__instance.onSoundEnd = onSoundEnd;
//			__instance.loadPlay(url);
		}

		// :: ���� �÷���
		public static function get_position(index:int):Number
		{
			var t_rv:Number = NaN;

			if (__instances != null)
			{
				var t_ss:SimpleSound = __instances[index];
				t_rv = t_ss.get_position();
			}

			return t_rv;
		}
	}
}
