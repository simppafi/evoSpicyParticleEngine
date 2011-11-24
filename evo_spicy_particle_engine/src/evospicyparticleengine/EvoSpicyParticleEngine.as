package evospicyparticleengine{
	import evospicyparticleengine.texture.ITextureParticle;
	import flash.display.BlendMode;
	import com.adobe.utils.AGALMiniAssembler;
	import evospicyparticleengine.buffer.BufferParticle;
	import evospicyparticleengine.buffer.value.IValue;
	import evospicyparticleengine.camera.Camera3D;
	import evospicyparticleengine.render.RendererBase;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageDisplayState;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import org.osflash.signals.Signal;
	
	/**
	 * @author simo
	 */
	public class EvoSpicyParticleEngine
	{
		public var onEngineReady			:Signal;
		public var onGPUInfo				:Signal;
		public var on3DFailed				:Signal;
		
		private var context3d				:Context3D;
		private var texture					:Texture;
		
		private var transformModel			:Matrix3D;
		private var transformCamera			:Matrix3D;
		private var transformProjection		:Matrix3D;
		private var transformParticle		:Matrix3D;
		
		private var stage:Stage;
		private var _fov:Number, _aspect:Number, _zNear:Number, _zFar:Number;
		
		public var camera:Camera3D;
		
		private var filtered:Boolean = false;
		private var enableErrorChecking:Boolean;
		
		public function EvoSpicyParticleEngine(stage:Stage, stageIndex:int = 0, enableErrorChecking:Boolean = false, fKeyForFullscreen:Boolean = true)
		{
			onEngineReady = new Signal();
			onGPUInfo = new Signal(String);
			on3DFailed = new Signal();
			
			transformModel = new Matrix3D();
			transformCamera = new Matrix3D();
			transformProjection = new Matrix3D();
			transformParticle = new Matrix3D();
			
			this.stage = stage;
			this.enableErrorChecking = enableErrorChecking;
			
			camera = new Camera3D();
			
			_aspect = stage.stageWidth/stage.stageHeight;
			_zNear = 0.1;
			_zFar = 10000;
			_fov = 60*Math.PI/180;
			perspective(_fov, _aspect, _zNear, _zFar);
			
			if(fKeyForFullscreen) stage.addEventListener(KeyboardEvent.KEY_UP, keyListener);
			
			var stage3d : Stage3D = stage.stage3Ds[stageIndex];
			stage3d.x = 0;
			stage3d.y = 0;
			
			stage3d.addEventListener(Event.CONTEXT3D_CREATE, onGotContext);
			stage3d.addEventListener(ErrorEvent.ERROR, context3dError);
			stage3d.requestContext3D(Context3DRenderMode.AUTO);
			stage.addEventListener(Event.RESIZE, resize);
		}
		
		private function onGotContext(event : Event) : void
		{
			var stage3d : Stage3D = Stage3D(event.currentTarget);
			context3d = stage3d.context3D;
			
			if (context3d == null)
			{
				on3DFailed.dispatch();
				return;
			}
			
			onGPUInfo.dispatch(context3d.driverInfo);
			
			context3d.enableErrorChecking = enableErrorChecking;
			context3d.configureBackBuffer(stage.stageWidth &~1, stage.stageHeight &~1, 0, true);
			context3d.setCulling(Context3DTriangleFace.BACK);
			context3d.setDepthTest(true, Context3DCompareMode.LESS); 
			context3d.setBlendFactors( Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA );
			
			if(filtered) createViewPort();
			
			onEngineReady.dispatch();
		}
		
		
		// ADD //
		 
		private var sharedIndexBuffer:IndexBuffer3D;
		private var sharedUVBuffer:VertexBuffer3D;
		private var buffers:Vector.<BufferParticle>;
		public function addParticles(count:int, valueClass:IValue):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
				
			buffers = new Vector.<BufferParticle>();
			
			var buff:BufferParticle;
			var bufferCount:int = int(count/21845);
			var particleCount:int = 21845 * bufferCount;
			for(var i:int = 0; i < bufferCount; i++)
			{
				valueClass.setup(i, bufferCount, particleCount);
				buff = new BufferParticle(21845, valueClass, i);
				buff.setup(context3d);
				buffers.push(buff);
			}
			valueClass.dispose();
			valueClass = null;
			trace("I only do full buffers. Particle count: "+bufferCount*21845 +", Buffers: "+bufferCount);
			
			sharedIndexBuffer = createIndexBuffer();
			sharedUVBuffer = createUVBuffer();
			createTriangle();
			
			if(pendingRenderer) setPendingRenderer();
		}
		
		
		
		// CREATE //
		 
		private function createIndexBuffer():IndexBuffer3D
		{
			var countVertices:int = 21845 * 3;
			var indexData : Vector.<uint > = new Vector.<uint>(countVertices, true);
			for(var i:int = 0; i < countVertices; i++) { indexData[i] = i; }
			var indexBuffer:IndexBuffer3D = context3d.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			return indexBuffer;
		}
		
		private function createUVBuffer():VertexBuffer3D
		{
			var countParticles:int = 21845;
			var countVertices:int = countParticles * 3;
			var _uvData:Vector.<Number> = new Vector.<Number>();
			for(var i:int = 0; i < countParticles; i++) { _uvData.push(0,1,.5,0,1,1);}
			var uvBuffer:VertexBuffer3D = context3d.createVertexBuffer(countVertices, 2);
			uvBuffer.uploadFromVector(_uvData, 0, countVertices);
			return uvBuffer;
		}
		
		private function createTriangle():void
		{
			var data:Vector.<Number> = Vector.<Number>([-1, -1, 0, 1]);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 10, data, 1);
			data = Vector.<Number>([0, 1, 0, 1]);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 11, data, 1);
			data = Vector.<Number>([1, -1, 0, 1]);
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, data, 1);
		}
		
		
		// SETUP //
		 
		public function setDepthTest(value:Boolean):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
			if(value) {
				context3d.setDepthTest(true, Context3DCompareMode.LESS); 
			}else{
				context3d.setDepthTest(false, Context3DCompareMode.ALWAYS);
			}
		}
		
		public function setTextureParticle(particleTexture:ITextureParticle):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
			texture = particleTexture.get(context3d, texture);
		}
		
		public function setBlendMode(blendMode:String):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
			if(blendMode == BlendMode.ADD)
			{
				context3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA);
			}else{
				context3d.setBlendFactors( Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA );
			}
		}
		
		public function setBlendFactors(sourceFactor:String, destinationFactor:String):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
			context3d.setBlendFactors(sourceFactor, destinationFactor);
		}
		
		public var render:Function;
		private var renderer:RendererBase;
		private var pendingRenderer:Boolean = false;
		public function setRenderer(renderer:RendererBase):void
		{
			if (context3d == null) { throw("EvoSpicyEngine isn't ready yet. Listen singal onEngineReady"); return; }
			
			if(buffers)
			{
				pendingRenderer = false;
				this.renderer = renderer;
				this.renderer.setup(context3d, 
									camera, 
									texture, 
									sharedIndexBuffer, 
									sharedUVBuffer, 
									buffers,
									transformModel,
									transformCamera,
									transformProjection,
									transformParticle);
				
				this.render = renderer.render;
			}else{
				pendingRenderer = true;
				this.renderer = renderer;
				this.render = renderer.render;
			}
		}
		private function setPendingRenderer():void
		{
			this.renderer.setup(context3d, 
								camera, 
								texture, 
								sharedIndexBuffer, 
								sharedUVBuffer, 
								buffers,
								transformModel,
								transformCamera,
								transformProjection,
								transformParticle);
			pendingRenderer = false;
		}
		
		
		// PERSPECTIVE //
		 
		public function perspective(fov:Number, aspect:Number, zNear:Number, zFar:Number):void 
		{
			this._fov = fov;
			this._aspect = aspect;
			this._zNear = zNear;
			this._zFar = zFar;
			var yScale:Number = 1.0/Math.tan(fov/2.0);
			var xScale:Number = yScale / aspect; 
			transformProjection.copyRawDataFrom(Vector.<Number>([	xScale, 0.0, 0.0, 0.0,
																	0.0, yScale, 0.0, 0.0,
																	0.0, 0.0, zFar/(zFar-zNear), 1.0,
																	0.0, 0.0, (zNear*zFar)/(zNear-zFar), 0.0 ]));
		}
		
		public function set fov(value:Number):void
		{
			_fov = value*Math.PI/180;
			perspective(_fov, _aspect, _zNear, _zFar);
		}
		
		public function get fov():Number
		{
			return _fov;
		}
		
		public function set zFar(value:Number):void
		{
			_zFar = value;
			perspective(_fov, _aspect, _zNear, _zFar);
		}
		
		public function get zFar():Number
		{
			return _zFar;
		}
		
		
		
		// POSTPROCESS //
		
		private var hasViewPort:Boolean = false;
		
		private var renderProgram : Program3D;
		private var renderTexture:Texture;
		private var renderVertexBuffer:VertexBuffer3D;
		private var renderIndexBuffer : IndexBuffer3D;
		private var renderUVBuffer:VertexBuffer3D;
		
		private var renderTextureWidth:int = 2048 >> 1;
		private var renderTextureHeight:int = 2048 >> 1;
		
		private function createViewPort():void
		{
			renderTexture = context3d.createTexture( renderTextureWidth, renderTextureHeight, Context3DTextureFormat.BGRA, true );
			
			// SHADERS
			var agalVertexSource : String = 	"" +
												"mov op, va0 \n" +
												"mov v0, va1 \n" +
												"";
													
			var agalVertex : AGALMiniAssembler = new AGALMiniAssembler();
			agalVertex.assemble(Context3DProgramType.VERTEX, agalVertexSource);

			var agalFragmentSource:String = "";
			
			agalFragmentSource += "tex oc, v0, fs0 <2d,linear,miplinear> \n"; //2d,linear,miplinear
			
			
			var agalFragment : AGALMiniAssembler = new AGALMiniAssembler();
			agalFragment.assemble(Context3DProgramType.FRAGMENT, agalFragmentSource);
			
			renderProgram = context3d.createProgram();
			renderProgram.upload(agalVertex.agalcode, agalFragment.agalcode);
			
			// VERTEX & INDEX
			var indexData : Vector.<uint > = new Vector.<uint>();
			indexData.push(0, 2, 1, 0, 3, 2); 
			
			renderIndexBuffer = context3d.createIndexBuffer(indexData.length);
			renderIndexBuffer.uploadFromVector(indexData, 0, indexData.length);
			
			var vertexData:Vector.<Number> = new Vector.<Number>();
			
			var halfW:Number = 1;
	        var halfH:Number = 1;
	        vertexData.push(-halfW, -halfH); // 0 -  left  bottom front
	        vertexData.push( halfW, -halfH); // 1 -  right bottom front
	        vertexData.push( halfW,  halfH); // 2 -  right top    front
	        vertexData.push(-halfW,  halfH); // 3 -  left  top    front
	        
			renderVertexBuffer = context3d.createVertexBuffer(4, 2);
			renderVertexBuffer.uploadFromVector(vertexData, 0, 4);
			
			// u,v
			var uvData:Vector.<Number> = new Vector.<Number>();
			uvData.push(0, 1);
        	uvData.push(1, 1);
       		uvData.push(1, 0);
        	uvData.push(0, 0);
			
			renderUVBuffer = context3d.createVertexBuffer(4, 2);
			renderUVBuffer.uploadFromVector(uvData, 0, 4);
			
			hasViewPort = true;
		}
		
		
		
		/******/
		
		private function context3dError(event:ErrorEvent):void
		{
			trace("context3derror "+event.text);
		}
		
		private function keyListener(event:KeyboardEvent):void
		{
			if(event.keyCode == 70)
			{
				if(stage.allowsFullScreen) {
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}
			}
		}
		
		private function resize(event:Event):void
		{
			_aspect = stage.stageWidth/stage.stageHeight;
			perspective(_fov, _aspect, _zNear, _zFar);
			context3d.configureBackBuffer((int(stage.stageWidth)&~1), (int(stage.stageHeight)&~1), 0, true);
		}
		
		
	}
}
