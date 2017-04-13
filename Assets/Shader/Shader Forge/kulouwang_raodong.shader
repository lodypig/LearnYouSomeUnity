Shader "Shader Forge/kulouwang_raodong 01" {
    Properties {
        _node_6595 ("node_6595", 2D) = "white" {}
        _node_4686 ("node_4686", Color) = (0.5,0.5,0.5,1)
        _Qiangdu ("Qiangdu", Float ) = 10
        _Niuqu ("Niuqu", Range(0, 1)) = 0
        _Goubiansize ("Goubian/size", Float ) = 0.1
        _node_1342 ("node_1342", 2D) = "white" {}
        _Goubianqiangdu ("Goubianqiangdu", Float ) = 100
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        GrabPass{ }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform sampler2D _GrabTexture;
            uniform float _Goubiansize;
            uniform sampler2D _node_6595; uniform float4 _node_6595_ST;
            uniform sampler2D _node_1342; uniform float4 _node_1342_ST;
            uniform float4 _node_4686;
            uniform float _Qiangdu;
            uniform float _Goubianqiangdu;
            uniform float _Niuqu;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float3 tangentDir : TEXCOORD2;
                float3 bitangentDir : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( _Object2World, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.screenPos = o.pos;
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.normalDir = normalize(i.normalDir);
                i.screenPos = float4( i.screenPos.xy / i.screenPos.w, 0, 0 );
                i.screenPos.y *= _ProjectionParams.x;
                float4 _node_6595_var = tex2D(_node_6595,TRANSFORM_TEX(i.uv0, _node_6595));
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + ((_node_6595_var.rgb.rg*i.vertexColor.a)*(_Niuqu*0.1));
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 normalLocal = lerp(float3(0,0,0),float3(_node_6595_var.a,_node_6595_var.a,_node_6595_var.a),_Niuqu);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 emissive = ((_Qiangdu*(_node_4686.rgb*_node_6595_var.rgb))*_node_6595_var.r);
                float3 finalColor = emissive;
                float4 _node_1342_var = tex2D(_node_1342,TRANSFORM_TEX(i.uv0, _node_1342));
                float node_3620_if_leA = step((_Goubiansize+i.vertexColor.r),_node_1342_var.r);
                float node_3620_if_leB = step(_node_1342_var.r,(_Goubiansize+i.vertexColor.r));
                float node_52 = 0.0;
                float node_2494 = 1.0;
                float node_3620 = lerp((node_3620_if_leA*node_52)+(node_3620_if_leB*node_2494),node_2494,node_3620_if_leA*node_3620_if_leB);
                float node_1014_if_leA = step(i.vertexColor.r,_node_1342_var.r);
                float node_1014_if_leB = step(_node_1342_var.r,i.vertexColor.r);
                return fixed4(lerp(sceneColor.rgb, finalColor,((_node_6595_var.a*(node_3620+((node_3620-lerp((node_1014_if_leA*node_52)+(node_1014_if_leB*node_2494),node_2494,node_1014_if_leA*node_1014_if_leB))*_Goubianqiangdu)))*i.vertexColor.a)),1);
            }
            ENDCG
        }
    }
}
