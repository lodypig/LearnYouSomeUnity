Shader "MW/SceneObject_2T" 
{
	Properties {
		_MainTex ("MainTex", 2D) = "white" {}
		_Albedo("Albedo Color", Color) = (0.5,0.5,0.5,0.5)

		_EmissionTex("Emission Tex", 2D) = "white" {}
		_Emission("Emission", Color) = (0.5,0.5,0.5,0.5)
		
		_LightColor("Light Color", Color)         = (1, 0.3, 0, 1.0)
		_LightDir("DirectLightDir", Vector)		  = (-1.9,0.02,0.33,0)
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
				fixed3 normal: TEXCOORD3;
			};

			struct appdata_t {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 normal : NORMAL;
			};

			v2f vert (appdata_t v){
				v2f o;

				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.sv_pos);
				o.uv = v.texcoord;
				o.uv_Lightmap = v.texcoord1;  
				o.normal = v.normal;

				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Albedo;

			sampler2D _EmissionTex;
			float4 _EmissionTex_ST;
			fixed4 _Emission;

			fixed4 _LightColor;
			fixed4 _LightDir;

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

				fixed4 EmiTex = tex2D(_EmissionTex, TRANSFORM_TEX(i.uv, _EmissionTex));
				fixed3 emiss = EmiTex.rgb * _Emission.rgb;
				c.rgb = albedo * lm + lerp(albedo, emiss, _Emission.a);

				//辅助光(固定)
				{
					float dot_v = max(0, dot(_LightDir, i.normal));
					c.rgb += dot_v * _LightColor.rgb * 0.25 * _LightColor.a;
				}

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
