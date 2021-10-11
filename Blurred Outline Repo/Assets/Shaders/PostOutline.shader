Shader "Unlit/PostOutline"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "black" {}
        _SceneTex("Scene Texture",2D) = "black" {}
        _kernel("Gauss Kernel", Vector) = (0,0,0,0)
        _kernelWidth("Gauss Kernel", float) = 1
        _OnlyShowBehindObject("Show Only Behind Object", float) = 0
        _OnlyShowInFrontObject("Show Only In Front of Object", float) = 0
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float kernel[50];
            float _kernelWidth;
            sampler2D _MainTex;
            sampler2D _SceneTex;
            //_TexelSize is a float2 that says how much screen space a texel occupies.
            float2 _MainTex_TexelSize;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                 //Also, the UVs show up in the top right corner for some reason, let's fix that.
                o.uv = o.vertex.xy / 2 + 0.5;
                
                return o;
            }

            half4 frag (v2f i) : COlOR
            {
                //arbitrary number of iterations for now
                int numberOfIterations = _kernelWidth;

                //split texel size into smaller words
                float texelX = _MainTex_TexelSize.x;

                //and a final intensity that increments based on surrounding intensities
                float colorIntensityInRadius = 0;

                //for every iteration horizontally
                for(int h = 0; h < numberOfIterations; h++)
                {
                    colorIntensityInRadius += kernel[h] *
                        tex2D(_MainTex, float2(i.uv.x + (h - numberOfIterations / 2) * texelX,i.uv.y)).r;
                }

                return colorIntensityInRadius;
            }
            ENDCG
        }
        
        GrabPass{}
        
        Pass 
        {
          CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            half4 _OutlineColor;
            float kernel[50];
            float _kernelWidth;
            sampler2D _MainTex;
            sampler2D _SceneTex;

            sampler2D _GrabTexture;
            float2 _GrabTexture_TexelSize;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                 //Also, the UVs show up in the top right corner for some reason, let's fix that.
                o.uv = o.vertex.xy / 2 + 0.5;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            half4 frag (v2f i) : COlOR
            {
                //arbitrary number of iterations for now
                int numberOfIterations = _kernelWidth;
                                                 
                //split texel size into smaller words
                float texelY = _GrabTexture_TexelSize.y;

                //if something already exists underneath the fragment, draw the scene instead.
                if(tex2D(_MainTex,i.uv.xy).r > 0)
                {
                    return tex2D(_SceneTex,i.uv.xy);
                }

                //and a final intensity that increments based on surrounding intensities
                float4 colorIntensityInRadius = 0;

                //for every iteration horizontally
                for(int v = 0; v < numberOfIterations; v++)
                {
                    colorIntensityInRadius += kernel[v] *
                        tex2D(_GrabTexture, float2(i.uv.x, 1-i.uv.y + (v - numberOfIterations / 2) * texelY));
                }

                half4 color = tex2D(_SceneTex, i.uv.xy) + colorIntensityInRadius * _OutlineColor;
                return color;
            }
            ENDCG  
        }
        Pass 
        {
          CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float _OnlyShowBehindObject;
            float _OnlyShowInFrontObject;
            sampler2D _MainTex;
            sampler2D _SceneTex;

            sampler2D _CameraDepthTexture;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                 //Also, the UVs show up in the top right corner for some reason, let's fix that.
                o.uv = o.vertex.xy / 2 + 0.5;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            half4 frag (v2f i) : COlOR
            {
                //depth calculations
                float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                depth = Linear01Depth(depth);

                half4 outlineMask = tex2D(_MainTex, i.uv.xy);

                if(_OnlyShowBehindObject > 0)
                {
                    //only show outline when behind and object
                    clip(depth < 0.1 ? -1:1);
                }
                else if(_OnlyShowInFrontObject > 0)
                {
                   //only show outline when not behind and object
                    clip(depth < 0.1 ? 1:-1); 
                }else
                {
                    //get rid of the entire depth to show all of the outlines
                    discard;
                }
                return tex2D(_SceneTex, i.uv.xy);
            }
            ENDCG  
        }
        
    }
}
