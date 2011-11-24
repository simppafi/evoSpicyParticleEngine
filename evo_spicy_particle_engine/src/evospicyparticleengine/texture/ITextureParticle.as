package evospicyparticleengine.texture {
	import flash.display3D.textures.Texture;
	import flash.display3D.Context3D;
	/**
	 * @author simo
	 */
	public interface ITextureParticle {
		function get(context3d:Context3D, texture:Texture):Texture;
	}
}
