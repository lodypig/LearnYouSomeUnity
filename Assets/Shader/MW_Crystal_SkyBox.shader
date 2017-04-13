Shader "MW/Crystal_Skybox"  
{  
    Properties {  
        _MainTex ("MainTex", 2D) = "white" {}
		_UVAniTex ("UVAniTex", 2D) = "white" {}

		_RimLight ("Rim Light", Color) = (1,1,1,1)
		//_RimPower("Rim Light Power", float) = 1

		_LightDir("Light Dir", vector) = (3.27,-4.01,7.68,0)
		_LightPower("High Light Power", float) = 1
		_LightColor("UV Light Color", Color) = (0,0.419,1,1)

        _Emission ("Emission", Range(0.0,2.0)) = 0.9
		_FlowSpeed("FlowSpeed", float) = 3.0
        [NoScaleOffset] _RefractTex ("Refraction Texture", Cube) = "" {}  
    }  

	CGINCLUDE
		#include "UnityCG.cginc"  
	        struct v2f {  
                float4 pos : SV_POSITION;  
				float4 tex_uv:TEXCOORD0;  
                float3 uv : TEXCOORD1;  

            };  
  
			fixed _FlowSpeed;
			fixed _LightPower;
			//fixed _RimPower;

			float4 _LightDir;
			fixed4 _LightColor;
            v2f vert (appdata_base v)  
            {  
                v2f o;  
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);  
  
                // TexGen CubeReflect:  
                // reflect view direction along the normal, in view space.  
				float3 _viewDir = ObjSpaceViewDir(v.vertex);
				float3 viewDir = _viewDir;  
				//viewDir.x += _SinTime.w * _FlowSpeed;
				//viewDir.z += _CosTime.w * _FlowSpeed;
				viewDir = normalize(viewDir);
                o.uv = -reflect(viewDir, v.normal);  
                o.uv = mul(_Object2World, float4(o.uv,0)); 
				o.tex_uv.xy = v.texcoord;
				fixed dot1 = dot(_viewDir, v.normal);
				//float deltaT = _Time.z * 10 % 5;
				//+ float4(deltaT, deltaT, 0, 0)
				fixed3 ld = _LightDir;
				//ld.x += _SinTime.w * _FlowSpeed;
				//ld.z += _CosTime.w * _FlowSpeed;
				fixed dot_dir = dot(normalize(ld), normalize(v.normal));
				o.tex_uv.z = pow(clamp(dot_dir, 0, 1), _LightPower);
				//o.tex_uv.w = pow(clamp(1 - dot1, 0, 1), _RimPower);
				o.tex_uv.w = clamp(1 - dot1, 0, 1);
                return o;  
            }  
  
            sampler2D _MainTex;
			sampler2D _UVAniTex;
			fixed4 _HighLight;
			fixed4 _RimLight;
            samplerCUBE _RefractTex;  
            half _EnvironmentLight;  
            half _Emission;  

            half4 fragBack(v2f i) : SV_Target    
            {  
				//refraction
				half3 MainColor = tex2D(_MainTex, i.tex_uv.xy).rgb;// + fixed3(0,0,1) * i.tex_uv.x;
                half3 refraction = texCUBE(_RefractTex, i.uv).rgb * MainColor;
				//half3 refraction = lerp(texCUBE(_RefractTex, i.uv).rgb, MainColor, 0.3) ;
				//hightlight
				//float hl_dot = i.tex_uv.z;
				//half3 hl_color = hl_dot * _HighLight.rgb * _HighLight.a;
			
				float rm_dot = i.tex_uv.w;
			
                return half4(refraction.rgb * _Emission, 1.0f);
            }

			half4 fragFront(v2f i) : SV_Target    
            {  
				//refraction
				fixed2 uv_xy = i.tex_uv.xy;
				half3 MainColor = tex2D(_MainTex, uv_xy).rgb;// + fixed3(0,0,1) * i.tex_uv.x;
                half3 refraction = texCUBE(_RefractTex, i.uv).rgb * MainColor;
				//half3 refraction = lerp(texCUBE(_RefractTex, i.uv).rgb, MainColor, 0.3) ;
				//hightlight
				//float hl_dot = i.tex_uv.z;
				//half3 hl_color = hl_dot * _HighLight.rgb * _HighLight.a;

				float rm_dot = i.tex_uv.w;
				half3 rm_color = rm_dot * lerp(refraction.rgb, _RimLight.rgb, _RimLight.a);

				float lg_dot = i.tex_uv.z;
				half3 lg_color = lg_dot * _LightColor.rgb * _LightColor.a;

				//uv动画效果
				fixed2 ani_uv = uv_xy * 2;
				ani_uv.y -= _Time.x * _FlowSpeed;
				half3 UVAniColor = tex2D(_UVAniTex, ani_uv).rgb * 0.8;

                return half4(refraction.rgb * _Emission + (refraction.rgb * 0.5 + rm_color + lg_color) * UVAniColor , rm_dot * 2 + 0.5f); //rm_dot * 2);
            }
	ENDCG

    SubShader {  
        Tags {  
            "Queue" = "Transparent"  
        }  

        //Pass {
		//	Cull Front
		//	ZWrite Off
        //    CGPROGRAM
        //    #pragma vertex vert  
        //    #pragma fragment fragBack  
        //    ENDCG
        //}
		//
		//Pass {		
		//	ZWrite On
		//	Blend SrcAlpha OneMinusSrcAlpha
        //    CGPROGRAM  
        //    #pragma vertex vert  
        //    #pragma fragment fragFront     
        //    ENDCG
        //}

		Pass {		
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment fragFront     
            ENDCG
        }
      }  
}  
