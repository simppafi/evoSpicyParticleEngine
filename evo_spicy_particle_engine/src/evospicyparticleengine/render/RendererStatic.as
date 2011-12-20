package evospicyparticleengine.render {
	import evospicyparticleengine.buffer.BufferParticle;
	import evospicyparticleengine.program.IProgram;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	/**
	 * @author simo
	 */
	public final class RendererStatic extends RendererBase {
		
		public var color_r:Number;
		public var color_g:Number;
		public var color_b:Number;
		
		function RendererStatic(programClass:IProgram, backgroundColor:uint = 0x000000)
		{
			super(programClass);
			
			this.color_r = ((backgroundColor & 0xff0000) >> 16)/255;
			this.color_g = ((backgroundColor & 0x00ff00) >> 8)/255;
			this.color_b = (backgroundColor & 0x0000ff)/255;
		}
		
		override protected function initialize():void
		{
			_moveVector = Vector.<Number>([	0, 	//time
											1,	//max
											10, //size of static particle
											1,]);
			
			_fragmentConst = new Vector.<Number>([	0.0001, //prepare for alphakill value 1-this
													1, 
													1,
													1,]);
			
			context3d.setTextureAt( 0, texture );
			context3d.setProgram(program);
			context3d.setVertexBufferAt(1, sharedUVBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConst);
			
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _moveVector, 1);
			
		}
		
		override public final function render():void
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
			context3d.clear(color_r, color_g, color_b, 1);
			
			
			if(filtered) 
			{
				context3d.setRenderToTexture(renderTexture, true, 0, 0);
				context3d.clear(color_r, color_g, color_b, 1);
				
				context3d.setTextureAt( 0, texture );
				context3d.setProgram(program);
				context3d.setVertexBufferAt(1, sharedUVBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentConst);
			}
			
			var system:BufferParticle;
			var k:int = buffers.length;
			for(var j:int = 0; j < k; j++)
			{
				system = buffers[j];
				
				context3d.setVertexBufferAt(2, system._rgbBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				
				context3d.setVertexBufferAt(0, system.positionStartBuffer, 0, Context3DVertexBufferFormat.FLOAT_4);
				
				context3d.drawTriangles(sharedIndexBuffer);
			}
			
			
			if(filtered) 
			{
				context3d.setRenderToBackBuffer();
				
				//context3d.setDepthTest(false, Context3DCompareMode.NEVER); 
				context3d.setTextureAt( 0, renderTexture );
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
