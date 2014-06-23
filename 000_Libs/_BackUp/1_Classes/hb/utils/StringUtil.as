package hb.utils
{
	/**
		@name : StringUtil
		@author : jungheebum(jhb0b@naver.com)
		@blog : http://blog.naver.com/jhb0b
		@date : 2009-04-02
	*/
	public final class StringUtil
	{
		public function StringUtil()
		{
		}

		// :: String is last number
		public static function getLastNumber(str:String, lastIndex:Number):String
		{
			return str.substr(lastIndex, str.length-lastIndex);
		}

		// :: Is String
		public static function getIsEmpty(v:String):Boolean
		{
			var rv:Boolean = false;

			if(v == null || v == '' || v.split(' ').join('').length < 1)
			{
				rv = true;
			}

			return rv;
		}
		
		// :: 
		public static function addTokkenNumber(target:String, count:int, tokken:String = '0'):String
		{
			var t_str:String = String(target);
			var t_len:int = count - t_str.length;	
			var i:Number = 0;

			while (i < t_len)
			{
				t_str = tokken + t_str;
				
				i++;
			}
			
			return t_str;
		}
	}
}