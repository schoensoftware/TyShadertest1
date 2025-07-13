





Shader "Custom/FullyFixedIceShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,0.5)
        _RefractionStrength ("Refraction Strength", Range(0.01, 1)) = 0.2
        _ReflectionStrength ("Reflection Strength", Range(0, 1)) = 0.8
        _FresnelPower ("Fresnel Power", Range(0.01, 10)) = 5
        [HideInInspector] _NormalMap ("Normal Map", 2D) = "white" {} // Optional normal map
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include necessary URP headers
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float3 tangent : TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                half _RefractionStrength;
                half _ReflectionStrength;
                half _FresnelPower;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                // Transform positions and normals correctly
                float3 worldPos = TransformObjectToWorld(input.positionOS);
                float3 worldNormal = TransformObjectToWorldNormal(input.normalOS);

                // Use proper URP transformation for clip space
                output.positionHCS = TransformObjectToHClip(worldPos);
                output.worldNormal = normalize(worldNormal);
                output.uv = input.uv;
                output.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                output.worldPos = worldPos;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Use world normal (or sample normal map if available)
                float3 normal = input.worldNormal;

                // Check if we have a normal map and it's being used
                #ifdef USE_NORMAL_MAP
                TEXTURE2D_SAMPLER2D(_NormalMap, sampler_NormalMap);
                normal = UnpackNormal(TEX2D(_NormalMap, sampler_NormalMap, input.uv));
                // For tangent space to world space conversion, we need the TBN matrix
                // Since we don't have all the data for proper TBN calculation in this simple shader,
                // we'll just normalize the normal and use it directly
                normal = normalize(normal);
                #endif

                // Calculate reflection vector
                float3 reflectDir = reflect(-input.viewDir, normal);

                // Fresnel effect with proper saturation
                half fresnel = saturate(1 - dot(input.viewDir, normal));
                fresnel = pow(fresnel, _FresnelPower);

                // Combine base color with reflections
                half4 baseColor = _BaseColor;
                baseColor.a *= saturate(dot(normal, input.viewDir)); // Adjust alpha based on viewing angle

                // Sample environment for reflections (simplified - no _MainTex dependency)
                half3 reflection = float3(0.5, 0.6, 0.8); // Simple sky color for demo

                // Combine all effects
                half4 finalColor = baseColor;
                finalColor.rgb += fresnel * reflection * _ReflectionStrength;

                return finalColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert_depth
            #pragma fragment frag_depth

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert_depth(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            void frag_depth(Varyings input) {}
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}




