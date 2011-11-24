package evospicyparticleengine.buffer.value {
	import evospicyparticleengine.color.IColor;
	
	/**
	 * @author simo
	 */
	public class ValueExplosionCube implements IValue {
		
		private var startXRadius:Number, startYRadius:Number, startZRadius:Number, endXRadius:Number, endYRadius:Number, endZRadius:Number;
		private var size:Number;
		private var randomSize:Boolean;
		private var movementMultiplier:Number;
		private var colors:IColor;
		function ValueExplosionCube(	colors:IColor, 	startXRadius:Number = 50, 	startYRadius:Number = 50, 	startZRadius:Number = 50,
														endXRadius:Number = 500, 	endYRadius:Number = 500, 	endZRadius:Number = 500,
														size:Number = 8, 			randomSize:Boolean = false, movementMultiplier:Number = 0
														)
		{
			this.colors = colors;
			this.startXRadius = startXRadius;
			this.startYRadius = startYRadius;
			this.startZRadius = startZRadius;
			this.endXRadius = endXRadius;
			this.endYRadius = endYRadius;
			this.endZRadius = endZRadius;
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
			var sxr:Number = startXRadius * 2;
			var syr:Number = startYRadius * 2;
			var szr:Number = startZRadius * 2;
			
			var exr:Number = endXRadius * 2;
			var eyr:Number = endYRadius * 2;
			var ezr:Number = endZRadius * 2;
			
			var _slice:int = bufferIndex*countParticles;
			var dive:Number = 1/totalParticleCount;
			
			var col:int;
			var colorData:Vector.<Vector.<Number>> = colors.get();
			var colorResolution:int = colors.resolution;
			
			for(var i:int = 0; i < countParticles; i++)
			{
				x = -startXRadius + sxr*Math.random();
				y = -startYRadius + syr*Math.random();
				z = -startZRadius + szr*Math.random();
				
				dx0 = x; dy0 = y; dz0 = z;
				dx1 = x; dy1 = y; dz1 = z;
				dx2 = x; dy2 = y; dz2 = z;
				
				_positionStartData.push(	dx0, dy0, dz0, 10,
											dx1, dy1, dz1, 11,
											dx2, dy2, dz2, 12);
											
				_positionStartOffset.push(	dx0, dy0, dz0, 10,
											dx1, dy1, dz1, 11,
											dx2, dy2, dz2, 12);
										
				
				x = -endXRadius + exr*Math.random();
				y = -endYRadius + eyr*Math.random();
				z = -endZRadius + ezr*Math.random();
				
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
								
			}
			
		}
		
		public function dispose():void
		{
			this.colors.dispose();
			this.colors = null;
		}
	}
}
