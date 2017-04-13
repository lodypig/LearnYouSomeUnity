Shader "MW/EffectUV" {
    Properties {
        _Tex1 ("Tex1", 2D) = "white" {}
        _Tex2 ("Tex2", 2D) = "white" {}
        _Tex3 ("Tex3", Color) = (0.5,0.5,0.5,1)
        _Tex4 ("Tex4", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform sampler2D _Tex1; uniform float4 _Tex1_ST;
            uniform sampler2D _Tex2; uniform float4 _Tex2_ST;
            uniform float4 _Tex3;
            uniform sampler2D _Tex4; uniform float4 _Tex4_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR
			{
                float4 Time = _Time;
                float2 uv1 = (i.uv0+Time.g*float2(0,-0.4));
                float4 _Tex1_var = tex2D(_Tex1,TRANSFORM_TEX(uv1, _Tex1));
                float2 uv2 = (i.uv0+Time.g*float2(0,-0.5));
                float4 _Tex2_var = tex2D(_Tex2,TRANSFORM_TEX(uv2, _Tex2));
                float4 _Tex4_var = tex2D(_Tex4,TRANSFORM_TEX(i.uv0, _Tex4));
                float3 emissive = ((((_Tex1_var.r*_Tex2_var.r)*5.0)*_Tex3.rgb)*_Tex4_var.r);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}
