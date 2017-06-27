// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Devi/LambertShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
		SubShader
	{


		Pass
		{
			Tags {"LightMode" = "ForwardBase"} //don't worry about what this does for now
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//User defined variable
			uniform float4 _Color;

			//Unity defined variable
			uniform float4 _LightColor0; //reserved word, tells you color of light

			//struct vertex input
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL; //passing in normals 
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR; //outputting color, passing into fragment 
			};

			vertexOutput vert(vertexInput v) {
				vertexOutput o; 

				//1) Normal direction 
				//need to map local (input) coordinates to world coordinates
				float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).rgb); //typecasing normal into 4 part value, then multiplying by world coordinate system, but only need first 3 elements so take .rgb
				//normalize takes elements and reduces them consistently so values stay b/w 0 and 1, remember to do this for consistency in output! 

				//2) Light direction
				float3 lightDirection = normalize(_WorldSpaceLightPos0.rgb);


				//3) Diffuse light -- for every normal, need dot product of normal and light direction to find light amount on that particular face, multiply by material color and light color
				float3 diffuseLight = float3(_Color.rgb) * float3(_LightColor0.rgb) * max(0.0, dot(normalDirection, lightDirection)); //max in case the value is < 0, if angle >= 90

				o.col = float4(diffuseLight, 1.0); //output for vertex shader
				//o.col = float4(normalDirection, 1.0); //output for vertex shader RAINBOW
				//o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex); 
				return o;
				
			}

			float4 frag(vertexOutput i) : COLOR{
				return i.col;
			}


			ENDCG
		}
	}

		//Fallback "Diffuse"
}
