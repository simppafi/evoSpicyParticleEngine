package evospicyparticleengine.buffer.value.data {
	import flash.display.BitmapData;
	/**
	 * @author simo
	 */
	public interface IData {
		function get initialized():Boolean;
		function get bit0():BitmapData;
		function get bit1():BitmapData;
		function get bit2():BitmapData;
		function setup(reso:int):void;
		function execute(bufferIndex:int):void;
		function dispose():void;
	}
}
