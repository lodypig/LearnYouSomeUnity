// Shader created with Shader Forge v1.16 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.16;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:3138,x:35942,y:32892,varname:node_3138,prsc:2|normal-511-OUT,emission-4761-OUT,alpha-2185-OUT,refract-6517-OUT;n:type:ShaderForge.SFN_Tex2d,id:2178,x:33185,y:32602,ptovrint:False,ptlb:node_2178,ptin:_node_2178,varname:node_2178,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:1201219a7a260e445849c8279393cb99,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:1437,x:32932,y:33163,ptovrint:False,ptlb:node_1437,ptin:_node_1437,varname:node_1437,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:ba20e8e97529a9b4e8da5e4e1c0747ee,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7237,x:33393,y:32495,varname:node_7237,prsc:2|A-4145-RGB,B-2178-RGB;n:type:ShaderForge.SFN_Color,id:4145,x:33163,y:32385,ptovrint:False,ptlb:node_4145,ptin:_node_4145,varname:node_4145,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:9559,x:33592,y:32449,varname:node_9559,prsc:2|A-7243-OUT,B-7237-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7243,x:33381,y:32325,ptovrint:False,ptlb:node_7243,ptin:_node_7243,varname:node_7243,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:10;n:type:ShaderForge.SFN_Multiply,id:4761,x:33945,y:32546,varname:node_4761,prsc:2|A-9559-OUT,B-2178-R;n:type:ShaderForge.SFN_If,id:1565,x:33561,y:33065,varname:node_1565,prsc:2|A-3713-OUT,B-1437-R,GT-4531-OUT,EQ-4531-OUT,LT-9065-OUT;n:type:ShaderForge.SFN_VertexColor,id:6250,x:32942,y:32913,varname:node_6250,prsc:2;n:type:ShaderForge.SFN_Add,id:3713,x:33220,y:32849,varname:node_3713,prsc:2|A-5197-OUT,B-6250-R;n:type:ShaderForge.SFN_ValueProperty,id:5197,x:32942,y:32835,ptovrint:False,ptlb:node_5197,ptin:_node_5197,varname:node_5197,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.1;n:type:ShaderForge.SFN_Vector1,id:4531,x:32932,y:33391,varname:node_4531,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:9065,x:33034,y:33615,varname:node_9065,prsc:2,v1:0;n:type:ShaderForge.SFN_If,id:6881,x:33609,y:33492,varname:node_6881,prsc:2|A-6250-R,B-1437-R,GT-4531-OUT,EQ-4531-OUT,LT-9065-OUT;n:type:ShaderForge.SFN_Subtract,id:964,x:33964,y:33208,varname:node_964,prsc:2|A-1565-OUT,B-6881-OUT;n:type:ShaderForge.SFN_Multiply,id:4974,x:34319,y:33198,varname:node_4974,prsc:2|A-964-OUT,B-7234-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7234,x:34063,y:33352,ptovrint:False,ptlb:node_7234,ptin:_node_7234,varname:node_7234,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:100;n:type:ShaderForge.SFN_Slider,id:6356,x:33938,y:33533,ptovrint:False,ptlb:node_6356,ptin:_node_6356,varname:node_6356,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:2;n:type:ShaderForge.SFN_Multiply,id:5764,x:34495,y:33778,varname:node_5764,prsc:2|A-6356-OUT,B-42-OUT;n:type:ShaderForge.SFN_Vector1,id:42,x:34121,y:33795,varname:node_42,prsc:2,v1:0.1;n:type:ShaderForge.SFN_Add,id:1304,x:34553,y:33111,varname:node_1304,prsc:2|A-1565-OUT,B-4974-OUT;n:type:ShaderForge.SFN_Multiply,id:6785,x:34945,y:32975,varname:node_6785,prsc:2|A-2178-A,B-1304-OUT;n:type:ShaderForge.SFN_Multiply,id:2185,x:35361,y:33050,varname:node_2185,prsc:2|A-6785-OUT,B-6250-A;n:type:ShaderForge.SFN_Multiply,id:6527,x:34789,y:33570,varname:node_6527,prsc:2|A-822-OUT,B-6250-A;n:type:ShaderForge.SFN_Lerp,id:511,x:35222,y:33397,varname:node_511,prsc:2|A-5231-OUT,B-2178-A,T-6356-OUT;n:type:ShaderForge.SFN_ComponentMask,id:822,x:34573,y:33389,varname:node_822,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-2178-RGB;n:type:ShaderForge.SFN_Multiply,id:6517,x:35035,y:33689,varname:node_6517,prsc:2|A-6527-OUT,B-5764-OUT;n:type:ShaderForge.SFN_Vector3,id:5231,x:34890,y:33245,varname:node_5231,prsc:2,v1:0,v2:0,v3:0;proporder:2178-4145-7243-1437-5197-7234-6356;pass:END;sub:END;*/

Shader "Shader Forge/kuangnuqishi_raodong 01" {
    Properties {
        _node_2178 ("node_2178", 2D) = "white" {}
        _node_4145 ("node_4145", Color) = (0.5,0.5,0.5,1)
        _node_7243 ("node_7243", Float ) = 10
        _node_1437 ("node_1437", 2D) = "white" {}
        _node_5197 ("node_5197", Float ) = 0.1
        _node_7234 ("node_7234", Float ) = 100
        _node_6356 ("node_6356", Range(0, 2)) = 1
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
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _GrabTexture;
            uniform sampler2D _node_2178; uniform float4 _node_2178_ST;
            uniform sampler2D _node_1437; uniform float4 _node_1437_ST;
            uniform float4 _node_4145;
            uniform float _node_7243;
            uniform float _node_5197;
            uniform float _node_7234;
            uniform float _node_6356;
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
                float4 _node_2178_var = tex2D(_node_2178,TRANSFORM_TEX(i.uv0, _node_2178));
                float2 sceneUVs = float2(1,grabSign)*i.screenPos.xy*0.5+0.5 + ((_node_2178_var.rgb.rg*i.vertexColor.a)*(_node_6356*0.1));
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
/////// Vectors:
                float3 normalLocal = lerp(float3(0,0,0),float3(_node_2178_var.a,_node_2178_var.a,_node_2178_var.a),_node_6356);
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
////// Lighting:
////// Emissive:
                float3 emissive = ((_node_7243*(_node_4145.rgb*_node_2178_var.rgb))*_node_2178_var.r);
                float3 finalColor = emissive;
                float4 _node_1437_var = tex2D(_node_1437,TRANSFORM_TEX(i.uv0, _node_1437));
                float node_1565_if_leA = step((_node_5197+i.vertexColor.r),_node_1437_var.r);
                float node_1565_if_leB = step(_node_1437_var.r,(_node_5197+i.vertexColor.r));
                float node_9065 = 0.0;
                float node_4531 = 1.0;
                float node_1565 = lerp((node_1565_if_leA*node_9065)+(node_1565_if_leB*node_4531),node_4531,node_1565_if_leA*node_1565_if_leB);
                float node_6881_if_leA = step(i.vertexColor.r,_node_1437_var.r);
                float node_6881_if_leB = step(_node_1437_var.r,i.vertexColor.r);
                return fixed4(lerp(sceneColor.rgb, finalColor,((_node_2178_var.a*(node_1565+((node_1565-lerp((node_6881_if_leA*node_9065)+(node_6881_if_leB*node_4531),node_4531,node_6881_if_leA*node_6881_if_leB))*_node_7234)))*i.vertexColor.a)),1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
