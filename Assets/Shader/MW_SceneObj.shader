Shader "MW/SceneObj" 
{
	Properties {
		_MainTex ("MainTex", 2D) = "white" {}
		_Albedo("Albedo Color", Color) = (0.5,0.5,0.5,0.5)

		_Emission("Emission", Color) = (0.5,0.5,0.5,0.5)
	}
                
	SubShader 
	{
		Pass{
			Tags
			{
				"Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="TransparentCutout"
			}
			//Blend SrcAlpha one
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct v2f{
				fixed4 sv_pos: SV_POSITION;
				fixed4 uv: TEXCOORD0;
				fixed3 uv_Lightmap : TEXCOORD1;	 
				UNITY_FOG_COORDS(2)
			};

			struct appdata_t {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};

			v2f vert (appdata_t v){
				v2f o;

				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.sv_pos);
				o.uv = v.texcoord;
				o.uv_Lightmap = v.texcoord1;  

				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Albedo;
			fixed4 _Emission;

			struct fragOuput{
				fixed4 color : SV_Target;
			};
 
 			fragOuput frag(v2f i): SV_Target
			{
				fragOuput o;
				fixed4 c = fixed4(0,0,0,0);

				fixed4 texColor =  tex2D (_MainTex, TRANSFORM_TEX(i.uv, _MainTex));

				//光照贴图
				fixed2 uv_Lightmap = i.uv_Lightmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv_Lightmap));
				fixed3 albedo = texColor.rgb * _Albedo.rgb * _Albedo.a;
				fixed3 emiss = texColor.rgb * _Emission.rgb;
				c.rgb = albedo * lm + lerp(albedo, emiss, _Emission.a);

				//fog颜色处理
				UNITY_APPLY_FOG(i.fogCoord, c);

				o.color = c;
				return o; 
			}
			ENDCG
		}
	}
//Fallback "Diffuse"
}
