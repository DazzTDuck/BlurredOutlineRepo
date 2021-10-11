Shader "Unlit/WaterStylized"
{
    Properties
    {
        [Header(Noise)]
        _SurfaceNoise("Surface Noise", 2D) = "white" {}
        _SurfaceNoiseScroll("Surface Noise Scroll Amount", Vector) = (0.03, 0.03, 0, 0)
        [Header(Distortion)]
        _SurfaceDistortion("Surface Distortion", 2D) = "white" {}	
        _SurfaceDistortionAmount("Surface Distortion Amount", Range(0, 1)) = 0.27
        [Header(Color and Foam)]
        _WaterColor ("Water Color", Color) = (0,0,1,1)
        _FoamColor ("Foam Color", Color) = (1,1,1,1)
        _FoamDistance ("Foam Distance", Range(0, 3)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata //mesh data
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f //interpolators
            {
                float2 uv : TEXCOORD0;
                float2 distortUV : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _CameraDepthTexture;
            float4 _WaterColor;
            float4 _FoamColor;
            float _FoamDistance;

            //noise
            sampler2D _SurfaceNoise;
            float4 _SurfaceNoise_ST;
            float2 _SurfaceNoiseScroll;

            //distortion
            sampler2D _SurfaceDistortion;
            float4 _SurfaceDistortion_ST;
            float _SurfaceDistortionAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _SurfaceNoise);
                o.distortUV = TRANSFORM_TEX(v.uv, _SurfaceDistortion);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //distortion
                float2 distortSample = (tex2D(_SurfaceDistortion, i.distortUV).xy * 2 - 1) * _SurfaceDistortionAmount;

                //noise texture scrolling
                float2 noiseUV = float2((i.uv.x + _Time.y * _SurfaceNoiseScroll.x) + distortSample.x,
                    (i.uv.y + _Time.y * _SurfaceNoiseScroll.y) + distortSample.y);
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;

                //depth calculations
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPos.w;

                //make controllable how big the foam is
                float foamDifference = saturate(depthDifference / _FoamDistance);

                //apply to intersections and add color
                float surfaceNoise = surfaceNoiseSample > foamDifference ? 1 : 0;
                float foam = _FoamColor * surfaceNoise;

                return _WaterColor + foam;
            }
            ENDCG
        }
    }
}
