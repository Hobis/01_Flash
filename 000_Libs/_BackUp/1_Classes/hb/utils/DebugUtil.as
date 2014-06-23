/**
	@ name : Debug trace tool
	@author : jungheebum(jhb0b@naver.com)
	@blog : http://blog.naver.com/jhb0b
	@date : 2009-04-02
*/
package hb.utils
{
	public class DebugUtil
	{
		public function DebugUtil()
		{
		}

		public static function test(str:String):void
		{
			if (isDebug)
			{
				trace(fontMsg+str);
			}
		}

		public static var isDebug:Boolean = true;
		public static var fontMsg:String = '# [hb] ';

	}
}
