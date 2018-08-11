// Copyright (c) 2018 synqark
//
// This code and repos（https://github.com/synqark/Arktoon-Shader) is under MIT licence, see LICENSE
//
// 本コードおよびリポジトリ（https://github.com/synqark/Arktoon-Shader) は MIT License を使用して公開しています。
// 詳細はLICENSEか、https://opensource.org/licenses/mit-license.php を参照してください。
Shader "arktoon/Fade" {
    Properties {
        // Culling
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("[Advanced] Cull", Float) = 2 // Back
        [Enum(Off, 0, On, 1)]_ZWrite("ZWrite", Float) = 0
        // Common
        _MainTex ("[Common] Base Texture", 2D) = "white" {}
        _Color ("[Common] Base Color", Color) = (1,1,1,1)
        _Normalmap ("[Common] Normal map", 2D) = "bump" {}
        _Emissionmap ("[Common] Emission map", 2D) = "white" {}
        _EmissionColor ("[Common] Emission Color", Color) = (0,0,0,1)
        // Shadow
        _ShadowBoarderMin ("[Shadow] Boarder Min", Range(0, 1)) = 0.499
        _ShadowBoarderMax ("[Shadow] Boarder Max", Range(0, 1)) = 0.55
        _ShadowStrength ("[Shadow] Strength", Range(0, 1)) = 0.5
        _ShadowStrengthMask ("[Shadow] Strength Mask", 2D) = "white" {}
        // Plan B
        [Toggle(USE_SHADE_TEXTURE)]_ShadowPlanBUsePlanB ("[Plan B] Use Plan B", Float ) = 0
        [Toggle(USE_SHADOW_MIX)]_ShadowPlanBUseShadowMix ("[Plan B] Use Shadow Mix", Float ) = 0
        [Toggle(USE_CUSTOM_SHADOW_TEXTURE)] _ShadowPlanBUseCustomShadowTexture ("[Plan B] Use Custom Shadow Texture", Float ) = 0
        _ShadowPlanBHueShiftFromBase ("[Plan B] Hue Shift From Base", Range(-1, 1)) = 0
        _ShadowPlanBSaturationFromBase ("[Plan B] Saturation From Base", Range(0, 2)) = 1
        _ShadowPlanBValueFromBase ("[Plan B] Value From Base", Range(0, 2)) = 0
        _ShadowPlanBCustomShadowTexture ("[Plan B] Custom Shadow Texture", 2D) = "black" {}
        _ShadowPlanBCustomShadowTextureRGB ("[Plan B] Custom Shadow Texture RGB", Color) = (1,1,1,1)
        // Gloss
        [Toggle(USE_GLOSS)]_UseGloss ("[Gloss] Enabled", Float) = 0
        _GlossBlend ("[Gloss] Blend", Range(0, 1)) = 0
        _GlossBlendMask ("[Gloss] Blend Mask", 2D) = "white" {}
        _GlossPower ("[Gloss] Power", Range(0, 1)) = 0.5
        _GlossColor ("[Gloss] Color", Color) = (1,1,1,1)
        // MatCap
        [Toggle(USE_MATCAP)]_UseMatcap ("[MatCap] Enabled", Float) = 0
        _MatcapBlend ("[MatCap] Blend", Range(0, 3)) = 1
        _MatcapBlendMask ("[MatCap] Blend Mask", 2D) = "white" {}
        _MatcapNormalMix ("[MatCap] Normal map mix", Range(0, 2)) = 1
        _MatcapTexture ("[MatCap] Texture", 2D) = "black" {}
        _MatcapColor ("[MatCap] Color", Color) = (1,1,1,1)
        // Reflection
        [Toggle(USE_REFLECTION)]_UseReflection ("[Reflection] Enabled", Float) = 0
        _ReflectionReflectionPower ("[Reflection] Reflection Power", Range(0, 1)) = 0
        _ReflectionReflectionMask ("[Reflection] Reflection Mask", 2D) = "white" {}
        _ReflectionNormalMix ("[Reflection] Normal Map Mix", Range(0,2)) = 1
        _ReflectionCubemap ("[Reflection] Cubemap", Cube) = "_Skybox" {}
        _ReflectionRoughness ("[Reflection] Roughness", Range(0, 1)) = 0
        // Rim
        [Toggle(USE_RIM)]_UseRim ("[Rim] Enabled", Float) = 0
        _RimBlend ("[Rim] Blend", Range(0, 3)) = 0
        _RimBlendMask ("[Rim] Blend Mask", 2D) = "white" {}
        _RimFresnelPower ("[Rim] Fresnel Power", Range(0, 10)) = 1
        _RimColor ("[Rim] Color", Color) = (1,1,1,1)
        _RimTexture ("[Rim] Texture", 2D) = "white" {}
        [MaterialToggle] _RimUseBaseTexture ("[Rim] Use Base Texture", Float ) = 0
        // ShadowCap
        [Toggle(USE_SHADOWCAP)]_UseShadowCap ("[ShadowCap] Enabled", Float) = 0
        _ShadowCapBlend ("[ShadowCap] Blend", Range(0, 3)) = 0
        _ShadowCapBlendMask ("[ShadowCap] Blend Mask", 2D) = "white" {}
        _ShadowCapNormalMix ("[ShadowCap] Normal map mix", Range(0, 2)) = 1
        _ShadowCapTexture ("[ShadowCap] Texture", 2D) = "white" {}
        _ShadowCapColor ("[ShadowCap] Color", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull [_Cull]
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma shader_feature USE_SHADE_TEXTURE
            #pragma shader_feature USE_SHADOW_MIX
            #pragma shader_feature USE_GLOSS
            #pragma shader_feature USE_MATCAP
            #pragma shader_feature USE_REFLECTION
            #pragma shader_feature USE_RIM
            #pragma shader_feature USE_SHADOWCAP
            #pragma shader_feature USE_CUSTOM_SHADOW_TEXTURE

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float _GlossPower;
            uniform float4 _GlossColor;
            float3 ShadeSH9Indirect(){
                return ShadeSH9(half4(0.0, -1.0, 0.0, 1.0));
            }

            float3 ShadeSH9Direct(){
                return ShadeSH9(half4(0.0, 1.0, 0.0, 1.0));
            }

            float3 grayscale_vector_node(){
                return float3(0, 0.3823529, 0.01845836);
            }

            float3 ShadeSH9Normal( float3 normalDirection ){
                return ShadeSH9(half4(normalDirection, 1.0));
            }

            float3 CalculateHSV(float3 baseTexture, float hueShift, float saturation, float value ){
                float4 node_5443_k = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 node_5443_p = lerp(float4(float4(baseTexture,0.0).zy, node_5443_k.wz), float4(float4(baseTexture,0.0).yz, node_5443_k.xy), step(float4(baseTexture,0.0).z, float4(baseTexture,0.0).y));
                float4 node_5443_q = lerp(float4(node_5443_p.xyw, float4(baseTexture,0.0).x), float4(float4(baseTexture,0.0).x, node_5443_p.yzx), step(node_5443_p.x, float4(baseTexture,0.0).x));
                float node_5443_d = node_5443_q.x - min(node_5443_q.w, node_5443_q.y);
                float node_5443_e = 1.0e-10;
                float3 node_5443 = float3(abs(node_5443_q.z + (node_5443_q.w - node_5443_q.y) / (6.0 * node_5443_d + node_5443_e)), node_5443_d / (node_5443_q.x + node_5443_e), node_5443_q.x);;
                return (lerp(float3(1,1,1),saturate(3.0*abs(1.0-2.0*frac((hueShift+node_5443.r)+float3(0.0,-1.0/3.0,1.0/3.0)))-1),(node_5443.g*saturation))*(value*node_5443.b));
            }

            uniform float _ShadowPlanBHueShiftFromBase;
            uniform float _ShadowPlanBSaturationFromBase;
            uniform float _ShadowPlanBValueFromBase;
            uniform float _ShadowBoarderMin;
            uniform float _ShadowBoarderMax;
            uniform float _ShadowStrength;
            uniform sampler2D _ShadowStrengthMask; uniform float4 _ShadowStrengthMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _Emissionmap; uniform float4 _Emissionmap_ST;
            uniform float4 _EmissionColor;
            uniform sampler2D _MatcapTexture; uniform float4 _MatcapTexture_ST;
            uniform float _MatcapBlend;
            uniform sampler2D _MatcapBlendMask; uniform float4 _MatcapBlendMask_ST;
            uniform float _ReflectionRoughness;
            uniform float _ReflectionReflectionPower;
            uniform sampler2D _ReflectionReflectionMask; uniform float4 _ReflectionReflectionMask_ST;
            uniform float _ReflectionNormalMix;
            uniform float _GlossBlend;
            uniform sampler2D _GlossBlendMask; uniform float4 _GlossBlendMask_ST;
            uniform float _RimFresnelPower;
            uniform float4 _RimColor;
            uniform fixed _RimUseBaseTexture;
            uniform float _RimBlend;
            uniform sampler2D _RimBlendMask; uniform float4 _RimBlendMask_ST;
            uniform sampler2D _RimTexture; uniform float4 _RimTexture_ST;
            uniform sampler2D _ShadowPlanBCustomShadowTexture; uniform float4 _ShadowPlanBCustomShadowTexture_ST;
            uniform float4 _ShadowPlanBCustomShadowTextureRGB;
            uniform float4 _MatcapColor;
            uniform float _MatcapNormalMix;
            uniform samplerCUBE _ReflectionCubemap;
            uniform sampler2D _ShadowCapTexture; uniform float4 _ShadowCapTexture_ST;
            uniform sampler2D _ShadowCapBlendMask; uniform float4 _ShadowCapBlendMask_ST;
            uniform float _ShadowCapBlend;
            uniform float4 _ShadowCapColor;
            uniform float _ShadowCapNormalMix;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                UNITY_LIGHT_ATTENUATION(attenuation,i, i.posWorld.xyz);
////// Emissive:

                #ifdef USE_MATCAP
                    float3 normalDirectionMatcap = normalize(mul( float3(normalLocal.r*_MatcapNormalMix,normalLocal.g*_MatcapNormalMix,normalLocal.b), tangentTransform )); // Perturbed normals
                    float2 transformMatcap = (mul( UNITY_MATRIX_V, float4(normalDirectionMatcap,0) ).xyz.rgb.rg*0.5+0.5);
                    float4 _MatcapTexture_var = tex2D(_MatcapTexture,TRANSFORM_TEX(transformMatcap, _MatcapTexture));
                    float4 _MatcapBlendMask_var = tex2D(_MatcapBlendMask,TRANSFORM_TEX(i.uv0, _MatcapBlendMask));
                    float3 matcap = ((_MatcapColor.rgb*_MatcapTexture_var.rgb)*_MatcapBlendMask_var.rgb*_MatcapBlend);
                #else
                    float3 matcap = float3(0,0,0);
                #endif

                #ifdef USE_SHADOWCAP
                    float3 normalDirectionShadowCap = normalize(mul( float3(normalLocal.r*_ShadowCapNormalMix,normalLocal.g*_ShadowCapNormalMix,normalLocal.b), tangentTransform )); // Perturbed normals
                    float2 transformShadowCap = (mul( UNITY_MATRIX_V, float4(normalDirectionShadowCap,0) ).xyz.rgb.rg*0.5+0.5);
                    float4 _ShadowCapTexture_var = tex2D(_ShadowCapTexture,TRANSFORM_TEX(transformShadowCap, _ShadowCapTexture));
                    float4 _ShadowCapBlendMask_var = tex2D(_ShadowCapBlendMask,TRANSFORM_TEX(i.uv0, _ShadowCapBlendMask));
                    float3 shadowcap = (1.0 - ((1.0 - (_ShadowCapTexture_var.rgb*_ShadowCapColor.rgb))*_ShadowCapBlendMask_var.rgb)*_ShadowCapBlend);
                #else
                    float3 shadowcap = float3(1000,1000,1000);
                #endif

                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 Diffuse = (_MainTex_var.rgb*_Color.rgb);

                #ifdef USE_RIM
                    float _RimBlendMask_var = tex2D(_RimBlendMask, TRANSFORM_TEX(i.uv0, _RimBlendMask));
                    float4 _RimTexture_var = tex2D(_RimTexture,TRANSFORM_TEX(i.uv0, _RimTexture));
                    float3 RimLight = (lerp( _RimTexture_var.rgb, Diffuse, _RimUseBaseTexture )*pow(1.0-max(0,dot(normalDirection, viewDirection)),_RimFresnelPower)*_RimBlend*_RimColor.rgb*_RimBlendMask_var);
                #else
                    float3 RimLight = float3(0,0,0);
                #endif

                float4 _Emissionmap_var = tex2D(_Emissionmap,TRANSFORM_TEX(i.uv0, _Emissionmap));
                float3 emissive = max(((_Emissionmap_var.rgb*_EmissionColor.rgb)+matcap),RimLight);
                float3 ShadeSH9Minus = ShadeSH9Indirect();
                float3 indirectLighting = saturate(ShadeSH9Minus);
                float3 ShadeSH9Plus = ShadeSH9Direct();
                float3 directLighting = saturate((ShadeSH9Plus+_LightColor0.rgb));
                float3 grayscale_vector = grayscale_vector_node();
                float grayscalelightcolor = dot(_LightColor0.rgb,grayscale_vector);
                float grayscaleDirectLighting = ((dot(lightDirection,normalDirection)*grayscalelightcolor*attenuation)+dot(ShadeSH9Normal( normalDirection ),grayscale_vector));
                float bottomIndirectLighting = dot(ShadeSH9Minus,grayscale_vector);
                float topIndirectLighting = dot(ShadeSH9Plus,grayscale_vector);
                float lightDifference = ((topIndirectLighting+grayscalelightcolor)-bottomIndirectLighting);
                float remappedLight = ((grayscaleDirectLighting-bottomIndirectLighting)/lightDifference);
                float node_4614 = 0.0;
                float _ShadowStrengthMask_var = tex2D(_ShadowStrengthMask, TRANSFORM_TEX(i.uv0, _ShadowStrengthMask));
                float directContribution = (1.0 - ((1.0 - saturate((node_4614 + ( (saturate(remappedLight) - _ShadowBoarderMin) * (1.0 - node_4614) ) / (_ShadowBoarderMax - _ShadowBoarderMin)))) * _ShadowStrengthMask_var * _ShadowStrength));
                float3 finalLight = lerp(indirectLighting,directLighting,directContribution);

                #ifdef USE_SHADE_TEXTURE
                    #ifdef USE_SHADOW_MIX
                        float3 shadeMixValue = finalLight;
                    #else
                        float3 shadeMixValue = directLighting;
                    #endif
                    #ifdef USE_CUSTOM_SHADOW_TEXTURE
                        float4 _ShadowPlanBCustomShadowTexture_var = tex2D(_ShadowPlanBCustomShadowTexture,TRANSFORM_TEX(i.uv0, _ShadowPlanBCustomShadowTexture));
                        float3 shadowCustomTexture = _ShadowPlanBCustomShadowTexture_var.rgb * _ShadowPlanBCustomShadowTextureRGB.rgb;
                        float3 ShadeMap = shadowCustomTexture*shadeMixValue;
                    #else
                        float3 Diff_HSV = CalculateHSV(Diffuse, _ShadowPlanBHueShiftFromBase, _ShadowPlanBSaturationFromBase, _ShadowPlanBValueFromBase);
                        float3 ShadeMap = Diff_HSV*shadeMixValue;
                    #endif
                    float3 ToonedMap = (lerp(ShadeMap,Diffuse*finalLight,finalLight)/1.0);
                #else
                    float3 ToonedMap = Diffuse*finalLight;
                #endif

                #ifdef USE_REFLECTION
                    float3 normalDirectionReflection = normalize(mul( float3(normalLocal.r*_ReflectionNormalMix, normalLocal.g*_ReflectionNormalMix, normalLocal.b), tangentTransform )); // Perturbed normals
                    float3 viewReflectDirection = reflect( -viewDirection, normalDirectionReflection );
                    float4 _ReflectionReflectionMask_var = tex2D(_ReflectionReflectionMask,TRANSFORM_TEX(i.uv0, _ReflectionReflectionMask));
                    float3 ReflectionMap = (_ReflectionReflectionPower*_ReflectionReflectionMask_var.rgb*texCUBElod(_ReflectionCubemap,float4(viewReflectDirection,_ReflectionRoughness*15.0)).rgb);
                #else
                    float3 ReflectionMap = float3(0,0,0);
                #endif

                #ifdef USE_GLOSS
                    float _GlossBlendMask_var = tex2D(_GlossBlendMask, TRANSFORM_TEX(i.uv0, _GlossBlendMask));
                    float3 Gloss = ((max(0,dot(lightDirection,normalDirection))*pow(max(0,dot(normalDirection,halfDirection)),exp2(lerp(1,11,_GlossPower)))*_GlossColor.rgb)*_LightColor0.rgb*attenuation*_GlossBlend * _GlossBlendMask_var);
                #else
                    float3 Gloss = float3(0,0,0);
                #endif

                float3 finalColor = emissive + min(max((ToonedMap+ReflectionMap),Gloss),shadowcap);
                fixed4 finalRGBA = fixed4(finalColor,(_MainTex_var.a*_Color.a));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Cull [_Cull]
            Blend One One
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma shader_feature USE_GLOSS
            #pragma shader_feature USE_SHADOWCAP
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float _GlossPower;
            uniform float4 _GlossColor;

            uniform float _ShadowBoarderMin;
            uniform float _ShadowBoarderMax;
            uniform float _ShadowStrength;
            uniform sampler2D _ShadowStrengthMask; uniform float4 _ShadowStrengthMask_ST;
            uniform sampler2D _Normalmap; uniform float4 _Normalmap_ST;
            uniform sampler2D _Emissionmap; uniform float4 _Emissionmap_ST;
            uniform float4 _EmissionColor;

            uniform float _GlossBlend;
            uniform sampler2D _GlossBlendMask; uniform float4 _GlossBlendMask_ST;
            uniform sampler2D _ShadowCapTexture; uniform float4 _ShadowCapTexture_ST;
            uniform sampler2D _ShadowCapBlendMask; uniform float4 _ShadowCapBlendMask_ST;
            uniform float _ShadowCapBlend;
            uniform float4 _ShadowCapColor;
            uniform float _ShadowCapNormalMix;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 _Normalmap_var = UnpackNormal(tex2D(_Normalmap,TRANSFORM_TEX(i.uv0, _Normalmap)));
                float3 normalLocal = _Normalmap_var.rgb;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals

                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);

                UNITY_LIGHT_ATTENUATION(attenuation,i, i.posWorld.xyz);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
                float3 Diffuse = (_MainTex_var.rgb*_Color.rgb);

                #ifdef USE_GLOSS
                    float _GlossBlendMask_var = tex2D(_GlossBlendMask, TRANSFORM_TEX(i.uv0, _GlossBlendMask));
                    float3 Gloss = ((max(0,dot(lightDirection,normalDirection))*pow(max(0,dot(normalDirection,halfDirection)),exp2(lerp(1,11,_GlossPower)))*_GlossColor.rgb)*_LightColor0.rgb*attenuation*_GlossBlend*_GlossBlendMask_var);
                #else
                    float3 Gloss = float3(0,0,0);
                #endif

                #ifdef USE_SHADOWCAP
                    float3 normalDirectionShadowCap = normalize(mul( float3(normalLocal.r*_ShadowCapNormalMix,normalLocal.g*_ShadowCapNormalMix,normalLocal.b), tangentTransform )); // Perturbed normals
                    float2 transformShadowCap = (mul( UNITY_MATRIX_V, float4(normalDirectionShadowCap,0) ).xyz.rgb.rg*0.5+0.5);
                    float4 _ShadowCapTexture_var = tex2D(_ShadowCapTexture,TRANSFORM_TEX(transformShadowCap, _ShadowCapTexture));
                    float4 _ShadowCapBlendMask_var = tex2D(_ShadowCapBlendMask,TRANSFORM_TEX(i.uv0, _ShadowCapBlendMask));
                    float3 shadowcap = (1.0 - ((1.0 - (_ShadowCapTexture_var.rgb*_ShadowCapColor.rgb))*_ShadowCapBlendMask_var.rgb)*_ShadowCapBlend);
                #else
                    float3 shadowcap = float3(1000,1000,1000);
                #endif

				float lightContribution = dot(normalize(_WorldSpaceLightPos0.xyz - i.posWorld.xyz),normalDirection)*attenuation;
                float3 directContribution = (1.0 - (1.0 - saturate(((saturate(lightContribution) - _ShadowBoarderMin) / (_ShadowBoarderMax - _ShadowBoarderMin)))));
                float _ShadowStrengthMask_var = tex2D(_ShadowStrengthMask, TRANSFORM_TEX(i.uv0, _ShadowStrengthMask));
                float3 finalLight = saturate(directContribution + ((1 - (_ShadowStrength * _ShadowStrengthMask_var)) * attenuation));
                float3 ToonedMap = Diffuse * lerp(0, _LightColor0.rgb, finalLight);
                float3 finalColor = min(max((ToonedMap),Gloss),shadowcap);

                fixed4 finalRGBA = fixed4(finalColor * (_MainTex_var.a * _Color.a),0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Standard"
    CustomEditor "ArktoonShaders.ArktoonInspector"
}
