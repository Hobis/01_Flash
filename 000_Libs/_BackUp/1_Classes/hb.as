this.stop();

/**
# 본 스크립트는 한번만 실행 됩니다.

@초기작성자: Hobis Jung
@작성일자: 110121
*/

if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import hb.effects.S_Move;
	import utils.ComHandler;
	import utils.MC_Util;
	import utils.SimpleSound;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	1 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 드래그 사용 비트맵 리셋
	var p_frame_1_dragBitmap_reset:Function = function():void
	{
		this.m_dataObj.d_dragBitmap.x = 0;
		this.m_dataObj.d_dragBitmap.y = 0;
		this.m_dataObj.d_dragBitmap.visible = false;
		this.m_dataObj.d_drag_bd.fillRect(this.m_dataObj.d_drag_bd.rect, 0x00000000);
	};

	// :: 1 프래임 드래그 마우스 업
	var p_frame_1_drag_mouseUp:Function = function(event:MouseEvent):void
	{
		m_target.stage.removeEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		var t_mc:MovieClip = null;
		var t_len:int = m_dataObj.answers.length;
		var t_mx:Number = m_bogisCont.mouseX;
		var t_my:Number = m_bogisCont.mouseY;
		var t_ia:int, t_ib:int;
		var t_afterBool:Boolean = false;

		for (var i:int = 0; i < t_len; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];

			if
			(
				(
					(t_mx >= t_mc.x) &&
					(t_mx <= (t_mc.x + t_mc.width))
				) &&
				(
					(t_my >= t_mc.y) &&
					(t_my <= (t_mc.y + t_mc.height))
				) &&

				(t_mc.d_isSound)
			)
			{
				t_ia = p_getLastIndex(t_mc.name);
				t_ib = p_getLastIndex(m_dataObj.d_nowDrag.name);

				if (m_dataObj.pd == null)
					m_dataObj.pd = new Array(m_dataObj.answers.length);
				m_dataObj.pd[t_ia] = m_dataObj.dragValues[t_ib];

				t_mc.tf.text = m_dataObj.pd[t_ia];

				if (!t_mc.d_isDragIn)
				{
					p_frame_1_answerCountCheck();
					t_mc.d_isDragIn = true;
				}

				t_afterBool = true;

				break;
			}
		}

		if (t_afterBool)
		{
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				t_mc.x, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				t_mc.y, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};

			m_bogisCont.soundClip_mc.gotoAndPlay('#_0');

			t_afterBool = false;
		}
		else
		{
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				m_dataObj.d_nowDrag.x, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				m_dataObj.d_nowDrag.y, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};

			m_bogisCont.soundClip_mc.gotoAndPlay('#_1');
		}


		p_trace('현재 푼답: ' + m_dataObj.pd);
	}

	// :: 1 프래임 드래그 마우스 무브
	var p_frame_1_drag_mouseMove:Function = function(event:MouseEvent):void
	{
		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;

		event.updateAfterEvent();
	};

	// :: 1 프래임 드래그 마우스 다운
	var p_frame_1_drag_mouseDown:Function = function(event:MouseEvent):void
	{
		m_target.stage.addEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		m_dataObj.d_nowDrag = MovieClip(event.currentTarget);

		if (m_dataObj.d_dragBitmap == null)
		{
			m_dataObj.d_drag_bd = new BitmapData(
					m_dataObj.d_nowDrag.width,
					m_dataObj.d_nowDrag.height, true, 0x00000000);
			m_dataObj.d_dragBitmap = new Bitmap(m_dataObj.d_drag_bd);
			m_dataObj.d_dragBitmap.alpha = 0.6;
			m_dataObj.d_dragBitmap.visible = false;
			m_bogisCont.addChild(m_dataObj.d_dragBitmap);
		}

		m_dataObj.d_drag_bd.draw(m_dataObj.d_nowDrag);

		m_dataObj.d_mp =
		{
			x: m_dataObj.d_nowDrag.mouseX,
			y: m_dataObj.d_nowDrag.mouseY
		};

		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;
		m_dataObj.d_dragBitmap.visible = true;
	};

	// :: 1 프래임 드래그 초기화
	var p_frame_1_drags_init:Function = function():void
	{
		// 드래그 할때 보여지는 모양
		this.m_dataObj.d_dragBitmap = null;
		// 드래그 다운 mx, my
		this.m_dataObj.d_mp = null;
		// 드래그 할때 현재 드래그 하는 타겟
		this.m_dataObj.d_nowDrag = null;
		// 드래그 애니메이션 필요
		this.m_dataObj.d_smX = new S_Move();
		this.m_dataObj.d_smY = new S_Move();
		this.m_dataObj.d_sm_sn_in = 0.8;
		this.m_dataObj.d_sm_sn_back = 0.8;


		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// Drag
		t_la = this.m_dataObj.dragValues.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['drag_' + i];

			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.tf.text = this.m_dataObj.dragValues[i];
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, this.p_frame_1_drag_mouseDown);
		}


		// DragTarget
		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['dragTarget_' + i];
			t_mc.tf.text = '';
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc = m_bogisCont['dragTarget_' + t_index];		;
		t_mc.d_isSound = true;

		p_trace('t_index: ' + t_index);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// DragTarget
		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];
			t_mc.tf.text = '';
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.selectCount = 0;
		m_dataObj.pd = null;
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);
			}
		}


		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답확인
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시풀기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	}

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this.target_0;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 정답 배열 (무조건 배열에 스트링)
			dragValues: ['A', 'B', 'C', 'D'],

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['A', 'B', 'C']
		};

		// 답을 선택해야할 도달치
		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		// 답을 선택하는 카운트
		this.m_dataObj.selectCount = 0;
		// 학생이 푼답을 담을 변수 (배열)
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_drags_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	초기화
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
		if (this == this.root)
			this.addEventListener(Event.ENTER_FRAME,
				function(event:Event):void
				{
					MovieClip(event.currentTarget).removeEventListener(Event.ENTER_FRAME, arguments.callee);
					owner.gotoAndStop(2);
				}
			);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	// - 문제의 보기들을 가지고 있는 무비클립
	var m_bogisCont:MovieClip = null;
	// - 문제 타겟이 되는 무비클립
	var m_target:MovieClip = null;
	// - 모든 상태정보를 가지고 있는 오브젝트
	var m_dataObj:Object = null;


	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}

//this.gotoAndStop(2);


















this.stop();

/**
# 본 스크립트는 한번만 실행 됩니다.

@초기작성자: Hobis Jung
@작성일자: 110121
*/

