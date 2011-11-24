package evospicyparticleengine.program {
	import flash.display3D.Program3D;
	import flash.display3D.Context3D;
	/**
	 * @author simo
	 */
	public interface IProgram {
		function get(context3d:Context3D):Program3D;
	}
}
