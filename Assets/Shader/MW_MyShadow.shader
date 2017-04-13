Shader "MW/MyShadow"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
	}
	
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"DisableBatching" = "True" 
		}
		
		Pass
		{
			//Cull Off
			//Lighting Off
			ZWrite Off
			ZTest Off
			//Fog { Mode Off }
			//Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	

			sampler2D _MainTex;
			float4 _MainTex_ST;
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f
			{
				float4 sv_pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.sv_pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				return o;
			}
				
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 xy = fixed2(1-i.uv.x, 1-i.uv.y);
				fixed4 texS = tex2D(_MainTex, xy);
				fixed c = 1 - ceil(texS.r);
				return fixed4(c, c, c, (1 - c) * 0.6);
			}
			ENDCG
		}
	}
}
