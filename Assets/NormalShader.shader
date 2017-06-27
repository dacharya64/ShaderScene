// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "vijay/Simple/7 - NormalMaps" {
	Properties{
		_Color("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex("Diffuse Texture", 2D) = "white" {}
	_BumpMap("Normal Texture", 2D) = "bump" {}

	//ADD SPECULAR PROPERTIES HERE
	//_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor("Specular Color", Color) = (1, 1, 1, 1) //white
		_Shininess("Shininess", Float) = 10
	}

		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma exclude_renderers flash

		//User defined variables
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform float4 _Color;

		//ADD SPECULAR VARIABLES HERE
		uniform float4 _SpecColor; //specular color
		uniform float _Shininess;


		//Unity defined variables
		uniform float4 _LightColor0;

		//Base input structs
		struct vertexInput {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 tangent : TANGENT;
		};
		struct vertexOutput {
			float4 pos : SV_POSITION;
			float4 tex : TEXCOORD0;
			float4 posWorld : TEXCOORD1;
			float3 tangentWorld : TEXCOORD2;
			float3 normalWorld : TEXCOORD3;
			float3 binormalWorld : TEXCOORD4;
		};

		//vertex function

		vertexOutput vert(vertexInput v) {
			vertexOutput o;

			o.tangentWorld = normalize(float3(mul(unity_ObjectToWorld, float4(float3(v.tangent.xyz), 0.0)).xyz));
			o.normalWorld = normalize(mul(float4 (v.normal.xyz, 0.0), unity_WorldToObject).xyz);
			o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld).xyz * v.tangent.w);

			o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			//o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.tex = v.texcoord;

			return o;
		}

		//fragment function

		float4 frag(vertexOutput i) : COLOR
		{
			float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - float3(i.posWorld.xyz));
			float3 lightDirection;
			float atten;

			if (_WorldSpaceLightPos0.w == 0.0) {	//directional light
				atten = 1.0;
				lightDirection = normalize(float3(_WorldSpaceLightPos0.xyz));
			}
			else {
				float3 fragmentToLightSource = float3(_WorldSpaceLightPos0.xyz - float3(i.posWorld.xyz));
				float distance = length(fragmentToLightSource);
				atten = 1.0 / distance;
				lightDirection = normalize(fragmentToLightSource);
			}

			//Texture maps
			float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
			float4 texN = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

			//unpackNormal function
			float3 localCoords = float3 (2.0 * texN.ag - float2(1.0, 1.0), 0.0);

			localCoords.z = 1.0;

			//normal transpose matrix
			float3x3 local2WorldTranspose = float3x3(
				i.tangentWorld,
				i.binormalWorld,
				i.normalWorld
				);


			float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));


			//Lighting
			float3 diffuseReflection = atten * float3(_LightColor0.rgb) * max(0.0, dot(normalDirection, lightDirection));
			//float3 specularReflection = (0.0, 0.0, 0.0);	

			//FILL THIS PART TO ADD SPECULAR PROPERTIES TO THE LIGHT
			float3 specularReflection = _Color.rgb * _LightColor0.rgb * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess); //calculating reflected vector , finding halfway b/w that and view

			float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection + specularReflection;


			return float4(tex.xyz * lightFinal * _Color.xyz, 1.0);
		}

			ENDCG


		}//end pass

		 //Fallback "Diffuse"


		}//end subshader

}