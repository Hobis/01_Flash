package net.siriz.utils
{
	import flash.events.StatusEvent;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	
	/**
	 * AS2のクラスを利用して、ブラウザー上のフラッシュ範囲でマウスホイルを操作すると、スクロール範囲をフラッシュのみに制限するクラス。
	 * AVM2ではAVM1のメソッドにアクセスできないため、LocalConnectionを利用して参照する。
	 * 
	 * Copyright (c) 2011 - 2011 SIRIZ (blog.siriz.net)
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 9
	 * @productversion Flash CS3
	 * 
	 * @inheritDoc
	 * 
	 * GNU-GPL version 3 licenses.
	 * 
	 * This program is free software: you can redistribute it and/or modify
	 * it under the terms of the GNU General Public License as published by
	 * the Free Software Foundation, either version 3 of the License, or
	 * (at your option) any later version.
	 *
	 * This program is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	 * GNU General Public License for more details.
	 *
	 * You should have received a copy of the GNU General Public License
	 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
	 *
	 * As additional permission under GNU GPL version 3 section 7, you
	 * may distribute non-source (e.g., minimized or compacted) forms of
	 * that code without the copy of the GNU GPL normally required by
	 * section 4, provided you include this license notice and a URL
	 * through which recipients can access the Corresponding Source.
	 * 
	 */
	
	public class WheelMouse
	{
		public static const VERSION:String = '1.0';
		
		/**
		 * AVM1と通信するためのLocalConnection
		 * @default null
		 */
		public var AVM_lc:LocalConnection;
		
		
		/**
		 * AVM1用のマウスホイルaddListenerを呼び込むメソッド
		 * リソース管理のため、Singletonパターンを利用、直接にアクセスが許可しない。
		 * @param	$class
		 */
		public function WheelMouse( $class:Class ):void 
		{
			if ( $class !== Singleton ) throw Error( "staticを利用してください。" );
			
			// as2のWheel関数をByteArrayに変換してもう一度分かりやすく１６進数に変換したもの。
			var wheelByteArray:String = "C3D7D388F6868080F81C25144DEF53B098465FF6AB6BC0E8FC9C3683C8D1478914BAE99456C6DDD95734E2522A22B241F17292F78DA4F1E43BEBA7A1F16544F192C2C87C2743C97A352D9BE3C4CA143CFE1E1F1D67F5B2025CA1405AEF000D8C580F9F814057274BB900AAF3FBD657EEA923408F39A51F368BFDA1A28B2161F0D89C9AC54A0E11DE29D410D6C22512AA95AABF8D859E29A15FAC541404E0936EB0AF929E8D1578999F510158AE944658D190CD31A1AFE2179E1122C383B44291520B9A0AB9D2E4B59841023283CA7DDABDD6A9AD9F733E720E519E61DC62312FB45E1BD5F4D9BD67A736BCEBA5CD57D54DD08D7DC0B7AD3DE21965D7DA455234B9EF2ACC2DEDA2300B853EE25E32CC4DB234F973856D58CEDD2FF7FAAB73CC29D4512574EE17276BCC630C864CCFFA64BA0878A4A02160B2D2BD0954F52C9EE58196B59CC53E67609808C6AA6FD36773901F90359747DBC5B361DD17A45F2C5D3E3949C100A6EAAE3A24F7331A9F1CC684F58927836690A95F9CEF12F65B5A8B394021C3766C1AAC94BD4F358C43EE544B2D466B16395B148D58ED59E659B09BC633342559F6A9497E22F5C23329B308F39B535CFF204DD9A7348E730EBD39CD97D21BE52D5C2A1B4D1B298B90533592661D903745E810F4A1420C13B8296D42A42AB826A4DF4BDB94535F16F045BA2139F7F921AB56890D7ECFCC57A214E9E3E6B9AD5E52E87C632BA950481E1F1F3FD95A4D80FC7B828FA02083CE76BDAEC8C898F40EBE91C7808D5BF179E31F909F12DB402EBBD555BF348FFD877629037D868DC3E9117340B0163F45216BCB8DA381BDA173161220722A0313BA606CA164619E0C0FFCE627FA161515E771B57BB31716BB635A8A2CE4E255D2B23C5CDD0F5D39197BDE6A4EA543AB5F5780B210FD891997721BBF069D1065654C13DFD9F88E5791FFE4E1E371E03E3B5EB9DB057CEADACCA7395FDD17DC00BF8A016762";
			
			var temp:String = "", i:int, j:int;
			var dat:ByteArray = new ByteArray();
			
			// １６進数をByteArrayに変換する
			for ( i = 0, j = wheelByteArray.length / 2; i < j; i ++ )
			{
				temp = wheelByteArray.substr( i * 2, 2 );
				dat.writeByte( parseInt( temp, 16 ) - 128 );
			}
			
			
			// メモリー上にロードする
			var loader:Loader = new Loader();
			loader.loadBytes( dat );
			
			
			// AVM1と通信するためのLocalConnectionを生成する。
			AVM_lc = new LocalConnection();
			AVM_lc.addEventListener( StatusEvent.STATUS, function():void { return; } );
		}
		
		
		static private var _instance:WheelMouse;
		
		/**
		 * AVM1用マウスホイル機能を有効にする。
		 */
		static public function run():void {
			if ( !_instance ) {
				_instance = new WheelMouse( Singleton as Class );
			}
			else {
				_instance.AVM_lc.send( "AVM2toAVM1", "wheelHandler", true );
			}
		}
		
		
		/**
		 * AVM1用マウスホイル機能を無効にする。
		 */
		static public function remove():void {
			if ( _instance ) {
				_instance.AVM_lc.send( "AVM2toAVM1", "wheelHandler", false );
			}
		}
		
		
	}
}


internal class Singleton {}