if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import hb.effects.S_Move;
	import utils.ComHandler;
	import utils.MC_Util;
	import utils.SimpleSound;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	1 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 드래그 사용 비트맵 리셋
	var p_frame_1_dragBitmap_reset:Function = function():void
	{
		this.m_dataObj.d_dragBitmap.x = 0;
		this.m_dataObj.d_dragBitmap.y = 0;
		this.m_dataObj.d_dragBitmap.visible = false;
		this.m_dataObj.d_drag_bd.fillRect(this.m_dataObj.d_drag_bd.rect, 0x00000000);
	};

	// :: 1 프래임 드래그 마우스 업
	var p_frame_1_drag_mouseUp:Function = function(event:MouseEvent):void
	{
		m_target.stage.removeEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		var t_mc:MovieClip = null;
		var t_len:int = m_dataObj.answers.length;
		var t_mx:Number = m_bogisCont.mouseX;
		var t_my:Number = m_bogisCont.mouseY;
		var t_ia:int, t_ib:int;
		var t_afterBool:Boolean = false;

		for (var i:int = 0; i < t_len; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];

			if
			(
				(
					(t_mx >= t_mc.x) &&
					(t_mx <= (t_mc.x + t_mc.width))
				) &&
				(
					(t_my >= t_mc.y) &&
					(t_my <= (t_mc.y + t_mc.height))
				) &&

				(t_mc.d_isSound)
			)
			{
				t_ia = p_getLastIndex(t_mc.name);
				t_ib = p_getLastIndex(m_dataObj.d_nowDrag.name);

				if (m_dataObj.pd == null)
					m_dataObj.pd = new Array(m_dataObj.answers.length);
				m_dataObj.pd[t_ia] = m_dataObj.dragValues[t_ib];

				t_mc.tf.text = m_dataObj.pd[t_ia];

				if (!t_mc.d_isDragIn)
				{
					p_frame_1_answerCountCheck();
					t_mc.d_isDragIn = true;
				}

				t_afterBool = true;

				break;
			}
		}

		if (t_afterBool)
		{
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				t_mc.x, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				t_mc.y, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};

			m_bogisCont.soundClip_mc.gotoAndPlay('#_0');

			t_afterBool = false;
		}
		else
		{
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				m_dataObj.d_nowDrag.x, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				m_dataObj.d_nowDrag.y, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};

			m_bogisCont.soundClip_mc.gotoAndPlay('#_1');
		}


		p_trace('현재 푼답: ' + m_dataObj.pd);
	}

	// :: 1 프래임 드래그 마우스 무브
	var p_frame_1_drag_mouseMove:Function = function(event:MouseEvent):void
	{
		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;

		event.updateAfterEvent();
	};

	// :: 1 프래임 드래그 마우스 다운
	var p_frame_1_drag_mouseDown:Function = function(event:MouseEvent):void
	{
		m_target.stage.addEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		m_dataObj.d_nowDrag = MovieClip(event.currentTarget);

		if (m_dataObj.d_dragBitmap == null)
		{
			m_dataObj.d_drag_bd = new BitmapData(
					m_dataObj.d_nowDrag.width,
					m_dataObj.d_nowDrag.height, true, 0x00000000);
			m_dataObj.d_dragBitmap = new Bitmap(m_dataObj.d_drag_bd);
			m_dataObj.d_dragBitmap.alpha = 0.6;
			m_dataObj.d_dragBitmap.visible = false;
			m_bogisCont.addChild(m_dataObj.d_dragBitmap);
		}

		m_dataObj.d_drag_bd.draw(m_dataObj.d_nowDrag);

		m_dataObj.d_mp =
		{
			x: m_dataObj.d_nowDrag.mouseX,
			y: m_dataObj.d_nowDrag.mouseY
		};

		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;
		m_dataObj.d_dragBitmap.visible = true;
	};

	// :: 1 프래임 드래그 초기화
	var p_frame_1_drags_init:Function = function():void
	{
		// 드래그 할때 보여지는 모양
		this.m_dataObj.d_dragBitmap = null;
		// 드래그 다운 mx, my
		this.m_dataObj.d_mp = null;
		// 드래그 할때 현재 드래그 하는 타겟
		this.m_dataObj.d_nowDrag = null;
		// 드래그 애니메이션 필요
		this.m_dataObj.d_smX = new S_Move();
		this.m_dataObj.d_smY = new S_Move();
		this.m_dataObj.d_sm_sn_in = 0.8;
		this.m_dataObj.d_sm_sn_back = 0.8;


		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// Drag
		t_la = this.m_dataObj.dragValues.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['drag_' + i];

			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.tf.text = this.m_dataObj.dragValues[i];
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, this.p_frame_1_drag_mouseDown);
		}


		// DragTarget
		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['dragTarget_' + i];
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;
			t_mc.d_textColor = t_mc.tf.textColor;
			t_mc.tf.text = '';
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc = m_bogisCont['dragTarget_' + t_index];		;
		t_mc.d_isSound = true;

		p_trace('t_index: ' + t_index);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// DragTarget
		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;
			t_mc.tf.textColor = t_mc.d_textColor;
			t_mc.tf.text = '';

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.selectCount = 0;
		m_dataObj.pd = null;
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				t_mc = m_bogisCont['dragTarget_' + i];
				t_mc.tf.textColor = 0xff0000;
				t_mc.tf.text = m_dataObj.answers[i];
			}
		}


		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답확인
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시풀기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	}

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this.target_0;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 정답 배열 (무조건 배열에 스트링)
			dragValues: ['A', 'B', 'C', 'D'],

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['A', 'B', 'C']
		};

		// 답을 선택해야할 도달치
		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		// 답을 선택하는 카운트
		this.m_dataObj.selectCount = 0;
		// 학생이 푼답을 담을 변수 (배열)
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_drags_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	초기화
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
		if (this == this.root)
			this.addEventListener(Event.ENTER_FRAME,
				function(event:Event):void
				{
					MovieClip(event.currentTarget).removeEventListener(Event.ENTER_FRAME, arguments.callee);
					owner.gotoAndStop(2);
				}
			);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	// - 문제의 보기들을 가지고 있는 무비클립
	var m_bogisCont:MovieClip = null;
	// - 문제 타겟이 되는 무비클립
	var m_target:MovieClip = null;
	// - 모든 상태정보를 가지고 있는 오브젝트
	var m_dataObj:Object = null;


	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}

//this.gotoAndStop(2);







this.stop();

