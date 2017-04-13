Shader "MW/SimpleWater"
{
	Properties
	{
		_NormalTex("Normal Tex", 2D) = "white" {}
		_NormalTile("Normal Tile", float) = 1

		_MainColor("Main Color", Color) = (1,1,1,1)

		_VerticalSpeed("Vertical Speed", Range(0.0, 2.0)) = 0.4
		_HorizontalSpeed("Horizontal Speed", Range(0.0, 2.0)) = 0.1
		//_LightColor("Light Color", Color) = (1,1,1,1)
		//_LightDir("LightDir", Vector) = (-300,500,-250,0)
		//
		_HightLightColor("HighLightColor", Color) = (1,1,1,1)
		_HightLightDir("HightLightDir", Vector) = (-300,500,-250,0)

		_WaterAlpha("Water Alpha", Range(0.0, 1.0)) = 0.7
		[NoScaleOffset]_RefractTex("Refraction Texture", Cube) = "" {}  
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _NormalTex;
		float _NormalTex_ST;
		fixed _NormalTile;
		fixed _VerticalSpeed;
		fixed _HorizontalSpeed;
		fixed _WaterAlpha;
		fixed4 _MainColor;

		samplerCUBE _RefractTex;

		half4 _HightLightDir;
		fixed4 _HightLightColor;

		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 tex_uv: TEXCOORD0;
			UNITY_FOG_COORDS(1)
			float3 viewDir: TEXCOORD2;
		}; 
		//写死切线方向
		v2f vert(appdata_base v)
		{
			v2f o;
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);  
			o.viewDir = ObjSpaceViewDir(v.vertex);
			o.tex_uv.xy = v.texcoord; 
			//o.tex_uv.z = v.color.a;
            return o; 
		}
			
		fixed4 frag (v2f i) : SV_Target
		{
			//refraction
			//直接当object space normal来使用 因为水是平面(取巧)
			half2 NormalUV = i.tex_uv.xy * _NormalTile;
			half2 TempUV;
			TempUV.x = NormalUV.x * 5 + _Time.x * _VerticalSpeed;
			TempUV.y = NormalUV.y * 5 + _Time.x * _HorizontalSpeed;
			half3 NormalTex1 = UnpackNormal(tex2D(_NormalTex, TempUV.xy));
			//half3 NormalTex1 = UnpackNormal(tex2D(_NormalTex, NormalUV.xy * 5 + _Time.xx * _VerticalSpeed));
			TempUV.x = NormalUV.x * 5 - _Time.x * _VerticalSpeed;
			TempUV.y = NormalUV.y * 5 - _Time.x * _HorizontalSpeed;
			half3 NormalTex2 = UnpackNormal(tex2D(_NormalTex, TempUV.yx * 5 - _Time.xx * 0.1));
			half3 NormalTex = (NormalTex1 + NormalTex2) * 0.5;
			//half3 NormalTex = UnpackNormal(tex2D(_NormalTex, NormalUV.yx));
			half3 ref_dir = reflect(i.viewDir, normalize(half3(NormalTex.x, NormalTex.z, NormalTex.y))); 
			ref_dir = mul(_Object2World, float4(ref_dir,0));
            half3 refraction = texCUBE(_RefractTex, ref_dir).rgb * 2 - 1;

			return half4(refraction.rgb * _MainColor.rgb , _WaterAlpha);//+  
        }

		fixed4 fragHighLight(v2f i) : SV_Target
		{
			//refraction
			//直接当object space normal来使用 因为水是平面(取巧)
			half2 NormalUV = i.tex_uv.xy * _NormalTile;
			half3 NormalTex1 = UnpackNormal(tex2D(_NormalTex, NormalUV.xy * 10 + _Time.xx * 0.2));
			half3 NormalTex2 = UnpackNormal(tex2D(_NormalTex, NormalUV.yx * 10 - _Time.xx * 0.2));
			half3 NormalTex = (NormalTex1 + NormalTex2) * 0.5;
			//light
			half dot_l = clamp(dot(normalize(_HightLightDir.rgb), normalize(NormalTex)), 0, 1);
			half3 highLight = dot_l * _HightLightColor.rgb;

            return half4(highLight, dot_l); 
        }
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Transparent" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
            //ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			ENDCG
		}

		Pass
		{
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragHighLight
			#pragma multi_compile_fog
			ENDCG
		}
	}
}
