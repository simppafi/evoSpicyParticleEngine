package evospicyparticleengine.texture {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.Context3D;
	/**
	 * @author simo
	 */
	public final class TextureParticleAlphaKill implements ITextureParticle {
		
		private var resolution:int;
		
		function TextureParticleAlphaKill(resolution:int = 128)
		{
			this.resolution = resolution;
		}
		
		public final function get(context3d:Context3D, texture:Texture):Texture
		{
			var mul:Number = resolution/256;
			texture = context3d.createTexture( resolution, resolution, Context3DTextureFormat.BGRA, false);
			var bitmapData:BitmapData = new BitmapData(resolution, resolution, true, 0xFFFF0000);
			var ball:Sprite = new Sprite();
			ball.graphics.beginFill(0xFFFFFF, 1);
			ball.graphics.drawCircle(128 * mul, 178 * mul, 78 * mul);
			ball.graphics.endFill();
			bitmapData.draw(ball);
			texture.uploadFromBitmapData(bitmapData);
			return texture;
		}
		
	}
}