/**
# 본 스크립트는 한번만 실행 됩니다.

@초기작성자: Hobis Jung
@작성일자: 110121
*/
if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import utils.ComHandler;
	import utils.MC_Util;
	import utils.SimpleSound;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}

	// :: 라인 그리기
	var p_drawLine:Function = function(canvas:MovieClip,
		fromX:Number, fromY:Number,
		toX:Number, toY:Number,
		color:uint = 0x5F9E45):void
	{
		canvas.graphics.clear();
		canvas.graphics.lineStyle(4, color, 1);
		canvas.graphics.moveTo(fromX, fromY);
		canvas.graphics.lineTo(toX, toY);
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	2 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_frame_2_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.tf.text = '';
		}

		m_dataObj.pd = null;
		m_dataObj.selectCount = 0;
	};

	// :: 2 프래임 정답선택 카운트 확인
	var p_frame_2_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				p_frame_1_popUpOpen();
			}
		}
	};

	// :: 2 프래임 텍스트 입력 체인지 이벤트 (텍스트를 먼저 입력해야 선긋기가 가능)
	var p_frame_2_input_change:Function = function(event:Event):void
	{
		var t_tf:TextField = TextField(event.currentTarget);
		var t_mc:MovieClip = MovieClip(t_tf.parent);

		if (t_tf.text.length > 0)
		{
			var t_index:int = p_getLastIndex(t_mc.name);

			if (m_dataObj.pd == null)
				m_dataObj.pd = new Array(m_dataObj.answers.length);

			m_dataObj.pd[t_index] = t_tf.text;

			if (!t_mc.d_isInput)
			{
				p_frame_2_answerCountCheck();

				t_mc.d_isInput = true;
			}
		}

		//p_trace('텍스트 입력 여부(t_mc.d_isInput): ' + t_mc.d_isInput);
		p_trace('텍스트된 텍스트: ' + m_dataObj.pd);
	};

	// :: 2 프래임 텍스트 입력 필드 초기화
	var p_frame_2_input_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.tf.text = '';
			//t_mc.tf.addEventListener(Event.CHANGE, this.p_frame_2_input_change);
			t_mc.tf.addEventListener(FocusEvent.FOCUS_OUT, this.p_frame_2_input_change);
		}
	};

	// :: 2 프래임 초기화
	var p_frame_2_init:Function = function():void
	{
		this.m_target = this.target_1;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 정답 배열 (무조건 배열에 스트링)
			answers: [
				'How\'s it going?',
				'I\'m glad to meet you',
				'See you later']
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		this.p_frame_2_input_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	1 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		var t_canvas:MovieClip = null;
		var t_drag:MovieClip = null;
		var t_dragTarget:MovieClip = null;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['inputView_' + i];
			t_mc.gotoAndStop(2);

			t_canvas = m_dataObj.d_lcs2[i];
			t_drag = m_bogisCont['drag_' + i];
			t_dragTarget = m_bogisCont['dragTarget_' + (int(m_dataObj.answers[i].no) - 1)];
			p_drawLine(t_canvas,
				t_drag.x, t_drag.y,
				t_dragTarget.x, t_dragTarget.y,
				0xff0000);
		}

		MC_Util.setVisible(m_target.confirm_mc, false);
		MC_Util.setVisible(m_target.restart_mc, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{

		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['sound_' + i];
			t_mc.d_isPlay = false;
		}

		t_la = m_dataObj.answers.length;

		// input, inputView, drag, dragTarget의 개수는 일치해야 한다.
		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.mouseChildren = false;
			t_mc.tf.text = '';

			t_mc = m_bogisCont['inputView_' + i];
			t_mc.gotoAndStop(1);

			t_mc = m_bogisCont['drag_' + i];
			t_mc.d_isDrag = false;

			t_mc = m_dataObj.d_lcs[i];
			t_mc.graphics.clear();
			t_mc = m_dataObj.d_lcs2[i];
			t_mc.graphics.clear();
		}

		MC_Util.setVisible(m_target.confirm_mc, false);
		MC_Util.setVisible(m_target.restart_mc, false);

		m_dataObj.pd = null;
		m_dataObj.selectCount = 0;
	};

	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setVisible(m_target.confirm_mc, true);
			}
		}

		this.p_trace('this.m_dataObj.selectCount: ' + this.m_dataObj.selectCount);
	};

	// :: 1 프래임 드래그 채크
	var p_frame_1_dragMouseUp_check:Function = function():void
	{
		var t_index:int = this.p_getLastIndex(this.m_dataObj.d_nowDrag.name);
		var t_canvas:MovieClip = this.m_dataObj.d_lcs[t_index];

		var t_mx:Number = this.m_target.bogisCont_mc.mouseX;
		var t_my:Number = this.m_target.bogisCont_mc.mouseY;

		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		var t_nowDrag:MovieClip = this.m_dataObj.d_nowDrag;
		var t_after:Boolean = false;

		var t_pd:Object = null;

		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['dragTarget_' + i];

			if
			(
				(
					(t_mx >= (t_mc.x - Math.round(t_mc.width / 2))) &&
					(t_mx <= (t_mc.x + Math.round(t_mc.width / 2)))
				) &&
				(
					(t_my >= (t_mc.y - Math.round(t_mc.height / 2))) &&
					(t_my <= (t_mc.y + Math.round(t_mc.height / 2)))
				)
			)
			{
				this.p_drawLine(t_canvas,
					t_nowDrag.x, t_nowDrag.y,
					t_mc.x, t_mc.y,
					0x0099CC);

				t_nowDrag.gotoAndPlay('#_0');

				// 답 저장
				if (this.m_dataObj.pd != null)
				{
					t_pd = this.m_dataObj.pd[t_index];
					t_pd.no = String(this.p_getLastIndex(t_mc.name) + 1);
					this.p_trace('현재 답 확인: ' + this.m_dataObj.pd[t_index].no);
				}

				// 여러번 답을 선택해도 한번만 실행
				if (!t_nowDrag.d_isDrag)
				{
					this.p_frame_1_answerCountCheck();

					t_nowDrag.d_isDrag = true;
				}

				t_after = true;

				break;
			}
		}

		if (!t_after)
			t_nowDrag.gotoAndPlay('#_1');


		//this.p_trace('t_mx: ' + t_mx);
		//this.p_trace('t_my: ' + t_my);
	};

	// :: 1 프래임 드래그 마우스 업
	var p_frame_1_mouseUp:Function = function(event:MouseEvent):void
	{
		m_target.stage.removeEventListener(MouseEvent.MOUSE_UP, p_frame_1_mouseUp);
		m_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		var t_index:int = p_getLastIndex(m_dataObj.d_nowDrag.name);
		var t_canvas:MovieClip = m_dataObj.d_lcs[t_index];
		t_canvas.graphics.clear();

		p_frame_1_dragMouseUp_check();

		m_dataObj.d_nowDrag = null;
	};

	// :: 1 프래임 드래그 마우스 무브
	var p_frame_1_drag_mouseMove:Function = function(event:MouseEvent):void
	{
		var t_index:int = p_getLastIndex(m_dataObj.d_nowDrag.name);
		var t_canvas:MovieClip = m_dataObj.d_lcs[t_index];

		var t_x:Number = m_target.bogisCont_mc.mouseX;
		var t_y:Number = m_target.bogisCont_mc.mouseY;

		p_drawLine(t_canvas,
			m_dataObj.d_nowDrag.x, m_dataObj.d_nowDrag.y,
			t_x, t_y);

		event.updateAfterEvent();
	};

	// :: 1 프래임 드래그 마우스 다운
	var p_frame_1_drag_mouseDown:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_input:MovieClip = m_bogisCont['input_' + p_getLastIndex(t_mc.name)];

		if (t_input.d_isInput)
		{
			m_target.stage.addEventListener(MouseEvent.MOUSE_UP, p_frame_1_mouseUp);
			m_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

			m_dataObj.d_nowDrag = t_mc;
		}
	};

	// :: 1 프래임 드래그 초기화
	var p_frame_1_drag_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['drag_' + i];
			t_mc.d_isDrag = false;
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, this.p_frame_1_drag_mouseDown);

			// 선그리기 캔버스 MovieClip
			t_mc = new MovieClip();
			this.m_dataObj.d_lcsCont.addChild(t_mc);
			this.m_dataObj.d_lcs.push(t_mc);

			// 선그리기 캔버스 MovieClip 정답표시
			t_mc = new MovieClip();
			this.m_dataObj.d_lcsCont.addChild(t_mc);
			this.m_dataObj.d_lcs2.push(t_mc);

			try
			{
				// 정답확인선이 제일 위에 보이게 조정
				this.m_dataObj.d_lcsCont.setChildIndex(this.m_dataObj.d_lcs2,
					this.m_dataObj.d_lcsCont.numChildren - 1);
			}
			catch (e:Error)
			{
			}

		}
	};

	// :: 1 프래임 텍스트 입력 체인지 이벤트 (텍스트를 먼저 입력해야 선긋기가 가능)
	var p_frame_1_input_change:Function = function(event:Event):void
	{
		var t_tf:TextField = TextField(event.currentTarget);
		var t_mc:MovieClip = MovieClip(t_tf.parent);

		if (t_tf.text.length > 0)
		{
			var t_index:int = p_getLastIndex(t_mc.name);

			var t_pd:Object =
			{
				text: t_tf.text
			};

			if (m_dataObj.pd == null)
				m_dataObj.pd = new Array(m_dataObj.answers.length);

			m_dataObj.pd[t_index] = t_pd;

			if (!t_mc.d_isInput)
			{
				t_mc.d_isInput = true;
			}
		}

		//p_trace('텍스트 입력 여부(t_mc.d_isInput): ' + t_mc.d_isInput);
	};

	// :: 1 프래임 텍스트 입력 필드 초기화
	var p_frame_1_input_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.mouseChildren = false;
			t_mc.tf.text = '';
			t_mc.tf.addEventListener(Event.CHANGE, this.p_frame_1_input_change);
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);
		var t_input:MovieClip = null;

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc.d_isPlay = true;

		t_input = m_bogisCont['input_' + t_index];
		t_input.mouseChildren = true;

		p_trace(t_index + ' 번 사운드 들음 여부: ' + t_mc.d_isPlay);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.d_isPlay = false;
			t_mc.buttonMode = true;
			t_mc.mouseChildren = true;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답보기
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시하기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setVisible(m_target.confirm_mc, false);
		MC_Util.setVisible(m_target.restart_mc, false);
	};

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this.target_0;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 정답 배열 (무조건 배열에 스트링)
			answers:
			[
				{text: 'class', no: '1'},
				{text: 'friend', no: '3'},
				{text: 'student', no: '2'},
			]
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		this.m_dataObj.d_lcsCont = new MovieClip();
		this.m_dataObj.d_lcsCont.mouseChildren = false;
		this.m_dataObj.d_lcsCont.mouseEnabled = false;
		this.m_target.bogisCont_mc.addChild(this.m_dataObj.d_lcsCont);
		this.m_dataObj.d_lcs = [];
		this.m_dataObj.d_lcs2 = [];

		// 드래그 할대 드래깅 되는 타겟
		this.m_dataObj.d_nowDrag = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_input_init();
		this.p_frame_1_drag_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	초기화
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 팝업 열기
	var p_frame_1_popUpOpen:Function = function(frame:int = 1):void
	{
		owner.popUp_mc.gotoAndStop(frame);
		owner.popUp_mc.visible = true;
	};

	// :: 팝업 닫기
	var p_frame_1_popUpClose:Function = function():void
	{
		owner.popUp_mc.visible = false;
	};

	// :: 팝업 초기화
	var p_popUp_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// - 팝업 닫기 버튼
		t_mc = this.popUp_mc.close_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK,
			function(event:MouseEvent):void
			{
				p_frame_2_reset_click(null);
				owner.popUp_mc.visible = false;
			}
		);

		this.popUp_mc.visible = false;
	};

	// :: 하단 페이지 컨트롤러 업데이트
	var p_pageController_update:Function = function(frame:int = 0):void
	{
		var t_info:String = null;

		if (frame > 0)
			t_info = String(frame) + ' / ' + String(owner.totalFrames - 1);
		else
			t_info = String(owner.currentFrame - 1) + ' / ' + String(owner.totalFrames - 1);

		pageCont_mc.nowPage_tf.text = t_info;
	};

	// :: 하단 페이지 컨트롤러 버튼 클릭 핸들러 (prev)
	var p_pageControllerPrev_click:Function = function(event:MouseEvent):void
	{
		if (owner.currentFrame > 2)
		{
			owner.prevFrame();
			p_pageController_update();
		}
	};

	// :: 하단 페이지 컨트롤러 버튼 클릭 핸들러 (next)
	var p_pageControllerNext_click:Function = function(event:MouseEvent):void
	{
		if (owner.currentFrame < owner.totalFrames)
		{
			owner.nextFrame();
			p_pageController_update();
		}
	};

	// :: 하단 페이지 컨트롤러 초기화
	var p_pageController_init:Function = function():void
	{
		this.pageCont_mc.prev_bt.buttonMode = true;
		this.pageCont_mc.prev_bt.mouseChildren = false;
		this.pageCont_mc.prev_bt.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		this.pageCont_mc.prev_bt.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		this.pageCont_mc.prev_bt.addEventListener(MouseEvent.CLICK, this.p_pageControllerPrev_click);

		this.pageCont_mc.next_bt.buttonMode = true;
		this.pageCont_mc.next_bt.mouseChildren = false;
		this.pageCont_mc.next_bt.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		this.pageCont_mc.next_bt.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		this.pageCont_mc.next_bt.addEventListener(MouseEvent.CLICK, this.p_pageControllerNext_click);

		this.p_pageController_update(1);
	};

	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
		this.p_popUp_init();
		this.p_pageController_init();

		if (this == this.root)
			this.addEventListener(Event.ENTER_FRAME,
				function(event:Event):void
				{
					MovieClip(event.currentTarget).removeEventListener(Event.ENTER_FRAME, arguments.callee);
					owner.gotoAndStop(2);
				}
			);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	// - 문제의 보기들을 가지고 있는 무비클립
	var m_bogisCont:MovieClip = null;
	// - 문제 타겟이 되는 무비클립
	var m_target:MovieClip = null;
	// - 모든 상태정보를 가지고 있는 오브젝트
	var m_dataObj:Object = null;


	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}




