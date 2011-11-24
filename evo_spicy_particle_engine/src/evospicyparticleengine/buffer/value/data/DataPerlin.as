package evospicyparticleengine.buffer.value.data {
	import flash.geom.Point;
	import flash.display.BitmapData;
	/**
	 * @author simo
	 */
	public class DataPerlin implements IData {
		
		private var bits:Vector.<BitmapData>;
		private var offset:Array;
		private var sizeA:int, sizeB:int, sizeC:int;
		private var mulAx:Number, mulAy:Number, mulBx:Number, mulBy:Number;
		
		function DataPerlin(sizeA:int = 120, sizeB:int = 60, sizeC:int = 80, 
							mulOffsetAx:Number = 0, mulOffsetAy:Number = 148, 
							mulOffsetBx:Number = 0, mulOffsetBy:Number = 148):void
		{
			this.sizeA = sizeA;
			this.sizeB = sizeB;
			this.sizeC = sizeC;
			this.mulAx = mulOffsetAx;
			this.mulAy = mulOffsetAy;
			this.mulBx = mulOffsetBx;
			this.mulBy = mulOffsetBy;
			bits = new Vector.<BitmapData>();
		}
		
		private var _initialized:Boolean = false;
		public function get initialized():Boolean { return _initialized; }
		
		public function get bit0():BitmapData { return bits[0]; }
		public function get bit1():BitmapData { return bits[1]; }
		public function get bit2():BitmapData { return bits[2]; }
		
		public function setup(reso:int):void
		{
			var s:int = int(reso+1);
			bits[0] = new BitmapData(s, s, false, 0);
			bits[1]  = new BitmapData(s, s, false, 0);
			bits[2]  = new BitmapData(s, s, false, 0);
			offset = new Array(new Point(), new Point());
			_initialized = true;
		}
		
		public function execute(bufferIndex:int):void
		{
			offset[0]["x"] = bufferIndex * mulAx;
			offset[0]["y"] = bufferIndex * mulAy;
			offset[1]["x"] = bufferIndex * mulBx;
			offset[1]["y"] = bufferIndex * mulBy;
			
			bits[0].perlinNoise(sizeA, sizeA, 2, Math.random(), true, true, 1, true, offset);
			bits[1].perlinNoise(sizeB, sizeB, 2, Math.random(), true, true, 1, true, offset);
			bits[2].perlinNoise(sizeC, sizeC, 2, Math.random(), true, true, 1, true, offset);
		}
		
		public function dispose():void
		{
			offset = null;
			bits[0].dispose();
			bits[1].dispose();
			bits[2].dispose();
			bits[0] = null;
			bits[1] = null;
			bits[2] = null;
			bits = null;
		}
	}
}
