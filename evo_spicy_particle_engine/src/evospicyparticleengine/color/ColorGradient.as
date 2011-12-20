package evospicyparticleengine.color {
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	/**
	 * @author simo
	 */
	public final class ColorGradient implements IColor {
		
		private var colorData:Vector.<Vector.<Number>>;
		function ColorGradient(colorValue:Array, resolution:int = 4096, darkColors:Array = null, lightColor:Array = null)
		{
			this._resolution = resolution;
			
			colorData = new Vector.<Vector.<Number>>();
			
			var sprite:Sprite = new Sprite();
			var colors:Vector.<BitmapData> = new Vector.<BitmapData>(3, true);
			var l:int, i:int;
			
			var _darkColors:Array = new Array();
			var _lightColors:Array = new Array();
			var alphas:Array = new Array();
			var ratios:Array = new Array();
			l = colorValue.length;
			var rat:int = 255 / (l-1);
		   	for(i = 0; i < l; i++)
			{
				alphas.push(1);
				ratios.push(rat*i);
				if(!darkColors) {
					_darkColors.push(0x313131);
				}
				if(!lightColor) {
					_lightColors.push(0xFFFFFF);
				}
			}
			
			var fillType:String = GradientType.LINEAR;
		    var cols:Array = [darkColors || _darkColors, colorValue, lightColor || _lightColors];
		    var matr:Matrix = new Matrix();
		    matr.createGradientBox(resolution, 1, 0, 0, 0);
		    var spreadMethod:String = SpreadMethod.PAD;
			
			for(i = 0; i < 3; i++)
			{
				colors[i] = new BitmapData(resolution, 1, false, 0);
				sprite.graphics.clear();
				sprite.graphics.beginGradientFill(fillType, cols[i], alphas, ratios, matr, spreadMethod);
				sprite.graphics.drawRect(0, 0, resolution, 1);
				sprite.graphics.endFill();
				colors[i].draw(sprite);
			}
			
			var vec0:Vector.<uint> = colors[0].getVector(colors[0].rect);
			var vec1:Vector.<uint> = colors[1].getVector(colors[1].rect);
			var vec2:Vector.<uint> = colors[2].getVector(colors[2].rect);
			
			var col0:uint, col1:uint, col2:uint;
			for(i = 0; i < resolution; i++)
			{
				col0 = vec0[i];
				col1 = vec1[i];
				col2 = vec2[i];
				colorData[i] = Vector.<Number>([	((col0 & 0xff0000) >> 16)/255, ((col0 & 0x00ff00) >> 8)/255, (col0 & 0x0000ff)/255,
													((col1 & 0xff0000) >> 16)/255, ((col1 & 0x00ff00) >> 8)/255, (col1 & 0x0000ff)/255,
													((col2 & 0xff0000) >> 16)/255, ((col2 & 0x00ff00) >> 8)/255, (col2 & 0x0000ff)/255]);
			}
			
			colors[0].dispose();
			colors[0] = null;
			colors[1].dispose();
			colors[1] = null;
			colors[2].dispose();
			colors[2] = null;
			colors = null;
		}
		
		public final function get():Vector.<Vector.<Number>>
		{
			return colorData;
		}
		
		private var _resolution:int;
		public final function get resolution():int
		{
			return _resolution;
		}
		
		public final function dispose():void
		{
			colorData = null;
		}
		
	}
}
