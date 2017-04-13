Shader "MW/Lava Glow" {
    Properties {
        _BaseTextureRGBA ("Base Texture (RGBA)", 2D) = "gray" {}
        _DistortTexture ("Distort Texture", 2D) = "white" {}
        _Color1 ("Color1", Color) = (0.4411765,0.2099391,0,1)
        _Color2 ("Color2", Color) = (0.9568627,0.8509804,0,1)
        _Emission ("Emission", Range(0, 1)) = 0.8
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fog
            #pragma target 3.0

            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _DistortTexture; uniform float4 _DistortTexture_ST;
            uniform float4 _Color1;
            uniform sampler2D _BaseTextureRGBA; uniform float4 _BaseTextureRGBA_ST;
            uniform float4 _Color2;
            uniform float _Emission;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(_Object2World, v.vertex);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
/////// Diffuse:
                float3 black = float3(0,0,0);
                float2 pos_Data = (float2(i.posWorld.r,i.posWorld.b)*0.2);
                float2 UV1 = (pos_Data*0.08)+_Time.g*float2(0.007,0.007);
                float2 UV2 = (pos_Data*0.7)+_Time.g*float2(0.015,0.015);
                float2 baseUV = (pos_Data+_Time.g*float2(0.005,-0.01));
                float4 UV1_Color = tex2D(_DistortTexture,TRANSFORM_TEX(UV1, _DistortTexture));
                float4 UV2_Color = tex2D(_DistortTexture,TRANSFORM_TEX(UV2, _DistortTexture));
                float4 base_Color = tex2D(_BaseTextureRGBA,TRANSFORM_TEX(baseUV, _BaseTextureRGBA));
				float3 value1 = lerp(black,(_Color2.rgb/(_SinTime.g*-0.2+0.8)),UV1_Color.r) + saturate((_Color1.rgb*(UV2_Color.r+UV2_Color.b)*2));
				float3 value2 = ((float3(0.2,0.05,0.05)/(_SinTime.g*-0.2+0.8))*base_Color.rgb);
                float3 mix_Color = lerp(value1, value2, base_Color.a) + base_Color.rgb;
                float3 diffuse = UNITY_LIGHTMODEL_AMBIENT.rgb * mix_Color;
/// Emissive:
                float3 emissive = lerp(black, mix_Color, _Emission);
/// Final Color:
                float3 finalColor = diffuse + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
   }
    CustomEditor "ShaderForgeMaterialInspector"
}