if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import utils.SimpleSound;
	import utils.MC_Util;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 1 Frame Action
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_frame_1_confirm:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				t_mc = m_bogisCont['bogi_' + i]
				t_mc = t_mc['check_' + (int(m_dataObj.answers[i]) - 1)];
				t_mc.gotoAndStop(3);

				//t_mc = m_bogisCont['bogi_' + i]
				//t_mc = t_mc['checkItem_' + (int(m_dataObj.answers[i]) - 1)];
				//t_mc.gotoAndStop(2);
			}
		}
	};

	var p_frame_1_reset:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_sub:MovieClip = null;
		var t_la:int, i:int;
		var t_lb:int, j:int;

		for (i = 0, t_la = m_dataObj.boigsLen; i < t_la; i ++)
		{
			t_mc = m_bogisCont['bogi_' + i];
			t_mc.mouseChildren = false;
			t_mc.d_nowCheck = null;

			for (j = 0, t_lb = m_dataObj.checksLen; j < t_lb; j ++)
			{
				t_sub = t_mc['check_' + j];
				t_sub.gotoAndStop(1);

				t_sub = t_mc['checkItem_' + j];
				t_sub.gotoAndStop(1);
			}

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.pd = null;
		m_dataObj.selectCount = 0;
	};

	var p_frame_1_check_click:Function = function(event:MouseEvent):void
	{
		var t_check:MovieClip = MovieClip(event.currentTarget);
		var t_ci:int = t_check.name.lastIndexOf('_') + 1;
		t_ci = int(t_check.name.substr(t_ci));

		var t_bogi:MovieClip = MovieClip(t_check.parent);
		var t_bi:int = t_bogi.name.lastIndexOf('_') + 1;
		t_bi = int(t_bogi.name.substr(t_bi));

		if (t_bogi.d_nowCheck != null)
			t_bogi.d_nowCheck.gotoAndStop(1);
		t_bogi.d_nowCheck = t_check;
		t_bogi.d_nowCheck.gotoAndStop(2);

		if (m_dataObj.pd == null)
			m_dataObj.pd = [];
		m_dataObj.pd[t_bi] = String(t_ci + 1);

		m_dataObj.selectCount ++;
		if (m_dataObj.selectCount >= m_dataObj.selectLen)
		{
			MC_Util.setEnable(m_target.confirm_mc, true, true);
			MC_Util.setEnable(m_target.restart_mc, true, true);
		}
	};

	var p_frame_1_init:Function = function():void
	{
		// {{{ -- 사용되는 버튼 설정
		this.m_target = this;
		this.m_bogisCont = this.m_target.bogisCont_mc;
		this.m_dataObj =
		{
			// - 선택형 보기수
			boigsLen: 4,
			// - 선택형 보기에 선택수
			checksLen: 2,
			// - 정답 배열 (반드시 스트링)
			answers: ['1', '2', '3', '4']
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		var t_mc:MovieClip = null;
		var t_sub:MovieClip = null;
		var t_la:int, i:int;
		var t_lb:int, j:int;
		// }}} -- 사용되는 버튼 설정


		// {{{ -- 보기그림 버튼 설정
		for (i = 0, t_la = this.m_dataObj.boigsLen; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['bogi_' + i];
			t_mc.d_nowCheck = null;

			for (j = 0, t_lb = this.m_dataObj.checksLen; j < t_lb; j ++)
			{
				t_sub = t_mc['check_' + j];
				t_sub.buttonMode = true;
				t_sub.mouseChildren = false;
				t_sub.addEventListener(MouseEvent.CLICK, this.p_frame_1_check_click);
			}
		}
		// }}} -- 보기그림 버튼 설정


		// 정답보기
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm);

		// 다시하기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	var m_bogisCont:MovieClip = null;
	var m_target:MovieClip = null;
	var m_dataObj:Object = null;

	var isInit:Boolean = true;
	var onwer:MovieClip = this;
}


