Shader "MW/Player" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
		_MixPower ("_Mix Power", Range(0,.9)) = 0
		_MixColor ("_Mix Color", Color) = (0,0,0,1)			//(1,1,1,1)
		_TransparentColor ("_Transparent Color", Color) = (0,0.42,1,1)
		_StencilTex("StencilTex", 2D) = "white"{}
		_StencilColor("StencilColor", Color) = (1,1,1,1)

		_LightColor("Light Color", Color) =	(0,0,0,1)			//(1,0.72,0,1)
		_LightDir("LightDir", Vector) = (-300,500,-250,0)
		_LightPower("LightPower", Int) = 40
		_LightAtten("LightAtten", float) = 0.4
    }
    SubShader {
		//遮挡显示	
		Pass
		{
			Tags 
			{
				"Queue" = "Geometry+1"
			}
			Blend SrcAlpha One
			ZWrite off
			ZTest off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			fixed4 _TransparentColor;
			
			struct appdata_t {
				fixed4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
				fixed4 color:COLOR;
				fixed4 normal:NORMAL;
			};

			struct v2f {
				fixed4  pos : SV_POSITION;
				fixed2 uv: TEXCOORD0;
				fixed4	color:COLOR;
			} ;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				fixed rim = 1 - saturate(dot(normalize(viewDir),normalize(v.normal) ));
				o.color = _TransparentColor * pow(rim,0.2);
				o.uv = v.texcoord;
					
				return o;
			}

			sampler2D _MainTex; 

			fixed4 frag (v2f i) : COLOR
			{
				return i.color; 
			}
			ENDCG
		}

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
			fixed	_MixPower;
			fixed4	_MixColor;
			fixed4	_TransparentColor;

			fixed4	_LightColor;
			float4	_LightDir;
			float	_LightAtten;
			int		_LightPower;

			sampler2D _StencilTex;
			fixed4  _StencilColor;

			struct fragOuput{
				fixed4 color : SV_Target;
			};

			fragOuput frag(v2f i): SV_Target
			{
				fragOuput o;
				fixed4 c = tex2D(_MainTex, i.uv) * 1.1;

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

				//辅光
				float3 lightDir = _LightDir.xyz;// - i.posWorld.xyz;
				float dot_l = dot(normalize(lightDir), normalize(i.normalWorld));  
				c.rgb += _LightColor * pow(saturate(dot_l), _LightPower) * _LightAtten;

				//漏字板
				fixed _stencil = tex2D(_StencilTex, i.uv).r;
				c.rgb = lerp(c.rgb, c.rgb * _StencilColor.rgb * _StencilColor.a, _stencil);
				//c.rgb = c.rgb * (1 - _stencil) + _stencil * c.rgb * _StencilColor.rgb * _StencilColor.a;

				o.color = c;
				o.color.a = _TransparentColor.a;
				return o;
			}

			ENDCG
		}
    }
}
