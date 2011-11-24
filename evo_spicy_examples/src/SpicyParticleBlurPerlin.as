package 
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import evospicyparticleengine.buffer.StartPoint3D;
	import flash.utils.getTimer;
	import evospicyparticleengine.render.RendererLinear;
	import evospicyparticleengine.ease.EaseProgram;
	import evospicyparticleengine.program.ProgramLinearNoAlphaKill;
	import evospicyparticleengine.buffer.value.data.DataPerlin;
	import evospicyparticleengine.color.ColorGradient;
	import evospicyparticleengine.buffer.value.ValueBitmapData;
	import flash.display.BlendMode;
	import evospicyparticleengine.texture.TextureParticleBlur;
	import evospicyparticleengine.EvoSpicyParticleEngine;
	import flash.events.Event;
	import flash.display.Sprite;
	
	[SWF(width="1280", height="720", frameRate="60", backgroundColor = "#0")]
	public class SpicyParticleBlurPerlin extends Sprite
	{
		private var spicy:EvoSpicyParticleEngine;
		
		public function SpicyParticleBlurPerlin()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		function init(event:Event):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Create engine instance. (Reference to stage, stageIndex = which stage.stage3Ds to use, enableErrorChecking, set f-key as fullscren trigger)
			spicy = new EvoSpicyParticleEngine(stage, 0, false, true);
			
			// If context3d failed
			spicy.on3DFailed.add(on3DFailed);
			
			// Get info about users GPU.
			spicy.onGPUInfo.add(onGPUInfo);
			
			// Wait until the engine is ready.
			spicy.onEngineReady.add(onEngineReady);
		}
		
		private function on3DFailed():void
		{
			trace("3D Failed");
		}
		
		private function onGPUInfo(info:String):void
		{
			trace("GPUInfo: "+info);
		}
		
		private function onEngineReady():void
		{
			// Z-Sort particles or not.
			spicy.setDepthTest(false);
			
			// Texture for particles.
			spicy.setTextureParticle(new TextureParticleBlur(128));
			
			// BlendMode of particles.
			spicy.setBlendMode(BlendMode.ADD);
			
			// How far away particles are rendered
			spicy.zFar = 30000;
			
			// Field Of View
			spicy.fov = 90;
			
			// count : int (maximum particle count = 1398080), valueClass : IValue (settings for particles. start points, end points, speeds, colors) 
			spicy.addParticles(139808, new ValueBitmapData(	new ColorGradient([0x3bc1ff, 0x84481b, 0xFFc1ff, 0x3bc1ff]), 			//colors
															new DataPerlin(12, 60, 80), 											// PerlinNoise data for positions
															10, 10, 10, 															// Start position multipliers
															250, 250, 250, 															// End position multipliers
															16, 																	// Size of single particle
															true, 																	// Randomize sizes or not
															0));																	// Add random value for individual speed
			
			// particle renderer. 
			var renderer:RendererLinear; 
			spicy.setRenderer(renderer = new RendererLinear(	new ProgramLinearNoAlphaKill(EaseProgram.EXPO_OUT, false, true), 	// Vertex and Fragment shader programs for particles
																0.000008, 															// Speed of particles
																128,  																// How many particles to rebirth in every frame
																0x1e1b17)); 														// Background color
			
			// Move the start point
			renderer.startPoints[0].y = -500;
			
			// add extra start point(s) (renderer.startPoints[1])
			renderer.addStartPoint(new StartPoint3D(0, 500, 0));
			
			
			// Start rendering
			this.addEventListener(Event.ENTER_FRAME, run);
		}
		
		private function run(event:Event):void
		{
			var time:int = getTimer();
			
			var angle:Number = time * .0001;
			var rad:Number = 2000;
			
			spicy.camera.position.x = rad * Math.sin(angle);
			spicy.camera.position.z = rad * Math.cos(angle);
			spicy.camera.position.y = 0;
			
			spicy.camera.lookAtPoint(0,0,0);
			
			spicy.camera.rotationZ = time * .01;
			
			spicy.render();
		}
		
	}
}
