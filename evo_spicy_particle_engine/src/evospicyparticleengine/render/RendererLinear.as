package evospicyparticleengine.render {
	import evospicyparticleengine.buffer.StartPoint3D;
	import evospicyparticleengine.buffer.BufferParticle;
	import evospicyparticleengine.program.IProgram;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	/**
	 * @author simo
	 */
	public class RendererLinear extends RendererBase {
		
		public var color_r:Number;
		public var color_g:Number;
		public var color_b:Number;
		public var speed:Number;
		function RendererLinear(program:IProgram, speed:Number, streamSize:int = 16, backgroundColor:uint = 0x000000)
		{
			super(program, streamSize);
			this.speed = speed;
			
			this.color_r = ((backgroundColor & 0xff0000) >> 16)/255;
			this.color_g = ((backgroundColor & 0x00ff00) >> 8)/255;
			this.color_b = (backgroundColor & 0x0000ff)/255;
		}
		
		override protected function initialize():void
		{
			_moveVector = Vector.<Number>([	0, 	//time
											1,	//max
											-10, //size of static particle
											2]);
			
			
			_fragmentConst = new Vector.<Number>([	0.0001, //prepare for alphakill value 1-this
													1, 
													1,
													1]);
			
			positionStartBuffer = context3d.createVertexBuffer(buffer_vertice_count, 4);
			positionEndBuffer = context3d.createVertexBuffer(buffer_vertice_count, 4);
			moveBuffer = context3d.createVertexBuffer(buffer_vertice_count, 4);
			
			context3d.setTextureAt( 0, texture );
			context3d.setProgram(program);
			context3d.setVertexBufferAt(1, sharedUVBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConst);
			
			context3d.setVertexBufferAt(2, buffers[0]._rgbBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			
			positionStartBuffer.uploadFromVector(buffers[0]._positionStartData, 0, buffer_vertice_count);
			context3d.setVertexBufferAt(0, positionStartBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
			positionEndBuffer.uploadFromVector(buffers[0]._positionEndData, 0, buffer_vertice_count);
			context3d.setVertexBufferAt(4, positionEndBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
			moveBuffer.uploadFromVector(buffers[0]._moveData, 0, buffer_vertice_count);
			context3d.setVertexBufferAt(3, moveBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
			
		}
		
		private var pos:int = 0;
		private var goal:int = 0;
		private var delta:int = 0, prevt:int = 0;
		private var time:Number = 0;
		private var bufferpos:int = 0;
		private var dataSize:int = (buffer_vertice_count / 3) * 12;
		override public function render():void
		{
			// CAMERA
			transformCamera.identity();
			
			transformCamera.position = camera.position;
			
			if(camera._doLookAt) {
				transformCamera.pointAt(camera._renderLookAt, Vector3D.Z_AXIS, _up);
				camera._doLookAt = false;
			}
			
			transformCamera.prependRotation(camera.rotationX, Vector3D.Y_AXIS);
			transformCamera.prependRotation(camera.rotationY, Vector3D.Y_AXIS);
			transformCamera.prependRotation(camera.rotationZ, Vector3D.Z_AXIS);
			
			transformCamera.copyToMatrix3D(transformParticle);
			transformCamera.invert();
			
			// MODEL
			transformModel.identity();
			transformModel.position = this;
			transformModel.append(transformCamera);
			transformModel.append(transformProjection);
			
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, transformModel, true);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 13, transformParticle, true);
			
			
			
			// RENDER
			var moveData:Vector.<Number>, positionStartData:Vector.<Number>, positionEndData:Vector.<Number>, offsetStartPosData:Vector.<Number>, offsetEndPosData:Vector.<Number>;
			var d:Number, startX:Number, startY:Number, startZ:Number;
			var startpoint:StartPoint3D;
			var buffer:BufferParticle;
		
			var _time:int = getTimer();
			delta = _time - prevt;
			prevt = _time;
			
			var c:int = 0;
			time += delta*speed;
			var b:int, b2:int, b3:int;
			
			context3d.clear(color_r, color_g, color_b, 1);
			
			
			if(filtered) 
			{
				context3d.setRenderToTexture(renderTexture, true, 0, 0);
				context3d.clear(color_r, color_g, color_b, 1);
				
				context3d.setTextureAt( 0, texture );
				//context3d.setTextureAt( 1, null );
				
				context3d.setProgram(program);
				context3d.setVertexBufferAt(1, sharedUVBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConst);
			}
			
			
			
			// TIME TO SHADER
			d = _moveVector[0] = time;
			
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _moveVector, 1);
			
			var l:int = buffers.length;
			for(var i:int = 0; i < l; i++)
			{	
				buffer = buffers[i];
				
				moveData = buffer._moveData;
				positionStartData = buffer._positionStartData;
				positionEndData = buffer._positionEndData;
				
				if(bufferpos == i)
				{
					goal += _streamSize;
					if(goal > dataSize) {
						
						if(goal == int(dataSize+_streamSize))
						{
							goal = _streamSize;
							pos = 0;
							c = 0;
							bufferpos = (++bufferpos == l) ? 0 : bufferpos;
						}else{
							goal = dataSize;
						}
					}
					
					offsetStartPosData = buffer._positionStartOffset;
					offsetEndPosData = buffer._positionEndOffset;
					
					for(; pos < goal; pos+=12)
					{
						startpoint = startPoints[int(c++ % startPointsCount)];
						
						startX = startpoint.x;
						startY = startpoint.y;
						startZ = startpoint.z;
						
						positionStartData[b2 = int(pos+8)] = positionStartData[b3 = int(pos+4)] = positionStartData[pos] = offsetStartPosData[pos] + startX;
						positionEndData[b2] = positionEndData[b3] = positionEndData[pos] = offsetEndPosData[pos] + startX;
						positionStartData[b2 = int(pos+9)] = positionStartData[b3 = int(pos+5)] = positionStartData[b = int(pos+1)] = offsetStartPosData[b] + startY;
						positionEndData[b2] = positionEndData[b3] = positionEndData[b] = offsetEndPosData[b] + startY;
						positionStartData[b2 = int(pos+10)] = positionStartData[b3 = int(pos+6)] = positionStartData[b = int(pos+2)] = offsetStartPosData[b] + startZ;
						positionEndData[b2] = positionEndData[b3] = positionEndData[b] = offsetEndPosData[b] + startZ;
						
						 
						moveData[pos] = moveData[int(pos+4)] = moveData[int(pos+8)] = d; 			//x starttime
						//moveData[int(pos+1)] = moveData[int(pos+5)] = moveData[int(pos+9)] = 1+Math.random()*.5;		//y time multiplier
						//moveData[int(pos+2)] = moveData[int(pos+6)] = moveData[int(pos+10)] = sca;		//z scale of particle
					}
					
					buffer.positionStartBuffer.uploadFromVector(positionStartData, 0, buffer_vertice_count);
					buffer.positionEndBuffer.uploadFromVector(positionEndData, 0, buffer_vertice_count);
					buffer.moveBuffer.uploadFromVector(moveData, 0, buffer_vertice_count);
				}
				
				context3d.setVertexBufferAt(0, buffer.positionStartBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
				context3d.setVertexBufferAt(4, buffer.positionEndBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
				context3d.setVertexBufferAt(3, buffer.moveBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
				context3d.setVertexBufferAt(2, buffer._rgbBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				
				context3d.drawTriangles(sharedIndexBuffer);
				
			}
			
			
		
			if(filtered) 
			{
				context3d.setRenderToBackBuffer();
				
				//context3d.setDepthTest(false, Context3DCompareMode.NEVER); 
				context3d.setTextureAt( 0, renderTexture );
				//context3d.setTextureAt( 1, renderTextureCopy );
				
				context3d.setProgram(renderProgram);
				context3d.setVertexBufferAt(0, renderVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				context3d.setVertexBufferAt(1, renderUVBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				
				context3d.setVertexBufferAt(2, null);
				context3d.setVertexBufferAt(3, null);
				context3d.setVertexBufferAt(4, null);
				
				context3d.drawTriangles(renderIndexBuffer);
			}
			
			
			context3d.present();
		}
	}
}