this.p_frame_1_init();




if (!this.isInit)
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import utils.ComHandler;
	import utils.MC_Util;


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 1 Frame Action
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 인풋들 채인지 이벤트
	var p_input_change:Function = function(event:Event):void
	{
		var t_tf:TextField = TextField(event.currentTarget);

		if (t_tf.text.length > 0)
		{
			var t_mc:MovieClip = MovieClip(t_tf.parent);
			var t_index:int = t_mc.name.lastIndexOf('_') + 1;
			t_index = int(t_mc.name.substr(t_index));

			var t_str:String = t_tf.text;
			t_str = t_str.split('  ').join(' ');

			if (m_dataObj.pd == null)
				m_dataObj.pd = [];
			m_dataObj.pd[t_index] = t_str;

			if (!t_mc.d_isInput)
			{
				p_frame_1_answerCountCheck();

				t_mc.d_isInput = true;
			}
		}

		p_trace('현재 푼답: ' + m_dataObj.pd);
		p_trace('현재 정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 아이템들 초기화
	var p_frame_1_items_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.d_textColor = t_mc.tf.textColor;
			t_mc.tf.text = '';

			t_mc.tf.addEventListener(Event.CHANGE, this.p_input_change);

			// 첫번째 활성화
			if (i == 0)
				this.m_target.stage.focus = t_mc.tf;
		}
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		var t_inputView:MovieClip = null;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				// 틀렸으니까 틀린답 표시
				t_inputView = m_bogisCont['input_' + i];
				t_inputView.tf.textColor = 0xff0000;
				t_inputView.tf.text = m_dataObj.answers[i];
			}
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['input_' + i];
			t_mc.d_isInput = false;
			t_mc.tf.textColor = t_mc.d_textColor;
			t_mc.tf.text = '';

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.selectCount = 0;
		m_dataObj.pd = null;
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답보기
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시하기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	};

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 정답 배열 (무조건 배열에 스트링)
			answers:
			[
				'It\'s very delicious.',
				'Do you want some more?',
				'it\'s very sweer.',
				'It\'s too hot.'
			]
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_items_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 초기화 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// - 문제의 전체 타겟 무비클립
	var m_target:MovieClip = null;
	// - 문제의 전체 보기관련 컨테이너
	var m_bogisCont:MovieClip = null;
	// - 문제의 각종 정보를 가지는 오브젝트
	var m_dataObj:Object = null;

	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}


this.p_frame_1_init();















this.stop();
/**
	@Name: 문제 모듈
	@초기작성자: Hobis Jung
	@작성일자: 110125
*/

if (!this.isInit)
{
	import utils.ComHandler;
	import utils.SimpleSound;
	import utils.MC_Util;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}

	var p_getTSSText:Function = function(target:MovieClip, endMinus:int = 2):String
	{
		var t_rv:int = null;

		var t_tss:TextSnapshot = target.textSnapshot;
		t_rv = t_tss.getText(0, t_tss.charCount - endMinus);

		return t_rv;
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 1 Frame Action
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 보기들 체크버튼 클릭
	var p_frame_1_check_click:Function = function(event:MouseEvent):void
	{
		var t_check:MovieClip = MovieClip(event.currentTarget);
		var t_bogi:MovieClip = MovieClip(t_check.parent);
		var t_ci:int = p_getLastIndex(t_check.name);
		var t_bi:int = p_getLastIndex(t_bogi.name);
		var t_inputView:MovieClip = m_bogisCont['inputView_' + t_bi];

		t_inputView.tf.text = t_check.d_str;

		if (m_dataObj.pd == null)
			m_dataObj.pd = new Array(m_dataObj.answers.length);
		m_dataObj.pd[t_bi] = t_check.d_str;


		if (!t_bogi.d_isCheck)
		{
			p_frame_1_answerCountCheck();
			t_bogi.d_isCheck = true;
		}

		p_trace('현재 푼답: ' + m_dataObj.pd);
		p_trace('현재 정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 보기들 초기화
	var p_frame_1_items_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_mc2:MovieClip = null;
		var t_la:int, i:int;
		var t_lb:int, j:int;


		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['bogi_' + i];
			t_mc.d_isCheck = false;
			t_mc.mouseChildren = false;


			t_lb = this.m_dataObj.checksLen;

			for (j = 0; j < t_lb; j ++)
			{
				t_mc2 = t_mc['check_' + j];
				t_mc2.d_str = m_dataObj.checkValues[j];
				t_mc2.buttonMode = true;
				t_mc2.mouseChildren = false;
				t_mc2.addEventListener(MouseEvent.CLICK, this.p_frame_1_check_click);
			}

			t_mc = this.m_bogisCont['inputView_' + i];
			t_mc.d_textColor = t_mc.tf.textColor;
			t_mc.tf.text = '';
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc.d_isSound = true;

		t_mc = m_bogisCont['bogi_' + t_index];
		t_mc.mouseChildren = true;

		p_trace('t_mc.mouseChildren: ' + t_mc.mouseChildren);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		var t_inputView:MovieClip = null;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				// 틀렸으니까 틀린답 표시
				t_inputView = m_bogisCont['inputView_' + i];
				t_inputView.tf.textColor = 0xff0000;
				t_inputView.tf.text = m_dataObj.answers[i];
			}
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['bogi_' + i];
			t_mc.d_isCheck = false;
			t_mc.mouseChildren = false;

			t_mc = m_bogisCont['inputView_' + i];
			t_mc.tf.textColor = t_mc.d_textColor;
			t_mc.tf.text = '';

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.pd = null;
		m_dataObj.selectCount = 0;
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답보기
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시하기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	};

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 선택형 보기의 개수
			//bogisLen: 2,

			// - 선택형 보기의 선택개수
			checkValues: ['a', 'b', 'c'],

			// - 선택형 보기의 선택개수
			checksLen: 3,

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['a', 'b']
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_items_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 초기화 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
	};

	// :: 초기화 함수 (초기에 한번만 호출)
	var reset:Function = function():void
	{
		this.p_frame_1_reset_click(null);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// - 문제의 전체 타겟 무비클립
	var m_target:MovieClip = null;
	// - 문제의 전체 보기관련 컨테이너
	var m_bogisCont:MovieClip = null;
	// - 문제의 각종 정보를 가지는 오브젝트
	var m_dataObj:Object = null;

	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}

