/*
 * ForcibleLoader
 *
 * Licensed under the MIT License
 *
 * Copyright (c) 2007-2009 BeInteractive! (www.be-interactive.org) and
 *                         Spark project  (www.libspark.org)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
package org.libspark.utils
{
	import flash.errors.EOFError;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public final class ForcibleLoader2
	{
		public function ForcibleLoader2()
		{
		}

		private static function isCompressed(bytes:ByteArray):Boolean
		{
			return bytes[0] == 0x43;
		}

		private static function uncompress(bytes:ByteArray):void
		{
			var cBytes:ByteArray = new ByteArray();
			cBytes.writeBytes(bytes, 8);
			bytes.length = 8;
			bytes.position = 8;
			cBytes.uncompress();
			bytes.writeBytes(cBytes);
			bytes[0] = 0x46;
			cBytes.length = 0;
			//cBytes.clear();
		}

		private static function updateVersion(bytes:ByteArray, version:uint):void
		{
			bytes[3] = version;
		}

		private static function flagSWF9Bit(bytes:ByteArray):void
		{
			var pos:int = findFileAttributesPosition(getBodyPosition(bytes), bytes);
			if (pos != -1) {
				bytes[pos + 2] |= 0x08;
			}
			else {
				insertFileAttributesTag(bytes);
			}
		}

		private static function insertFileAttributesTag(bytes:ByteArray):void
		{
			var pos:uint = getBodyPosition(bytes);
			var afterBytes:ByteArray = new ByteArray();
			afterBytes.writeBytes(bytes, pos);
			bytes.length = pos;
			bytes.position = pos;
			bytes.writeByte(0x44);
			bytes.writeByte(0x11);
			bytes.writeByte(0x08);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeBytes(afterBytes);
			afterBytes.length = 0;
		}

		private static function findFileAttributesPosition(offset:uint, bytes:ByteArray):int
		{
			bytes.position = offset;

			try {
				for (;;) {
					var byte:uint = bytes.readShort();
					var tag:uint = byte >>> 6;
					if (tag == 69) {
						return bytes.position - 2;
					}
					var length:uint = byte & 0x3f;
					if (length == 0x3f) {
						length = bytes.readInt();
					}
					bytes.position += length;
				}
			}
			catch (e:EOFError) {
			}

			return -1;
		}

		private static function getBodyPosition(bytes:ByteArray):uint
		{
			var result:uint = 0;

			result += 3; // FWS/CWS
			result += 1; // version(byte)
			result += 4; // length(32bit-uint)

			var rectNBits:uint = bytes[result] >>> 3;
			result += (5 + rectNBits * 4) / 8; // stage(rect)

			result += 2;

			result += 1; // frameRate(byte)
			result += 2; // totalFrames(16bit-uint)

			return result;
		}

		public static function getBytes(bytes:ByteArray):ByteArray
		{
			bytes.endian = Endian.LITTLE_ENDIAN;

			if (isCompressed(bytes))
			{
				uncompress(bytes);
			}

			var version:uint = uint(bytes[3]);

			if (version < 9)
			{
				updateVersion(bytes, 9);
			}
			if (version > 7)
			{
				flagSWF9Bit(bytes);
			}
			else
			{
				insertFileAttributesTag(bytes);
			}

			return bytes;
		}

	}

}
