package evospicyparticleengine.program {
	import evospicyparticleengine.ease.EaseProgram;
	import flash.display3D.Context3DProgramType;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	/**
	 * @author simo
	 */
	public final class ProgramLinearNoAlphaKill implements IProgram {
		
		private var ease:int;
		private var fromFullBright:Boolean;
		private var dimmDuringLife:Boolean;
		
		function ProgramLinearNoAlphaKill(ease:int = EaseProgram.LINEAR, fromFullBright:Boolean = false, dimmDuringLife:Boolean = false):void
		{
			this.ease = ease;
			this.fromFullBright = fromFullBright;
			this.dimmDuringLife = dimmDuringLife;
		}
		
		public final function get(context3d:Context3D):Program3D
		{
			var _constVertex:Vector.<Number>;
			
			if(ease == EaseProgram.EXPO_OUT || ease == EaseProgram.LINEAR)
			{
				// EXPO OUT
				_constVertex = Vector.<Number>([	0, 	
													1,	
													-10, 
													2]);
			}
			else if(ease == EaseProgram.EXPO_IN)
			{
				// EXPO IN
				_constVertex = Vector.<Number>([	0.001, 	
													1,	
													10, 
													2]);
				
			}
													
			context3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, _constVertex, 1);
			
			
			// SHADERS
			var agalVertexSource : String = 	"";
												
			agalVertexSource += 	"mov vt1, va0 \n"; 
																			// va3.x = starttime
			agalVertexSource += 	"sub vt3.x, vc4.x, va3.x \n";			// time + start time 0..1
			agalVertexSource += 	"mul vt3.x, vt3.x, va3.y \n";			// multiply time with move.y
			//agalVertexSource += 	"slt vt3.y, vt3.x, vc4.y \n";			// LIMIT TO 0-1; destination = source1 >= source2 ? 1 : 0, componentwise
			//agalVertexSource += 	"mul vt3.x, vt3.x, vt3.y \n";			// LIMIT TO 0-1;
																			// vt3.x = 0-1
												
												
			if(ease == EaseProgram.EXPO_OUT)
			{
				// EXPO OUT
				// (t:Number, b:Number, c:Number, d:Number)
				// time, 0, 1, 1
				// 1 * (-Math.pow(2, -10 * time/1) + 1) + 0;
				// -Math.pow(2, -10 * time) + 1;
				//________________________________________________________________
				agalVertexSource += 	"mul vt6.x, vc5.z, vt3.x \n"; 		// -10 * vt3.x
				agalVertexSource += 	"pow vt7.x, vc5.w, vt6.x \n"; 		// Math.pow(2, vt6)
				agalVertexSource += 	"neg vt7.x, vt7.x \n"; 				// -Math.pow(2, vt6)
				agalVertexSource += 	"add vt3.x, vt7.x, vc5.y \n"; 
			}
			else if(ease == EaseProgram.EXPO_IN)
			{
				// EXPO IN
				// (t:Number, b:Number, c:Number, d:Number)
				// time, 0, 1, 1
				// 1 * Math.pow(2, 10 * (time/d1 - 1)) + 0 - 1 * 0.001;
				// Math.pow(2, 10 * (time - 1)) - 0.001;
				//________________________________________________________________
				agalVertexSource += 	"sub vt6.x, vt3.x, vc5.y \n"; 		// (time - 1)
				agalVertexSource += 	"mul vt6.x, vt6.x, vc5.z \n"; 		// 10 * (time - 1)
				agalVertexSource +=		"pow vt7.x, vc5.w, vt6.x \n"; 		// Math.pow(2, (10 * (time - 1)))
				agalVertexSource += 	"sub vt3.x, vt7.x, vc5.x \n"; 		// Math.pow(2, (10 * (time - 1))) - 0.001
			}
			
			// LINEAR MOVEMENT
			agalVertexSource += 	"sub vt6.xyz, va4.xyz, vt1.xyz \n"; 	// b - a
			agalVertexSource += 	"mul vt7.xyz, vt6.xyz, vt3.x \n"; 		// movement
			agalVertexSource += 	"add vt1.xyz, vt1.xyz, vt7.xyz \n"; 	// add move
												
												
			// LIGHT
			/*"sub vt4, vt1, vc5 \n" + 		//vc5 light
			"dp3 vt4, vt4, vt4 \n" +
			"mul vt5, vt4.x, vc5.w \n" + 	// power of light
			
			"sub vt4, vt1, vc6 \n" + 		//vc6 light
			"dp3 vt4, vt4, vt4 \n" +
			"mul vt4, vt4.x, vc6.w \n" + 	//  power of light
			"mul vt5, vt5, vt4 \n" + 		// 
			
			"sub vt4, vt1, vc7 \n" + 		//vc7 light
			"dp3 vt4, vt4, vt4 \n" +
			"mul vt4, vt4.x, vc7.w \n" + 	//  power of light
			"mul vt5, vt5, vt4 \n" + 		
			
			"sub vt4, vt1, vc8 \n" + 		//vc8 light
			"dp3 vt4, vt4, vt4 \n" +
			"mul vt4, vt4, vc8.w \n" + 		//  power of light
			"mul v3, vt5, vt4 \n" + 		
			*/					
								
			agalVertexSource += 	"mov vt2, vc[va0.w] \n"; 
			agalVertexSource += 	"m33 vt0.xyz, vt2.xyz, vc13     \n";
			agalVertexSource += 	"mov vt0.w, vt2.w \n";
			agalVertexSource += 	"mul vt0.xyz, vt0.xyz, va3.z \n"; 		//Size of particle
			agalVertexSource += 	"add vt0.xyz, vt0.xyz, vt1.xyz \n"; 
			agalVertexSource += 	"m44 op, vt0, vc0 \n"; 					//transform and output vertex x,y,z
											
			agalVertexSource += 	"mov v1, va1 \n";       				// Send UVs to fragment shader
			agalVertexSource += 	"mov v2, va2 \n";       				// Send RGB to fragment shader
			agalVertexSource += 	"mov v0, vt3.x \n"; 					// lifetime to fragment shader
			
			
			var agalVertex : AGALMiniAssembler = new AGALMiniAssembler();
			agalVertex.assemble(Context3DProgramType.VERTEX, agalVertexSource);

			var agalFragmentSource:String = "";
			
			agalFragmentSource +=	"tex ft0, v1, fs0 <2d,linear> \n"; 		// Texture 2d,linear,miplinear //2d,linear,nearest
			agalFragmentSource +=	"mul ft0, ft0, v2 \n";					// colors
											
			//agalFragmentSource +=	"rcp ft1, v3 \n" +						// Lights
			//agalFragmentSource +=	"add ft0, ft0, ft1 \n" +				// Lights
											
			if(fromFullBright) {
				agalFragmentSource +=	"div ft0, ft0, v0 \n";				// from full bright to normal
			}
			if(dimmDuringLife) {
				agalFragmentSource +=	"sub ft0, ft0, v0 \n";				// dimm during life
			}								
											
			agalFragmentSource +=	"mov oc, ft0 ";           				// output color
			
			
			var agalFragment : AGALMiniAssembler = new AGALMiniAssembler();
			agalFragment.assemble(Context3DProgramType.FRAGMENT, agalFragmentSource);

			var _program:Program3D = context3d.createProgram();
			_program.upload(agalVertex.agalcode, agalFragment.agalcode);
			
			return _program;
		}
	}
}
