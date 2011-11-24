package evospicyparticleengine.buffer.value {
	/**
	 * @author simo
	 */
	public interface IValue {
		function setup(bufferIndex:int, bufferCount:int, totalParticleCount:int):void;
		function set(	_positionStartData:Vector.<Number>,
						_positionEndData:Vector.<Number>,
						_moveData:Vector.<Number>,
						_rgbData:Vector.<Number>,
						_positionStartOffset:Vector.<Number>,
						_positionEndOffset:Vector.<Number>,
						countParticles:int):void;
		function dispose():void;
	}
}
