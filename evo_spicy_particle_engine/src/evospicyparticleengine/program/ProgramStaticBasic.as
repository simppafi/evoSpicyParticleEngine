package evospicyparticleengine.program {
	import flash.display3D.Context3DProgramType;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
	/**
	 * @author simo
	 */
	public class ProgramStaticBasic implements IProgram {
		
		function ProgramStaticBasic():void
		{
			
		}
		
		public function get(context3d:Context3D):Program3D
		{
			// SHADERS
			var agalVertexSource : String = 	"" +
												
												"mov vt1, va0 \n" + 
												
												"mov vt2, vc[va0.w] \n" + 
												"m33 vt0.xyz, vt2.xyz, vc13     \n" +
												"mov vt0.w, vt2.w \n" + 
												"mul vt0.xyz, vt0.xyz, vc4.z \n" +  	// Size of particle
												"add vt0.xyz, vt0.xyz, vt1.xyz \n" + 
												
												"m44 op, vt0, vc0 \n"+ 					//transform and output vertex x,y,z
												
												"mov v1, va1 \n"+       				// Send UVs to fragment shader
												"mov v2, va2 \n"+       				// Send RGB to fragment shader
												
												"";
													
			var agalVertex : AGALMiniAssembler = new AGALMiniAssembler();
			agalVertex.assemble(Context3DProgramType.VERTEX, agalVertexSource);

			var agalFragmentSource:String = ""+
											"tex ft0, v1, fs0 <2d,linear> \n"+ 			// Texture 2d,linear,miplinear //2d,linear,nearest
											"sub ft0, ft0, ft0.x \n"+      				// prepare for alpha kill
											"kil ft0.y \n" + 							// Alpha Kill red pixels
											"move oc, v2 \n" +							// colors and output
											
											"";
			
			var agalFragment : AGALMiniAssembler = new AGALMiniAssembler();
			agalFragment.assemble(Context3DProgramType.FRAGMENT, agalFragmentSource);

			var _program:Program3D = context3d.createProgram();
			_program.upload(agalVertex.agalcode, agalFragment.agalcode);
			
			return _program;
		}
	}
}
