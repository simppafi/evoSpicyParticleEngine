package evospicyparticleengine.color {
	/**
	 * @author simo
	 */
	public interface IColor {
		function get():Vector.<Vector.<Number>>;
		function get resolution():int;
		function dispose():void;
	}
}
