package evospicyparticleengine.buffer {
	import evospicyparticleengine.buffer.value.IValue;
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	
	/**
	 * @author simo
	 */
	public final class BufferParticle {
		
		public static const BUFFER_SIZE		:int = 21845;
		
		public var countData				:int;
		public var countVertices			:int;
		public var countParticles			:int;
		
		// POSITION START
		public var _positionStartData 		:Vector.<Number>;
		public var _positionStartOffset		:Vector.<Number>;
		
		// POSITION END
		public var _positionEndData 		:Vector.<Number>;
		public var _positionEndOffset		:Vector.<Number>;
		
		// COLORS
		public var _rgbData					:Vector.<Number>;
		public var _rgbBuffer				:VertexBuffer3D;
		
		// PARTICLE PARAMETERS
		public var _moveData 				:Vector.<Number>;
		
		public var positionStartBuffer		:VertexBuffer3D;
		public var positionEndBuffer		:VertexBuffer3D;
		public var moveBuffer				:VertexBuffer3D;
		
		private var valueClass				:IValue;
		private var bufferIndex				:int;
		
		function BufferParticle(particleCount:int, valueClass:IValue, bufferIndex:int) 
		{	
			countParticles = particleCount;
			countVertices = particleCount * 3;
			countData = (countVertices / 3) * 12;
			this.valueClass = valueClass;
			this.bufferIndex = bufferIndex;
		}
		
		// GET RID OF THIS
		
		public var pos						:int = 0;
		public var _pos						:int = 0;
		public var goal						:int = 0;
		public var _dataSize				:int; 
		public var _streamSize:int;
		public final function setStreamSize(value:int):void
		{
			_streamSize = 12 * value;
		}
		
		public final function setup(context3d:Context3D):void
		{
			createVertexBuffer(context3d);
			setStreamSize(24);
			_dataSize = 21845 * 12;
		}
		
		private function createVertexBuffer(context3d:Context3D):void
		{
			_positionStartData = new Vector.<Number>();
			_positionEndData = new Vector.<Number>();
			_moveData = new Vector.<Number>();
			_rgbData = new Vector.<Number>();
			
			_positionStartOffset = new Vector.<Number>();
			_positionEndOffset = new Vector.<Number>();
			
			valueClass.set(	_positionStartData, 
							_positionEndData, 
							_moveData, 
							_rgbData, 
							_positionStartOffset,
							_positionEndOffset, 
							countParticles);
			valueClass = null;
			
			_rgbBuffer = context3d.createVertexBuffer(countParticles * 3, 3);
			_rgbBuffer.uploadFromVector(_rgbData, 0, countParticles * 3);
			_rgbData = null;
			
			positionStartBuffer = context3d.createVertexBuffer(countParticles * 3, 4);
			positionStartBuffer.uploadFromVector(_positionStartData, 0, countParticles * 3);
			
			positionEndBuffer = context3d.createVertexBuffer(countParticles * 3, 4);
			positionEndBuffer.uploadFromVector(_positionEndData, 0, countParticles * 3);
			
			moveBuffer = context3d.createVertexBuffer(countParticles * 3, 4);
			moveBuffer.uploadFromVector(_moveData, 0, countParticles * 3);
			
		}
		
		
		public final function dispose():void
		{
			
		}
		
		
	}
}
