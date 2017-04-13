Shader "MW/NPC"{
    Properties {
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _Cutoff ("Base Alpha cutoff", Range (0,.9)) = .5
		_MixPower ("Mix Power", Range(0,.9)) = 0
		_MixColor ("Mix Color", Color) = (1,1,1,1)
		_RimColor ("Rim Color", Color) = (1,0.43,0,1)
		_RimPower ("Rim Power", float) = 1.3
		_RimStrength ("Rim Strength", float) = 0

		//_LightColor("Light Color", Color)         = (1, 0.3, 0, 1.0)
		//_LightDir("DirectLightDir", Vector)		  = (-1.9,0.02,0.33,0)
    }
    SubShader {
		Tags 
		{
			"Queue" = "Geometry+20"
		}
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog	

			#include "UnityCG.cginc"

			struct v2f{
				fixed4 sv_pos: SV_POSITION;
				fixed4 uv: TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 normal:TEXCOORD2;
				float3 viewDir:TEXCOORD3;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.sv_pos);
				o.uv = v.texcoord;
				o.normal = v.normal;
				o.viewDir = ObjSpaceViewDir(v.vertex).xyz;
				return o;
			}
			 
			sampler2D _MainTex;
			fixed _Cutoff;
			fixed _MixPower;
			fixed4 _MixColor;
			fixed4  _RimColor;
			fixed _RimPower;
			fixed _RimStrength;

			//fixed4 _LightColor;
			//fixed4 _LightDir;

			struct fragOuput{
				fixed4 color : SV_Target;
			};

			fragOuput frag(v2f i): SV_Target
			{
				fragOuput o;
				fixed4 c = tex2D(_MainTex, i.uv);

				if(c.a < _Cutoff)
				{
					discard;
				}

				//灰度值
				fixed gray = dot(c.rgb, fixed3(0.3, 0.6, 0.1));

				//环境光处理(强)
				c.rgb +=  UNITY_LIGHTMODEL_AMBIENT.xyz * gray.r * 0.1;

				//fog颜色处理
				UNITY_APPLY_FOG(i.fogCoord, c);

				//自定义混合色处理
				c.rgb += gray.r * _MixColor.rgb * 2 * _MixPower;

				////辅光(固定)
				//{
				//	float dot_v = max(0, dot(_LightDir, i.normal));
				//	c.rgb += dot_v * _LightColor.rgb * 0.25 * _LightColor.a;
				//}

				//边缘高亮
				fixed dot_v = dot(i.normal, normalize(i.viewDir));
				c.rgb += _RimColor * pow(saturate(1 - dot_v), _RimPower) * 1.5f * _RimStrength;

				o.color = c;

				return o;
			}

			ENDCG
		}
    }
}