this.p_frame_1_init();
















this.stop();
/**
	@Name: 문제 모듈
	@초기작성자: Hobis Jung
	@작성일자: 110125
*/

if (!this.isInit)
{
	import utils.ComHandler;
	import utils.SimpleSound;
	import utils.MC_Util;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}

	var p_getTSSText:Function = function(target:MovieClip, endMinus:int = 2):String
	{
		var t_rv:int = null;

		var t_tss:TextSnapshot = target.textSnapshot;
		t_rv = t_tss.getText(0, t_tss.charCount - endMinus);

		return t_rv;
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 1 Frame Action
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 보기들 체크버튼 클릭
	var p_frame_1_check_click:Function = function(event:MouseEvent):void
	{
		var t_check:MovieClip = MovieClip(event.currentTarget);
		var t_bogi:MovieClip = MovieClip(t_check.parent);
		var t_ci:int = p_getLastIndex(t_check.name);
		var t_bi:int = p_getLastIndex(t_bogi.name);

		trace(t_bogi.d_nowCheck);
		if (t_bogi.d_nowCheck != null)
			t_bogi.d_nowCheck.gotoAndStop(1);
		t_check.gotoAndStop(2);
		t_bogi.d_nowCheck = t_check;

		if (m_dataObj.pd == null)
			m_dataObj.pd = new Array(m_dataObj.answers.length);
		m_dataObj.pd[t_bi] = t_check.d_value;


		if (!t_bogi.d_isCheck)
		{
			p_frame_1_answerCountCheck();
			t_bogi.d_isCheck = true;
		}

		p_trace('현재 푼답: ' + m_dataObj.pd);
		p_trace('현재 정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 보기들 초기화
	var p_frame_1_items_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_mc2:MovieClip = null;
		var t_la:int, i:int;
		var t_lb:int, j:int;


		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['bogi_' + i];
			t_mc.d_nowCheck = null;
			t_mc.d_isCheck = false;
			t_mc.mouseChildren = false;

			t_lb = this.m_dataObj.checksLen;

			for (j = 0; j < t_lb; j ++)
			{
				t_mc2 = t_mc['check_' + j];
				t_mc2.d_value = this.m_dataObj.checkValues[j];
				t_mc2.buttonMode = true;
				t_mc2.mouseChildren = false;
				t_mc2.addEventListener(MouseEvent.CLICK, this.p_frame_1_check_click);
			}
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc.d_isSound = true;

		t_mc = m_bogisCont['bogi_' + t_index];
		t_mc.mouseChildren = true;

		p_trace('t_mc.mouseChildren: ' + t_mc.mouseChildren);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				t_mc = m_bogisCont['bogi_' + i];
				t_mc = t_mc['check_' + (int(m_dataObj.answers[i]) - 1)];
				t_mc.gotoAndStop(3);
			}
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_mc2:MovieClip = null;
		var t_la:int, i:int;
		var t_lb:int, j:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['bogi_' + i];
			t_mc.d_nowCheck = null;
			t_mc.d_isCheck = false;
			t_mc.mouseChildren = false;

			t_lb = m_dataObj.checksLen;

			for (j = 0; j < t_lb; j ++)
			{
				t_mc2 = t_mc['check_' + j];
				t_mc2.gotoAndStop(1);
			}

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.pd = null;
		m_dataObj.selectCount = 0;
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답보기
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시하기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	};

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 선택형 보기의 개수
			//bogisLen: 2,

			// - 선택형 보기의 선택개수
			checkValues: ['1', '2', '3'],

			// - 선택형 보기의 선택개수
			checksLen: 3,

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['1', '2']
		};

		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		this.m_dataObj.selectCount = 0;
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_items_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//// 초기화 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
	};

	// :: 초기화 함수 (초기에 한번만 호출)
	var reset:Function = function():void
	{
		this.p_frame_1_reset_click(null);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// - 문제의 전체 타겟 무비클립
	var m_target:MovieClip = null;
	// - 문제의 전체 보기관련 컨테이너
	var m_bogisCont:MovieClip = null;
	// - 문제의 각종 정보를 가지는 오브젝트
	var m_dataObj:Object = null;

	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}

this.p_frame_1_init();




/**
# 본 스크립트는 한번만 실행 됩니다.

@초기작성자: Hobis Jung
@작성일자: 110121
*/

