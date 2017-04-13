Shader "MW/PlayerAlpha" {
    Properties {
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _Cutoff ("Base Alpha cutoff", Range (0,.9)) = 0.5
		_MixPower ("_Mix Power", Range(0,.9)) = 0
		_MixColor ("_Mix Color", Color) = (0,0,0,1)			//(1,1,1,1)
		_GlossColor("Gloss Color", Color) = (0,0,0,1)		//(0.5,0.83,1, 1)
		_RimColor("Rim Color", Color) = (0,0,0,1)
		_TransparentColor ("_Transparent Color", Color) = (0,0.42,1,1)

		_LightColor("Light Color", Color) =	(0,0,0,1)			//(1,0.72,0,1)
		_LightDir("LightDir", Vector) = (-300,500,-250,0)
		_LightPower("LightPower", Int) = 40
		_LightAtten("LightAtten", float) = 0.4

		//_TopLightDir("Top Light Dir", Vector) = (0,0,0,0)  
    }
    SubShader {
		//普通显示
		Pass{
			Tags 
			{
				"Queue" = "Geometry+11"
			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct v2f{
				fixed4 sv_pos: SV_POSITION;
				fixed4 uv: TEXCOORD0;
				UNITY_FOG_COORDS(1)
				//rim  
				float3 posWorld: TEXCOORD2;     
				float3 normalWorld : TEXCOORD3;  
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.sv_pos);
				o.uv = v.texcoord;
				//
				o.posWorld = mul(_Object2World, v.vertex);
				o.normalWorld = mul((float3x3)_Object2World, v.normal);  
				//
				return o;
			}
			 
			sampler2D _MainTex;
			fixed	_Cutoff;
			fixed	_MixPower;
			fixed4	_MixColor;
			fixed4	_GlossColor;
			fixed4  _RimColor;
			fixed4	_TransparentColor;

			fixed4	_LightColor;
			float4	_LightDir;
			float	_LightAtten;
			int		_LightPower;

			//half4  _TopLightDir;

			struct fragOuput{
				fixed4 color : SV_Target;
			};

			fragOuput frag(v2f i): SV_Target
			{
				fragOuput o;
				fixed4 c = tex2D(_MainTex, i.uv) * 1.1;

				if(c.a < _Cutoff)
				{
					discard;
				}

				//顶光强弱控制
				//fixed3 TopLightDir = _TopLightDir.xyz - i.posWorld.xyz;
				//fixed TopSumAtten = dot(normalize(TopLightDir), normalize(i.normalWorld));
				//TopSumAtten = (0.5 + TopSumAtten * 0.5);
				//c.rgb *= TopSumAtten;

				//灰度值
				fixed gray = dot(c.rgb, fixed3(0.3, 0.6, 0.1));

				//提亮
				c.rgb += c.rgb * gray.r * 0.04;

				//环境光处理(微弱)
				//c.rgb +=  UNITY_LIGHTMODEL_AMBIENT.xyz * 0.5;

				//fog颜色处理
				UNITY_APPLY_FOG(i.fogCoord, c);

				//自定义混合色处理
				if (_MixPower > 0)
				{
					c.rgb += gray.r * _MixPower * _MixColor.rgb * 2;
				}

				//光泽
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				fixed dot_v = dot(normalize(viewDir), normalize(i.normalWorld));
				fixed rim = max(0.1, min(0.8, dot_v));  
				c.rgb += _GlossColor.rgb * pow(rim, 8.0f);   

				//边缘高亮
				c.rgb += _RimColor * pow(clamp(1 - dot_v, 0, 1), 9.0f) * 0.6f;

				//辅光
				float3 lightDir = _LightDir.xyz;// - i.posWorld.xyz;
				float dot_l = dot(normalize(lightDir), normalize(i.normalWorld));  
				c.rgb += _LightColor * pow(saturate(dot_l), _LightPower) * _LightAtten;

				o.color = c;
				o.color.a = _TransparentColor.a;
				return o;
			}

			ENDCG
		}
    }
}
