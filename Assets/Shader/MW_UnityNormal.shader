Shader "MW/UnityNormal" {
   Properties {
	  _MainTex ("Diffuse Map", 2D) = "white" {}
      _BumpMap ("Normal Map", 2D) = "bump" {}

      _LightDir ("Light Dir", Vector) = (1,1,1,1)
	  _LightColor ("Light Color", Color) = (1,1,1,1) 
	  _AlbedoColor ("Albedo Color", Color) = (1,1,1,1) 

      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
   }

   CGINCLUDE // common code for all passes of all subshaders

      #include "UnityCG.cginc"
      uniform float4 _LightColor0; 
      // color of light source (from "Lighting.cginc")

      // User-specified properties
      sampler2D _BumpMap;   
	  sampler2D _MainTex;

	  float4 _LightDir;

	  fixed4 _LightColor;
      fixed4 _SpecColor; 
	  fixed4 _AlbedoColor;
      fixed _Shininess;

      struct vertexInput {
         float4 vertex : POSITION;
         float4 texcoord : TEXCOORD0;
         float3 normal : NORMAL;
         float4 tangent : TANGENT;
      };

      struct vertexOutput {
         float4 pos : SV_POSITION;
         float4 posWorld : TEXCOORD0;
         float4 tex : TEXCOORD1;
         float3 tangentWorld : TEXCOORD2;  
         float3 normalWorld : TEXCOORD3;
         float3 binormalWorld : TEXCOORD4;
      };

      vertexOutput vert(vertexInput input) 
      {
         vertexOutput output;

         float4x4 modelMatrix = _Object2World;
         float4x4 modelMatrixInverse = _World2Object; 

         output.tangentWorld = normalize(mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
         output.normalWorld = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
         output.binormalWorld = normalize(cross(output.normalWorld, output.tangentWorld) * input.tangent.w); // tangent.w is specific to Unity

         output.posWorld = mul(modelMatrix, input.vertex);
         output.tex = input.texcoord;
         output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
         return output;
      }

      // fragment shader with ambient lighting
      float4 fragWithAmbient(vertexOutput input) : COLOR
      {
		 float4 diffuse = tex2D(_MainTex, input.tex.xy);
		 if(diffuse.a < 0.5f)
		 {
			discard;
		 }

         float4 encodedNormal = tex2D(_BumpMap, input.tex.xy);
		 float3 localCoords = UnpackNormal(encodedNormal); 

         //float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 2.0 * encodedNormal.g - 1.0, 0.0);
         //localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

         float3x3 local2WorldTranspose = float3x3(input.tangentWorld, input.binormalWorld, input.normalWorld);
         float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

         float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
         float3 lightDirection = normalize(_LightDir.xyz);

         float3 ambientLighting = _AlbedoColor.rgb * diffuse.rgb;
         float3 diffuseReflection = _LightColor.rgb * diffuse.rgb * max(0.0, dot(normalDirection, lightDirection));

         float3 specularReflection;
         if (dot(normalDirection, lightDirection) < 0.0) 
         {
            specularReflection = float3(0.0, 0.0, 0.0); 
         }
         else
         {
            specularReflection = _LightColor * _SpecColor.rgb * 
				pow(max(0.0, dot(reflect(lightDirection, normalDirection), -viewDirection)), _Shininess);
         }
         return float4(ambientLighting + diffuseReflection + specularReflection, 1.0);
      }
   ENDCG

   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragWithAmbient  
         ENDCG
      }
   }
}