Shader "MW/wave_grass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CycleTime ("Cycle Time", float) = 1
		_OffsetX ("Offset X", float) = 1
		_OffsetY ("Offset Y", float) = 0.25
		_Alpha ("Alpha", range(0,1)) = 0.3
		_Albedo("Albedo Color", Color) = (0.5,0.5,0.5,0.5)
		_Emission("Emission", Color) = (0.5,0.5,0.5,0.5)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2: TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				fixed2 uv_Lightmap : TEXCOORD2;	 
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _CycleTime;
			float _OffsetX;
			float _OffsetY;
			float _Alpha;
			fixed4 _Albedo;
			fixed4 _Emission;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float t = _Time.y + o.vertex.y * _OffsetY;
				o.vertex.x += o.uv.y * ((t % _CycleTime)/_CycleTime - 0.5) * _OffsetX * (floor(t/_CycleTime) % 2 - 0.5) * 2;
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.uv_Lightmap = v.uv2;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				if(col.a < _Alpha)
				{
					discard;
				}
				//lightmap
				fixed2 uv_Lightmap = i.uv_Lightmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv_Lightmap));
				fixed3 albedo = col.rgb * _Albedo.rgb * _Albedo.a;
				fixed3 emiss = col.rgb * _Emission.rgb;
				col.rgb = albedo * lm + lerp(albedo, emiss, _Emission.a);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
