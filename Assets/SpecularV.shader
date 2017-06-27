// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Devi/SpecularV"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1) //white
		_Shininess("Shininess", Float) = 10
	}
		SubShader
	{


		Pass
		{
			//Tags {"LightMode" = "ForwardBase"} //don't worry about what this does for now
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//User defined variable
			uniform float4 _Color;
			uniform float4 _SpecColor; //specular color
			uniform float _Shininess; 

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

				float atten = 1.0; // distance form the light source 

				float3 viewDirection = normalize((_WorldSpaceCameraPos.rgb) - mul(unity_ObjectToWorld, v.vertex)).rgb; //eye position - (local coordinate of vertex * world coor system)

				//3) Diffuse light -- for every normal, need dot product of normal and light direction to find light amount on that particular face, multiply by material color and light color
				float3 diffuseLight = float3(_Color.rgb) * float3(_LightColor0.rgb) * max(0.0, dot(normalDirection, lightDirection)); //max in case the value is < 0, if angle >= 90

				float3 specularReflection = _Color.rgb * _LightColor0.rgb * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess); //calculating reflected vector , finding halfway b/w that and view

				float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.rgb + diffuseLight + specularReflection; //adding up all light

				//o.col = float4(diffuseLight, 1.0); //output for vertex shader
				//o.col = float4(normalDirection, 1.0); //output for vertex shader RAINBOW
				o.col = float4(lightFinal, 1.0); //output sum of all light

				//o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex); //put vertices where they're supposed to be 
				return o;
				
			}

			//interpolates color at pixel level 
			float4 frag(vertexOutput i) : COLOR{
				return i.col;
			}


			ENDCG
		}
	}

		//Fallback "Diffuse"
}
