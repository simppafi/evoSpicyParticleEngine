package evospicyparticleengine.buffer.value {
	import evospicyparticleengine.buffer.BufferParticle;
	import evospicyparticleengine.buffer.value.data.IData;
	import flash.display.BitmapData;
	import evospicyparticleengine.color.IColor;
	
	/**
	 * @author simo
	 */
	public class ValueBitmapData implements IValue {
		
		private var startXMul:Number, startYMul:Number, startZMul:Number, endXMul:Number, endYMul:Number, endZMul:Number;
		private var size:Number;
		private var randomSize:Boolean;
		private var movementMultiplier:Number;
		private var colors:IColor;
		
		public var data:IData;
		private var reso:int;
		
		function ValueBitmapData(	colors:IColor, data:IData,	startXMul:Number = 0, 		startYMul:Number = 0, 		startZMul:Number = 0,
															endXMul:Number = 96, 		endYMul:Number = 96, 		endZMul:Number = 96,
															size:Number = 8, 			randomSize:Boolean = false, movementMultiplier:Number = 0)
		{
			this.colors = colors;
			this.data = data;
			this.startXMul = startXMul;
			this.startYMul = startYMul;
			this.startZMul = startZMul;
			this.endXMul = endXMul;
			this.endYMul = endYMul;
			this.endZMul = endZMul;
			this.size = size;
			this.randomSize = randomSize;
			this.movementMultiplier = movementMultiplier;
		}
		
		private var bufferIndex:int;
		private var bufferCount:int;
		private var totalParticleCount:int;
		public function setup(bufferIndex:int, bufferCount:int, totalParticleCount:int):void
		{
			this.bufferIndex = bufferIndex;
			this.bufferCount = bufferCount;
			this.totalParticleCount = totalParticleCount;
			
			//reso =  Math.round(Math.sqrt(totalParticleCount));
			reso =  Math.round(Math.sqrt(BufferParticle.BUFFER_SIZE));
			if(!data.initialized) data.setup(reso);
		}
		
		public function set(	_positionStartData:Vector.<Number>,
								_positionEndData:Vector.<Number>,
								_moveData:Vector.<Number>,
								_rgbData:Vector.<Number>,
								_positionStartOffset:Vector.<Number>,
								_positionEndOffset:Vector.<Number>,
								countParticles:int):void
		{
			
			var move0:Number, move1:Number, move2:Number, move3:Number;
			
			var dx0:Number, dy0:Number, dz0:Number;
			var dx1:Number, dy1:Number, dz1:Number;
			var dx2:Number, dy2:Number, dz2:Number;
			
			var x:Number, y:Number, z:Number;
			
			var _slice:int = bufferIndex*countParticles;
			var dive:Number = 1/totalParticleCount;
			var col:int;
			var colorData:Vector.<Vector.<Number>> = colors.get();
			var colorResolution:int = colors.resolution;
			
			var dx:Number, dy:Number, dz:Number;
			var _x:int = 0;
			var _y:int = 0;
			
			data.execute(bufferIndex);
			var bit0:BitmapData = data.bit0;
			var bit1:BitmapData = data.bit1;
			var bit2:BitmapData = data.bit2;
			
			for(var i:int = 0; i < countParticles; i++)
			{
					if(_x == reso) {
						_y++;
						_x = 0;
					}
					
					dx = -42 + bit0.getPixel(_x, _y) * .00000500;
					dy = -42 + bit1.getPixel(_x, _y) * .00000500;
					dz = -42 + bit2.getPixel(_x, _y) * .00000500;
					
					x = dx*startXMul;
					y = dy*startYMul;
					z = dz*startZMul;
					
					dx0 = x; dy0 = y; dz0 = z;
					dx1 = x; dy1 = y; dz1 = z;
					dx2 = x; dy2 = y; dz2 = z;
					
					_positionStartData.push(	dx0, dy0, dz0, 10,
												dx1, dy1, dz1, 11,
												dx2, dy2, dz2, 12);
												
					_positionStartOffset.push(	dx0, dy0, dz0, 10,
												dx1, dy1, dz1, 11,
												dx2, dy2, dz2, 12);
											
					
					
					x = dx*endXMul;
					y = dy*endYMul;
					z = dz*endZMul;
					
					dx0 = x; dy0 = y; dz0 = z;
					dx1 = x; dy1 = y; dz1 = z;
					dx2 = x; dy2 = y; dz2 = z;
					
					_positionEndData.push(	dx0, dy0, dz0, 10,
											dx1, dy1, dz1, 11,
											dx2, dy2, dz2, 12);
					
					_positionEndOffset.push(	dx0, dy0, dz0, 10,
												dx1, dy1, dz1, 11,
												dx2, dy2, dz2, 12);
					
										
					
					move0 = 1000; 									// movement starttime time
					move1 = 1+movementMultiplier*Math.random();		// movement multiplier
					if(randomSize)
					{
						move2 = 1 + size * Math.random();			// size of particle
					}else{
						move2 = size;
					}
					move3 = 0;
					
					_moveData.push(	move0,move1,move2,move3,
									move0,move1,move2,move3,
									move0,move1,move2,move3);
					
					
					// COLORS
					col = int((_slice+i)*dive*colorResolution);
					_rgbData.push(	colorData[col][0], colorData[col][1], colorData[col][2],
									colorData[col][3], colorData[col][4], colorData[col][5],
									colorData[col][6], colorData[col][7], colorData[col][8]);
					
					_x++;
				
			}
			
		}
		
		public function dispose():void
		{
			data.dispose();
			data = null;
			colors.dispose();
			colors = null;
		}
		
	}
}