if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import hb.effects.S_Move;
	import utils.ComHandler;
	import utils.MC_Util;
	import utils.SimpleSound;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	라이브러리 함수들
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	var p_getLastIndex:Function = function(name:String):int
	{
		var t_rv:int = name.lastIndexOf('_') + 1;
		t_rv = int(name.substr(t_rv));
		return t_rv;
	};

	// :: 트레이서
	var p_trace:Function = function(str:String):void
	{
		var isDebug:Boolean = true;
		var fontMsg:String = '# [hb] ';

		if (isDebug)
		{
			trace(fontMsg + str);
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	1 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 1 프래임 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				p_trace('현재 푼답: ' + m_dataObj.pd);
				p_trace('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 1 프래임 드래그 사용 비트맵 리셋
	var p_frame_1_dragBitmap_reset:Function = function():void
	{
		this.m_dataObj.d_dragBitmap.x = 0;
		this.m_dataObj.d_dragBitmap.y = 0;
		this.m_dataObj.d_dragBitmap.visible = false;
		this.m_dataObj.d_drag_bd.fillRect(this.m_dataObj.d_drag_bd.rect, 0x00000000);
	};

	// :: 1 프래임 드래그 마우스 업
	var p_frame_1_drag_mouseUp:Function = function(event:MouseEvent):void
	{
		m_target.stage.removeEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		var t_mc:MovieClip = null;
		var t_len:int = m_dataObj.answers.length;
		var t_mx:Number = m_bogisCont.mouseX;
		var t_my:Number = m_bogisCont.mouseY;
		var t_ia:int, t_ib:int;
		var t_afterBool:Boolean = false;

		for (var i:int = 0; i < t_len; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];

			if
			(
				(
					(t_mx >= t_mc.x) &&
					(t_mx <= (t_mc.x + t_mc.width))
				) &&
				(
					(t_my >= t_mc.y) &&
					(t_my <= (t_mc.y + t_mc.height))
				) &&

				(t_mc.d_isSound)
			)
			{
				t_ia = p_getLastIndex(t_mc.name);
				t_ib = p_getLastIndex(m_dataObj.d_nowDrag.name);

				if (m_dataObj.pd == null)
					m_dataObj.pd = new Array(m_dataObj.answers.length);
				m_dataObj.pd[t_ia] = m_dataObj.dragValues[t_ib];

				t_mc.tf.text = m_dataObj.pd[t_ia];

				if (!t_mc.d_isDragIn)
				{
					p_frame_1_answerCountCheck();
					t_mc.d_isDragIn = true;
				}

				t_afterBool = true;

				break;
			}
		}

		if (t_afterBool)
		{/*
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				t_mc.x, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				t_mc.y, m_dataObj.d_sm_sn_in);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};*/

			p_frame_1_dragBitmap_reset();

			m_bogisCont.soundClip_mc.gotoAndPlay('#_0');

			t_afterBool = false;
		}
		else
		{
			m_dataObj.d_smX.move(m_dataObj.d_dragBitmap, 'x',
				m_dataObj.d_nowDrag.x, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.move(m_dataObj.d_dragBitmap, 'y',
				m_dataObj.d_nowDrag.y, m_dataObj.d_sm_sn_back);
			m_dataObj.d_smY.onMoveEnd = function():void
			{
				this.onMoveEnd = null;
				p_frame_1_dragBitmap_reset();
			};

			m_bogisCont.soundClip_mc.gotoAndPlay('#_1');
		}


		p_trace('현재 푼답: ' + m_dataObj.pd);
	}

	// :: 1 프래임 드래그 마우스 무브
	var p_frame_1_drag_mouseMove:Function = function(event:MouseEvent):void
	{
		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;

		event.updateAfterEvent();
	};

	// :: 1 프래임 드래그 마우스 다운
	var p_frame_1_drag_mouseDown:Function = function(event:MouseEvent):void
	{
		m_target.stage.addEventListener(MouseEvent.MOUSE_UP, p_frame_1_drag_mouseUp);
		m_target.stage.addEventListener(MouseEvent.MOUSE_MOVE, p_frame_1_drag_mouseMove);

		m_dataObj.d_nowDrag = MovieClip(event.currentTarget);

		if (m_dataObj.d_dragBitmap == null)
		{
			m_dataObj.d_drag_bd = new BitmapData(
					m_dataObj.d_nowDrag.width,
					m_dataObj.d_nowDrag.height, true, 0x00000000);
			m_dataObj.d_dragBitmap = new Bitmap(m_dataObj.d_drag_bd);
			m_dataObj.d_dragBitmap.alpha = 0.6;
			m_dataObj.d_dragBitmap.visible = false;
			m_bogisCont.addChild(m_dataObj.d_dragBitmap);
		}

		m_dataObj.d_drag_bd.draw(m_dataObj.d_nowDrag);

		m_dataObj.d_mp =
		{
			x: m_dataObj.d_nowDrag.mouseX,
			y: m_dataObj.d_nowDrag.mouseY
		};

		m_dataObj.d_dragBitmap.x =
			m_bogisCont.mouseX - m_dataObj.d_mp.x;
		m_dataObj.d_dragBitmap.y =
			m_bogisCont.mouseY - m_dataObj.d_mp.y;
		m_dataObj.d_dragBitmap.visible = true;
	};

	// :: 1 프래임 드래그 초기화
	var p_frame_1_drags_init:Function = function():void
	{
		// 드래그 할때 보여지는 모양
		this.m_dataObj.d_dragBitmap = null;
		// 드래그 다운 mx, my
		this.m_dataObj.d_mp = null;
		// 드래그 할때 현재 드래그 하는 타겟
		this.m_dataObj.d_nowDrag = null;
		// 드래그 애니메이션 필요
		this.m_dataObj.d_smX = new S_Move();
		this.m_dataObj.d_smY = new S_Move();
		this.m_dataObj.d_sm_sn_in = 0.8;
		this.m_dataObj.d_sm_sn_back = 0.8;


		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// Drag
		t_la = this.m_dataObj.dragValues.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['drag_' + i];

			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, this.p_frame_1_drag_mouseDown);
		}


		// DragTarget
		t_la = this.m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['dragTarget_' + i];
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;
			t_mc.d_textColor = t_mc.tf.textColor;
			t_mc.tf.text = '';
		}
	};

	// :: 1 프래임 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = p_getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc = m_bogisCont['dragTarget_' + t_index];		;
		t_mc.d_isSound = true;

		p_trace('t_index: ' + t_index);
	};

	// :: 1 프래임 사운드 초기화
	var p_frame_1_sound_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 1 프래임 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;

		// DragTarget
		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['dragTarget_' + i];
			t_mc.d_isSound = false;
			t_mc.d_isDragIn = false;
			t_mc.tf.textColor = t_mc.d_textColor;
			t_mc.tf.text = '';

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.selectCount = 0;
		m_dataObj.pd = null;
	};

	// :: 1 프래임 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.pd[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);

				t_mc = m_bogisCont['dragTarget_' + i];
				t_mc.tf.textColor = 0xff0000;
				t_mc.tf.text = m_dataObj.answers[i];
			}
		}


		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		p_trace('푼답: ' + m_dataObj.pd);
		p_trace('정답: ' + m_dataObj.answers);
	};

	// :: 1 프래임 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답확인
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시풀기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, ComHandler.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	}

	// :: 1 프래임 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this;
		this.m_bogisCont = this.m_target.bogisCont_mc;

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 사운드 URLs
			soundUrls: ['sound/moon_001.mp3', 'sound/moon_001.mp3', 'sound/moon_001.mp3'],

			// - 드래그들의 입력 스트링 배열
			dragValues: ['Kevin', 'Lucy', 'Jane'],

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['Jane', 'Lucy', 'Kevin']
		};

		// 답을 선택해야할 도달치
		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		// 답을 선택하는 카운트
		this.m_dataObj.selectCount = 0;
		// 학생이 푼답을 담을 변수 (배열)
		this.m_dataObj.pd = null;

		this.p_frame_1_buttons_init();
		this.p_frame_1_sound_init();
		this.p_frame_1_drags_init();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	초기화
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	// - 문제의 보기들을 가지고 있는 무비클립
	var m_bogisCont:MovieClip = null;
	// - 문제 타겟이 되는 무비클립
	var m_target:MovieClip = null;
	// - 모든 상태정보를 가지고 있는 오브젝트
	var m_dataObj:Object = null;


	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}

this.p_frame_1_init(2);








	// :: 초기화 호출
	var reset:Function = function():void
	{
		this.p_frame_1_reset_click(null);
	};
















this.stop();

/**
# 본 스크립트는 한번만 실행 됩니다.

@초기작성자: Hobis Jung
@작성일자: 110121
*/

