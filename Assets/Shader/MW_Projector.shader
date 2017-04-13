// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

Shader "MW/Projector" {
   Properties {
      _Caustic ("Projected Image", 2D) = "white" {}
	  _TexPower("TexPower", Range(0,.9)) = 0.15
	  _FollowMain("Follow Main Object", Int) = 0
   }
   SubShader {
      Pass {
         ZWrite Off // 不写入深度缓存
         Blend One One //影子与原色按1:1混合颜色
         Offset -1, -1 // 防止zbuff冲突，做的偏移
 
         CGPROGRAM
 
         #pragma vertex vert
         #pragma fragment frag 

         #include "UnityCG.cginc"
 
         uniform sampler2D _Caustic;  
		 uniform float4 _Caustic_ST;
 
         // Projector组件传入的从模型空间到投影空间的矩阵
         uniform float4x4 unity_Projector; 
		 fixed _TexPower;
		 int _FollowMain;
 
          struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posProj : TEXCOORD0; //投影空间的坐标值
			float4 posWorld: TEXCOORD1;	//世界坐标
         };
 
         vertexOutput vert(vertexInput input)
         {
            vertexOutput output;
 
			output.posWorld = mul(_Object2World,(input.vertex));
            output.posProj = mul(unity_Projector, input.vertex);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            if (input.posProj.w > 0.0) // 在投影物前方
            {
				if(_FollowMain == 1)
				{
					//posProj 跟随人物移动
					float2 uv = input.posProj.rg / input.posProj.w;
					return tex2D(_Caustic, uv) * _TexPower;
				}
				else
				{
					//posWorld 不跟随人物移动
					float2 uv = (input.posWorld.rgb * 0.3).rb;
					return tex2D(_Caustic, TRANSFORM_TEX(uv, _Caustic)) * _TexPower;
				}
            }
            else // 投影物体后方
            {
               return float4(0.0, 0.0, 0.0, 0.0);
            }
         }
 
         ENDCG
      }
   }
}