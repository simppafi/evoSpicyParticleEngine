package evospicyparticleengine.render {
	import flash.display3D.Context3DProgramType;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DTextureFormat;
	import evospicyparticleengine.buffer.StartPoint3D;
	import evospicyparticleengine.buffer.BufferParticle;
	import evospicyparticleengine.camera.Camera3D;
	import evospicyparticleengine.program.IProgram;
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * @author simo
	 */
	public class RendererBase extends Vector3D {
		
		public var startPoints					:Vector.<StartPoint3D>;
		protected var startPointsCount			:int;
		
		protected var _streamSize				:int;
		
		protected var context3d					:Context3D;
		protected var transformModel			:Matrix3D;
		protected var transformCamera			:Matrix3D;
		protected var transformProjection		:Matrix3D;
		protected var transformParticle			:Matrix3D;
		protected var camera					:Camera3D;
		
		protected var texture					:Texture;
		protected var program					:Program3D;
		protected var programClass				:IProgram;
		
		protected var sharedIndexBuffer			:IndexBuffer3D;
		protected var sharedUVBuffer			:VertexBuffer3D;
		protected var buffers					:Vector.<BufferParticle>;
		protected var buffersLength				:int;
		
		protected var _fragmentConst			:Vector.<Number>;
		protected var _moveVector				:Vector.<Number>;
		
		
		protected var positionStartBuffer		:VertexBuffer3D;
		protected var moveBuffer				:VertexBuffer3D;
		protected var positionEndBuffer			:VertexBuffer3D;
		
		//	FILTERED
		protected var filtered					:Boolean = false; 
		protected var renderProgram 			:Program3D;
		protected var renderTexture				:Texture;
		protected var renderVertexBuffer		:VertexBuffer3D;
		protected var renderIndexBuffer 		:IndexBuffer3D;
		protected var renderUVBuffer			:VertexBuffer3D;
		
		// CONSTANTS
		protected const _up						:Vector3D = new Vector3D(0, -1, 0);
		protected const buffer_vertice_count	:int = 65535;
		
		
		function RendererBase(programClass:IProgram, streamSize:int = 16):void
		{
			this.programClass = programClass;
			this.startPoints = new Vector.<StartPoint3D>();
			addStartPoint(new StartPoint3D());
			this.streamSize = streamSize;
		}
		
		public final function addStartPoint(startpoint:StartPoint3D):void
		{
			this.startPoints.push(startpoint);
			startPointsCount = startPoints.length;
		}
		
		private var _streamsizevalue:int;
		public final function set streamSize(value:int):void
		{
			_streamSize = value * 12;
			_streamsizevalue = value;
		}
		
		public final function get streamSize():int
		{
			return _streamsizevalue;
		}
		
		
		protected function initialize():void
		{
			//Must be overridden										
		}
		
		public final function setup(context:Context3D,
									camera:Camera3D,
									texture:Texture,
									sharedIndexBuffer:IndexBuffer3D,
									sharedUVBuffer:VertexBuffer3D,
									buffers:Vector.<BufferParticle>,
									transformModel:Matrix3D,
									transformCamera:Matrix3D,
									transformProjection:Matrix3D,
									transformParticle:Matrix3D):void
		{
			this.context3d = context;
			this.camera = camera;
			this.texture = texture;
			this.sharedIndexBuffer = sharedIndexBuffer;
			this.sharedUVBuffer = sharedUVBuffer;
			this.buffers = buffers;
			this.buffersLength = buffers.length;
			
			this.transformModel = transformModel;
			this.transformCamera = transformCamera;
			this.transformProjection = transformProjection;
			this.transformParticle = transformParticle;
			
			this.program = programClass.get(context3d);
			this.programClass = null;
			
			createViewPort();
			
			this.initialize();
		}
		
		public final function setupFiltered(	renderProgram:Program3D,
												renderTexture:Texture,
												renderVertexBuffer:VertexBuffer3D,
												renderIndexBuffer:IndexBuffer3D,
												renderUVBuffer:VertexBuffer3D):void
		{
			this.renderProgram = renderProgram;
			this.renderTexture = renderTexture;
			this.renderVertexBuffer = renderVertexBuffer;
			this.renderIndexBuffer = renderIndexBuffer;
			this.renderUVBuffer = renderUVBuffer;
		}
		
		
		public function render():void
		{
			//Must be overridden
		}
		
		
		
		public final function dispose():void
		{
			this.context3d = null;
			this.camera = null;
			this.texture = null;
			this.program = null;
			this.sharedIndexBuffer = null;
			this.sharedUVBuffer = null;
			this.buffers = null;
			
			this.renderProgram = null;
			this.renderTexture = null;
			this.renderVertexBuffer = null;
			this.renderIndexBuffer = null;
			this.renderUVBuffer = null;
		}
		
		
		
		
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
		}
		
		
	}
}
