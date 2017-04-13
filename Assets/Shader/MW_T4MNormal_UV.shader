Shader "MW/T4MNormal_UV" 
{
	Properties {

		_Splat1("Layer1", 2D) = "white" {}
		_Splat2("Layer2", 2D) = "white" {}
		_Splat3("Layer3", 2D) = "white" {}
		_Splat4("Layer4", 2D) = "white" {}

		_BumpSplat("LayerNormalmap", 2D) = "bump" {}
		
		_Tiling("Tiling x/y", Vector)=(1,1,0,0)
		
		_UseDirectionNormal("------------>>>>> UseDirectionNormal", Int) = 1
		_LightColor("Light Color", Color)         = (1, 0.51, 0, 1.0)
		//_DNormalPower("DirectionNormalPower", Vector)=(10,50,10,10)
		_LightDir("DirectLightDir", Vector)=(-100,-228,332,1)
		_NormalGloss("NormalGloss", float) = 30
		_NormalPower("NormalPower", float) = 0.4

		_UsePtLightNormal("------------>>>>> UsePtLightNormal", Int) = 1
		_PtNormalPower("PtNormalPower", Vector)=(2.66,-3.89,1.73,0)

		_Control ("Control (RGBA)", 2D) = "white" {}
	}
                
	SubShader 
	{
		Tags {
			"Queue" = "Geometry-100"
			"SplatCount" = "4"
			"RenderType" = "Opaque"
		}
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma target 3.0

			#include "UnityCG.cginc"

			struct v2f{
				float4 sv_pos: SV_POSITION;
				float4 uv_cl: TEXCOORD0;
				UNITY_FOG_COORDS(1) 
				float3 posWorld:TEXCOORD2;
			};

			fixed3 _LightDir;

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			v2f vert (appdata_t v){
				v2f o;

				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				UNITY_TRANSFER_FOG(o,o.sv_pos);
				o.uv_cl.xy = v.texcoord.xy;
				o.uv_cl.zw = v.texcoord1.xy;
				o.posWorld = mul(_Object2World, v.vertex);

				//切线空间的视角方向
				//TANGENT_SPACE_ROTATION;
				//o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				//float3 ObjLightDir = mul((fixed3x3)_World2Object, normalize(_LightDir));
				//o.lightDir = mul(rotation, ObjLightDir);

				return o;
			}

			sampler2D _Control;
			sampler2D _Splat1, _Splat2, _Splat3, _Splat4;
			sampler2D _BumpSplat;

			sampler2D _Environment_Tex2D;
			float _Environment_Tex2D_Tiling;

			fixed4 _Tiling;
			//fixed4 _DNormalPower;
			fixed4 _LightColor;
			int _UseDirectionNormal;
			float _NormalGloss;
			float _NormalPower;

			struct fragOuput{
				fixed4 color : SV_Target;
			};

			inline half3 Unity_SafeNormalize(half3 inVec)
			{
				half dp3 = max(0.001f, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}

 			fragOuput frag(v2f IN): SV_Target
			{
				fragOuput o;
				fixed4 c= fixed4(0,0,0,0);

				//混合贴图
				fixed4 splat_control = tex2D (_Control, IN.uv_cl.xy).rgba;	

				half2 uv_1 = IN.uv_cl.xy * _Tiling.x;		half2 uv_1b = uv_1 % 1 / 2;		uv_1b = half2(uv_1b.x,		uv_1b.y+0.5);
				half2 uv_2 = IN.uv_cl.xy * _Tiling.y;		half2 uv_2b = uv_2 % 1 / 2;		uv_2b = half2(uv_2b.x+0.5,	uv_2b.y+0.5);
				half2 uv_3 = IN.uv_cl.xy * _Tiling.z; 		half2 uv_3b = uv_3 % 1 / 2; 	uv_3b = half2(uv_3b.x,		uv_3b.y);
				half2 uv_4 = IN.uv_cl.xy * _Tiling.w;		half2 uv_4b = uv_4 % 1 / 2;		uv_4b = half2(uv_4b.x+0.5,	uv_4b.y);
		
				fixed3 lay1 = tex2D(_Splat1, uv_1).rgb;
				fixed3 lay2 = tex2D(_Splat2, uv_2).rgb;
				fixed3 lay3 = tex2D(_Splat3, uv_3).rgb;
				fixed3 lay4 = tex2D(_Splat4, uv_4).rgb; 

				c.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);

				//固定方向法线效果
				if(_UseDirectionNormal == 1) 
				{
					//目前最多2张法线
					float3 lay1B = UnpackNormal(tex2D(_BumpSplat, uv_1b));
					float3 lay2B = UnpackNormal(tex2D(_BumpSplat, uv_2b));
					float3 lay3B = UnpackNormal(tex2D(_BumpSplat, uv_3b));
					float3 lay4B = UnpackNormal(tex2D(_BumpSplat, uv_4b));
					//float3 normal = lay1B * splat_control.r* _DNormalPower.x + lay2B * splat_control.g* _DNormalPower.y + lay3B * splat_control.b* _DNormalPower.z + lay4B * splat_control.a* _DNormalPower.w;
					float3 normal = lay1B * splat_control.r + lay2B * splat_control.g + lay3B * splat_control.b + lay4B * splat_control.a;
					normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));

					//------------------------------//
					//随视角方向法线效果
					fixed3 color = _LightColor.rgb;

					fixed3 lightDir = _LightDir.xyz - IN.posWorld.xyz;
					fixed3 viewDir = normalize(_WorldSpaceCameraPos - IN.posWorld.xyz);

					//1) 2(n*l)n -l (据说在viewdir变化的情况下 这种算式更快)
					float dot_l = dot(normalize(lightDir), normalize(normal));  
					fixed3 refl = 2*dot_l*normalize(normal)-(normalize(lightDir));
					float dot_r = dot(normalize(refl), normalize(viewDir));

					//错误的做法 normal是切线空间的 而lightdir和viewdir是世界空间的 这么处理是不真实的
					//* 如果都转到切线空间 viewDir插值成frag之后会有奇怪尖锐的边缘数值跨越 暂时不知道怎么解决
					//* 如果normal转到世界空间做 要在v2f中保存转制矩阵数据 需要3个TEXCOORD 放不下那么多了
					//* 所以目前用这种错误的法线 所幸看起来效果还可以

					//2) h = v + l  -->  h * n
					//float3 half = normalize(lightDir) + normalize(viewDir);
					//float dot_r = dot(normalize(half), normalize(normal));

					fixed3 spec = color * pow(max(dot_r, 0), _NormalGloss) * _NormalPower;   
					c.rgb += spec;
				}

				//环境光
				//c.rgb += _LightColor.xyz * 0.2;

				//光照贴图
				float2 uv_Lightmap = IN.uv_cl.zw * unity_LightmapST.xy + unity_LightmapST.zw;
				c.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uv_Lightmap));

				//UV动画
				fixed4 uvAni = tex2D(_Environment_Tex2D, IN.uv_cl * _Environment_Tex2D_Tiling);
				c.rgb += uvAni * 0.2f;

				//fog颜色处理
				UNITY_APPLY_FOG(IN.fogCoord, c);

				o.color = c;
				return o; 
			}
			ENDCG
		}
	}
//Fallback "Diffuse"
}
