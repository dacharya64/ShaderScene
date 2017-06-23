Shader "Devi/FlatShader"{
	Properties{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0) //_Color is the variable name that you can reference in the rest of the shader file, "Color" is the name that will show up in Unity inspector, Color is type, then #s that default to floats
	}

		Subshader{	//properties that will be used in shader, what you want to do in shader 
			Pass {
				CGPROGRAM
				#pragma vertex vert //every shader comes with vertex and fragment shader
				#pragma fragment frag


				//User defined values
				float4 _Color; //A float with 4 defined values, can access certain values by _Color.x or _Color.r, use xyzw or rgba but don't mix them like "xg", they mean the same things tho -- one for coordinate position, other for color, but they're the same

				//Define a vertex input structure
				struct vertexInput {
					float4 vertex : POSITION; //POSITION is semantics -- reserved word that Unity understands, don't change this
				};

				//Define a vertex output structure 
				struct vertexOutput {
					float4 pos : SV_POSITION; //For vertex output, SV for cross-compatibility
				};

				vertexOutput vert(vertexInput v) {
					vertexOutput o;
					o.pos = UnityObjectToClipPos(v.vertex); //updated version of mul(UNITY_MATRIX_MVP, v.vertex); //mul = multiply, taking existing MVP (model view projection, existing state of Unity scene) and multuplying vertices
					return o;
				}

				float4 frag(vertexOutput i) : COLOR {
					return _Color;
				}

			ENDCG
		}
	}



	//Fallback "Diffuse"
}