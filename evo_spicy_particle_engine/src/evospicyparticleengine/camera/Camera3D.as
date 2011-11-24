package evospicyparticleengine.camera {
	import flash.geom.Vector3D;
	/**
	 * @author simo
	 */
	public class Camera3D {
		
		public var _renderLookAt	:Vector3D = new Vector3D();
		public var _doLookAt		:Boolean = false;
		
		public var position			:Vector3D = new Vector3D();
		
		public var rotationX		:Number = 0;
		public var rotationY		:Number = 0;
		public var rotationZ		:Number = 0;
		
		function Camera3D() {}
		
		public function lookAtVector3D(lookAt:Vector3D):void
		{
			_renderLookAt = lookAt;
			_doLookAt = true;
		}
		
		public function lookAtPoint(x:Number, y:Number, z:Number):void
		{
			_renderLookAt.x = x;
			_renderLookAt.y = y;
			_renderLookAt.z = z;
			_doLookAt = true;
		}
		
	}
}