if (!this.isInit)
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import hb.utils.DebugUtil;
	import hb.utils.MC_Util;
	import hb.utils.SimpleSound;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	1 프래임 컨텐츠 실행
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 정답선택 카운트 확인
	var p_frame_1_answerCountCheck:Function = function():void
	{
		if (this.m_dataObj.selectCount < this.m_dataObj.selectLen)
		{
			this.m_dataObj.selectCount ++;
			if (this.m_dataObj.selectCount >= this.m_dataObj.selectLen)
			{
				MC_Util.setEnable(m_target.confirm_mc, true, true);

				DebugUtil.test('현재 푼답: ' + m_dataObj.poonDap);
				DebugUtil.test('현재 정답: ' + m_dataObj.answers);
			}
		}
	};

	// :: 문제에 필요한 아이템들 초기화
	var p_frame_1_items_init:Function = function():void
	{
	};

	// :: 사운드 버튼들 클릭
	var p_frame_1_sound_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = MovieClip(event.currentTarget);
		var t_index:int = MC_Util.getLastIndex(t_mc.name);

		SimpleSound.loadPlay(m_dataObj.soundUrls[t_index]);

		t_mc.d_isPlay = true;

		DebugUtil.test(t_index + ' 번 사운드 들음 여부: ' + t_mc.d_isPlay);
	};

	// :: 사운드 초기화
	var p_frame_1_sounds_init:Function = function():void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = this.m_dataObj.soundUrls.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = this.m_bogisCont['sound_' + i];
			t_mc.d_isPlay = false;
			t_mc.buttonMode = true;
			t_mc.mouseChildren = false;
			t_mc.addEventListener(MouseEvent.ROLL_OVER, MC_Util.moo);
			t_mc.addEventListener(MouseEvent.ROLL_OUT, MC_Util.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_DOWN, MC_Util.moo);
			t_mc.addEventListener(MouseEvent.MOUSE_UP, MC_Util.moo);
			t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_sound_click);
		}
	};

	// :: 하단 리셋 버튼 클릭
	var p_frame_1_reset_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{

			t_mc = m_bogisCont['grade_' + i];
			t_mc.gotoAndStop(1);
		}

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);

		m_dataObj.selectCount = 0;
		m_dataObj.poonDap = null;

		p_frame_1_mainSound_play();
	};

	// :: 하단 정답보기 버튼 클릭
	var p_frame_1_confirm_click:Function = function(event:MouseEvent):void
	{
		var t_mc:MovieClip = null;
		var t_la:int, i:int;


		t_la = m_dataObj.answers.length;

		for (i = 0; i < t_la; i ++)
		{
			t_mc = m_bogisCont['grade_' + i];

			if (m_dataObj.poonDap[i] == m_dataObj.answers[i])
			{
				t_mc.gotoAndStop(2);
			}
			else
			{
				t_mc.gotoAndStop(3);
			}
		}

		m_bogisCont.soundClip_mc.gotoAndPlay('#_3');

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, true, true);

		DebugUtil.test('푼답: ' + m_dataObj.poonDap);
		DebugUtil.test('정답: ' + m_dataObj.answers);
	};

	// :: 하단 버튼 초기화
	var p_frame_1_buttons_init:Function = function():void
	{
		var t_mc:MovieClip = null;

		// 정답확인
		t_mc = this.m_target.confirm_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_confirm_click);

		// 다시풀기
		t_mc = this.m_target.restart_mc;
		t_mc.buttonMode = true;
		t_mc.mouseChildren = false;
		t_mc.addEventListener(MouseEvent.ROLL_OVER, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.ROLL_OUT, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_DOWN, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.MOUSE_UP, MC_Util.moo);
		t_mc.addEventListener(MouseEvent.CLICK, this.p_frame_1_reset_click);

		MC_Util.setEnable(m_target.confirm_mc, false, true);
		MC_Util.setEnable(m_target.restart_mc, false, true);
	}

	// :: 문제 읽어주는 사운드 플레이 완료
	var p_frame_1_mainSound_complete:Function = function():void
	{
		//m_target.mouseChildren = true;
	};

	// :: 문제 읽어주는 사운드
	var p_frame_1_mainSound_play:Function = function():void
	{
		SimpleSound.loadPlay(m_dataObj.mainSoundUrl, this.p_frame_1_mainSound_complete);
		//this.m_target.mouseChildren = false;
	};

	// :: 초기화
	var p_frame_1_init:Function = function():void
	{
		this.m_target = this.target_0;
		this.m_bogisCont = this.m_target.bogisCont_mc;


		var t_baseUrl:String = 'sound/';

		// 여기에 문제 관련 정보 입력 (필요없는 것은 주석처리)
		this.m_dataObj =
		{
			// - 문제 읽어주는 사운드 URL
			mainSoundUrl: t_baseUrl + 'DK_M_1.mp3',

			// - 효과 사운드
			effectSounds:
			[
				 t_baseUrl + 'se_correct_0.mp3',
				 t_baseUrl + 'se_failed_0.mp3',
				 t_baseUrl + 'se_failed_1.mp3',
				 t_baseUrl + 'se_stage_clear.mp3',
				 t_baseUrl + 'se_click_0.mp3'
			],

			// 문제 선택 미스
			SimpleSound.loadPlay(m_dataObj.effectSounds[0]);
			// 문제 선택
			SimpleSound.loadPlay(m_dataObj.effectSounds[4]);
			// 문제 정답확인
			SimpleSound.loadPlay(m_dataObj.effectSounds[3]);

			// - 사운드 URLs
			soundUrls:
			[
				t_baseUrl + 'DK_S_1.mp3',
				t_baseUrl + 'DK_S_2.mp3',
				t_baseUrl + 'DK_S_3.mp3',
				t_baseUrl + 'DK_S_4.mp3'
			],

			// - 정답 배열 (무조건 배열에 스트링)
			answers: ['1', '2', '3', '4']
		};

		// 답을 선택해야할 도달치
		this.m_dataObj.selectLen = this.m_dataObj.answers.length;
		// 답을 선택하는 카운트
		this.m_dataObj.selectCount = 0;
		// 학생이 푼답을 담을 변수 (배열)
		this.m_dataObj.poonDap = null;


		this.p_frame_1_buttons_init();
		//this.p_frame_1_sounds_init();
		//this.p_frame_1_items_init();

		//this.p_frame_1_mainSound_play();
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////	초기화
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// :: 초기화 함수 (초기에 한번만 호출)
	var p_init:Function = function():void
	{
		if (this == this.root)
			this.addEventListener(Event.ENTER_FRAME,
				function(event:Event):void
				{
					MovieClip(event.currentTarget).removeEventListener(Event.ENTER_FRAME, arguments.callee);
					owner.gotoAndStop(2);
				}
			);
	};

	// :: 리셋 외부 호출용
	var reset:Function = function():void
	{
		this.p_frame_1_reset_click();
	};

	// :: 텝 이동
	var moveTab:Function = function(index:int):void
	{
	};

	// :: 이전 텝 이동
	var prevTab:Function = function():void
	{
	};

	// :: 다음 텝 이동
	var nextTab:Function = function():void
	{
	};

	// :: 문제 시작
	var start:Function = function():void
	{
		this.gotoAndStop(2);
	};
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	// - 문제의 보기들을 가지고 있는 무비클립
	var m_bogisCont:MovieClip = null;
	// - 문제 타겟이 되는 무비클립
	var m_target:MovieClip = null;
	// - 모든 상태정보를 가지고 있는 오브젝트
	var m_dataObj:Object = null;


	var isInit:Boolean = true;
	var owner:MovieClip = this;

	this.p_init();
}
