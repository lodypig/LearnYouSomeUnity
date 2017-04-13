Shader "MW/AreaMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		//这个shader用于UI 不加这下面这些会报错		by linh
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255
		_ColorMask ("Color Mask", Float) = 15
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{ 
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _miniMapInfo;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 finalUV = _miniMapInfo.xy + i.uv * _miniMapInfo.zw;
				fixed4 col = tex2D(_MainTex, finalUV);
				fixed filter = max(1 - finalUV.x, 0) * max(1 - finalUV.y, 0);
				if(filter == 0)
				{
					col = fixed4(0,0,0,0);
				}
				return col;
			}
			ENDCG
		}
	}
}
