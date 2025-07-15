
Shader "Custom/AdvancedIceShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,0.5)
        _RefractionStrength ("Refraction Strength", Range(0.01, 1)) = 0.2
        _ReflectionStrength ("Reflection Strength", Range(0, 1)) = 0.8
        _FresnelPower ("Fresnel Power", Range(0.01, 10)) = 5
        [HideInInspector] _NormalMap ("Normal Map", 2D) = "white" {} // Optional normal map
        _RefractionTex ("Refraction Texture", 2D) = "" {} // Texture to simulate refraction
        _RimPower ("Rim Light Power", Range(0, 10)) = 3 // Controls intensity of rim lighting
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include necessary URP headers for latest compatibility
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Define transformation functions manually since Transform.hlsl is not available
            float3x4 UnityObjectToWorld;
            float3x4 UnityWorldToObject;

            float3 TransformObjectToWorld(float4 positionOS)
            {
                return mul(UnityObjectToWorld, positionOS).xyz;
            }

            float3 TransformObjectToWorldNormal(float3 normalOS)
            {
                return normalize(mul((float3x3)UnityObjectToWorld, normalOS));
            }

            float4 TransformObjectToHClip(float4 positionOS)
            {
                return UnityObjectToClipPos(positionOS);
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT; // Includes handedness in w component
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                float3 tangentWS : TEXCOORD4; // World space tangent
                float3 bitangentWS : TEXCOORD5; // World space bitangent
            };

            // Material properties
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                half _RefractionStrength;
                half _ReflectionStrength;
                half _FresnelPower;
                half _RimPower; // Additional property for rim lighting
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output;

                // Transform positions and normals correctly
                float3 worldPos = TransformObjectToWorld(input.positionOS);
                float3 worldNormal = TransformObjectToWorldNormal(input.normalOS);

                // Calculate tangent and bitangent in world space
                float3 worldTangent = TransformObjectToWorldNormal(float3(input.tangentOS.xyz * input.tangentOS.w));
                float3 worldBitangent = cross(worldNormal, worldTangent) * input.tangentOS.w;

                // Use proper URP transformation for clip space
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.worldNormal = normalize(worldNormal);
                output.uv = input.uv;
                output.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                output.worldPos = worldPos;
                output.tangentWS = normalize(worldTangent);
                output.bitangentWS = normalize(worldBitangent);

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Calculate TBN matrix for proper normal mapping
                float3x3 tbnMatrix = float3x3(
                    normalize(input.tangentWS),
                    normalize(input.bitangentWS),
                    normalize(input.worldNormal)
                );

                // Use world normal (or sample normal map if available)
                float3 normal = input.worldNormal;

                #ifdef USE_NORMAL_MAP
                TEXTURE2D_SAMPLER2D(_NormalMap, sampler_NormalMap);
                float3 tangentSpaceNormal = UnpackNormal(TEX2D(_NormalMap, sampler_NormalMap, input.uv));
                // Convert from tangent space to world space using TBN matrix
                normal = normalize(tbnMatrix * tangentSpaceNormal);
                #endif

                // Calculate reflection vector
                float3 reflectDir = reflect(-input.viewDir, normal);

                // Fresnel effect with proper saturation
                half fresnel = saturate(1 - dot(input.viewDir, normal));
                fresnel = pow(fresnel, _FresnelPower);

                // Combine base color with reflections
                half4 baseColor = _BaseColor;
                baseColor.a *= saturate(dot(normal, input.viewDir)); // Adjust alpha based on viewing angle

                // Sample environment for reflections (simplified - in a real scenario we'd use reflection probes)
                half3 reflection = float3(0.5, 0.6, 0.8); // Simple sky color for demo
                #ifdef USE_SCREEN_SPACE_REFLECTIONS
                // In a full implementation, we would sample screen space reflections here
                #endif

                // Implement refraction effect (simplified - in real scenario we'd use texture sampling)
                half3 refractionColor = float3(0.7, 0.8, 1.0); // Light blue for ice
                #ifdef USE_REFRACTION_TEXTURE
                TEXTURE2D_SAMPLER2D(_RefractionTex, sampler_RefractionTex);
                refractionColor = TEX2D(_RefractionTex, sampler_RefractionTex, input.uv).rgb;
                #endif

                // Combine all effects with proper weighting
                half4 finalColor = baseColor;

                // Add reflections based on fresnel
                finalColor.rgb += fresnel * reflection * _ReflectionStrength;

                // Add refraction effect (mixed with base color)
                finalColor.rgb = lerp(finalColor.rgb, refractionColor, _RefractionStrength);

                // Add rim lighting for better edge definition
                half rim = saturate(1 - dot(input.viewDir, normal));
                rim = pow(rim, _RimPower * 2);
                finalColor.rgb = lerp(finalColor.rgb, float3(0.8, 0.9, 1.0), rim * 0.2);

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

            // Include necessary URP headers for latest compatibility
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Define transformation functions manually since Transform.hlsl is not available
            float3x4 UnityObjectToWorld;
            float3x4 UnityWorldToObject;

            float3 TransformObjectToWorld(float4 positionOS)
            {
                return mul(UnityObjectToWorld, positionOS).xyz;
            }

            float3 TransformObjectToWorldNormal(float3 normalOS)
            {
                return normalize(mul((float3x3)UnityObjectToWorld, normalOS));
            }

            float4 TransformObjectToHClip(float4 positionOS)
            {
                return UnityObjectToClipPos(positionOS);
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT; // Includes handedness in w component
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert_depth(Attributes input)
            {
                Varyings output;
                float3 worldPos = TransformObjectToWorld(input.positionOS);
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            void frag_depth(Varyings input) {}
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
