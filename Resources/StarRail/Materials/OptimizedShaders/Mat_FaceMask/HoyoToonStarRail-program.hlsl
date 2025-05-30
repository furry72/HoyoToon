vs_out vs_base(vs_in v)
{
    vs_out o = (vs_out)0.0f;
    UNITY_SETUP_INSTANCE_ID(v); 
    UNITY_INITIALIZE_OUTPUT(vs_out, o); 
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    float4 pos_ws  = mul(unity_ObjectToWorld, v.vertex);
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);
    o.pos = pos_wvp;
    o.ws_pos =  v.vertex;
    o.ss_pos = ComputeScreenPos(o.pos);
    o.uv = float4(v.uv_0, v.uv_1); // populate this with both uvs to save on texcoords 
    o.normal = mul((float3x3)unity_ObjectToWorld, v.normal) ; // WORLD SPACE NORMAL 
    o.tangent.xyz = mul((float3x3)unity_ObjectToWorld, v.tangent.xyz); // WORLD SPACE TANGENT
    o.tangent.w = v.tangent.w * unity_WorldTransformParams.w; 
    o.view = _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz;
    o.v_col = v.v_col;    
    o.vertex = v.vertex;
    #if defined(can_dissolve)
        if((0.0 /*_DissoveON*/))
        {
            dissolve_vertex(v, o.dis_pos, o.dis_uv);
        }
    #endif
    if((1.0 /*_FaceMaterial*/)) o.normal = 0.5f;
    o.grab = ComputeGrabScreenPos(o.pos);
    #if defined (_is_shadow)
        if((0.0 /*_HairMaterial*/))
        {
            float4 ws_pos = mul(unity_ObjectToWorld, v.vertex);
            float3 vl = mul(_WorldSpaceLightPos0.xyz, UNITY_MATRIX_V) * (1.f / ws_pos.w);
            float3 offset_pos = ((vl * .001f) * float3(7,0,5)) + v.vertex.xyz;
            v.vertex.xyz = offset_pos;
            o.pos = UnityObjectToClipPos(v.vertex);
        }
    #endif
    if(hide_parts(v.v_col) && !(1.0 /*_FaceMaterial*/) && ((0 /*_ShowPartID*/) != 0)) o.pos = float4(-99.0, -99.0, -99.0, 1.0);
    TRANSFER_SHADOW(o)
    return o;
}
vs_out vs_edge(vs_in v)
{
    vs_out o = (vs_out)0.0f; // cast to 0 to avoid intiailization warnings
    if((0.0 /*_EnableOutline*/))
    {
        if((1.0 /*_FaceMaterial*/)) // sigh is this even going to work in vr? 
        {
            float4 tmp0;
            float4 tmp1;
            float4 tmp2;
            float4 tmp3;
            tmp0.xy = float2(-0.206, 0.961);
            tmp0.z = (0.6 /*_OutlineFixSide*/);
            tmp1.xyz = mul(v.vertex.xyz, (float3x3)unity_ObjectToWorld).xyz;
            tmp2.xyz = _WorldSpaceCameraPos - tmp1.xyz;
            tmp1.xyz = mul(tmp1.xyz, (float3x3)unity_ObjectToWorld).xyz;
            tmp0.w = length(tmp1.xyz);
            tmp1.yzw = tmp0.w * tmp1.xyz;
            tmp0.w = tmp1.x * tmp0.w + -0.1;
            tmp0.x = dot(tmp0.xyz, tmp1.xyz); 
            tmp2.yz = float2(-0.206, 0.961);
            tmp2.xw = -float2((0.6 /*_OutlineFixSide*/).x, (0.05 /*_OutlineFixFront*/).x);
            tmp0.y = dot(tmp2.xyz, tmp1.xyz);
            tmp0.z = dot(float2(0.076, 0.961), tmp1.xy);
            tmp0.x = max(tmp0.y, tmp0.x);
            tmp0.x = 0.1 - tmp0.x;
            tmp0.x = tmp0.x * 9.999998;
            tmp0.x = max(tmp0.x, 0.0);
            tmp0.y = tmp0.x * -2.0 + 3.0;
            tmp0.x = tmp0.x * tmp0.x;
            tmp0.x = tmp0.x * tmp0.y;
            tmp0.x = min(tmp0.x, 1.0);
            tmp0.y = saturate(tmp0.z);
            tmp0.z = 1.0 - tmp0.z;
            tmp0.y = tmp2.x + tmp0.y;
            tmp0.yw = saturate(tmp0.yw * float2(20.0, 5.0));
            tmp1.x = tmp0.y * -2.0 + 3.0;
            tmp0.y = tmp0.y * tmp0.y;
            tmp0.y = tmp0.y * tmp1.x;
            tmp0.x = max(tmp0.x, tmp0.y);
            tmp0.x = min(tmp0.x, 1.0);
            tmp0.x = tmp0.x - 1.0;
            tmp0.x = v.v_col.y * tmp0.x + 1.0;
            tmp0.x = tmp0.x * (0.1 /*_OutlineWidth*/);
            tmp0.x = tmp0.x * (0.187 /*_OutlineScale*/);
            tmp0.y = tmp0.w * -2.0 + 3.0;
            tmp0.w = tmp0.w * tmp0.w;
            tmp0.y = tmp0.w * tmp0.y;
            tmp1.xy = -float2((0.1 /*_OutlineFixRange1*/).x, (0.1 /*_OutlineFixRange2*/).x) + float2((0.1 /*_OutlineFixRange3*/).x, (0.1 /*_OutlineFixRange4*/).x);
            tmp0.yw = tmp0.yy * tmp1.xy + float2((0.1 /*_OutlineFixRange1*/).x, (0.1 /*_OutlineFixRange2*/).x);
            tmp0.y = smoothstep(tmp0.y, tmp0.w, tmp0.z);
            tmp0.y = tmp0.y * v.v_col.z;
            tmp0.zw = v.v_col.zy > float2(0.0, 0.0);
            tmp0.y = tmp0.z ? tmp0.y : v.v_col.w;
            tmp0.z = v.v_col.y < 1.0;
            tmp0.z = tmp0.w ? tmp0.z : 0.0;
            tmp0.z = tmp0.z ? 1.0 : 0.0;
            tmp0.y = tmp0.z * (0.0 /*_FixLipOutline*/) + tmp0.y;
            tmp0.x = tmp0.y * tmp0.x;
            float3 outline_normal;
            outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
            outline_normal.z = -1;
            outline_normal.xyz = normalize(outline_normal.xyz);
            float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
            float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
            if(!(1.0 /*_EnableFOVWidth*/)) fov_width = 1;
            wv_pos.xyz = wv_pos + (outline_normal * fov_width * tmp0.x);
            o.pos = mul(UNITY_MATRIX_P, wv_pos);
        }
        else
        {
            float3 outline_normal;
            outline_normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);
            outline_normal.z = -1;
            outline_normal.xyz = normalize(outline_normal.xyz);
            float4 wv_pos = mul(UNITY_MATRIX_MV, v.vertex);
            float fov_width = 1.0f / (rsqrt(abs(wv_pos.z / unity_CameraProjection._m11)));
            if(!(1.0 /*_EnableFOVWidth*/))fov_width = 1;
            wv_pos.xyz = wv_pos + (outline_normal * fov_width * (v.v_col.w * (0.1 /*_OutlineWidth*/) * (0.187 /*_OutlineScale*/)));
            o.pos = mul(UNITY_MATRIX_P, wv_pos);
        }
    }
    o.uv = float4(v.uv_0, v.uv_1);
    o.v_col = v.v_col; 
    o.ws_pos = mul(unity_ObjectToWorld, v.vertex);
    o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
    if((0.0 /*_DissoveON*/) )
    {
        dissolve_vertex(v, o.dis_pos, o.dis_uv);
    }
    if(hide_parts(v.v_col) && !(1.0 /*_FaceMaterial*/) && ((0 /*_ShowPartID*/) != 0)) o.pos = float4(-99.0, -99.0, -99.0, 1.0);
    return o;
}
shadow_out vs_shadow(shadow_in v)
{
    shadow_out o = (shadow_out)0.0f; // initialize so no funny compile errors
    float3 view = _WorldSpaceCameraPos.xyz - (float3)mul(v.vertex.xyz, unity_ObjectToWorld);
    o.view = normalize(view);
    o.normal = mul((float3x3)unity_ObjectToWorld, v.normal);
    float4 pos_ws  = mul(unity_ObjectToWorld, v.vertex);
    o.ws_pos = pos_ws;
    float4 pos_wvp = mul(UNITY_MATRIX_VP, pos_ws);
    o.pos = pos_wvp;
    o.uv_a = float4(v.uv_0.xy, v.uv_1.xy);
    if((0.0 /*_DissoveON*/) )
    {
        dissolve_vertex(v, o.dis_pos, o.dis_uv);
    }
    if(hide_parts(v.v_col) && !(1.0 /*_FaceMaterial*/) && ((0 /*_ShowPartID*/) != 0)) o.pos = float4(-99.0, -99.0, -99.0, 1.0);
    o.hide = hide_parts(v.v_col) && !(1.0 /*_FaceMaterial*/) && ((0 /*_ShowPartID*/) != 0);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    return o;
} 
float4 ps_base(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float4 ws_pos = mul(unity_ObjectToWorld, i.ws_pos);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    UNITY_LIGHT_ATTENUATION(atten, i, ws_pos.xyz);
    float transparnecy_check = (0.0 /*_IsTransparent*/);
    float testTresh =(0.0 /*_AlphaTestThreshold*/);
    if((0.0 /*_IsTransparent*/)) testTresh = 0.0f;
    float3 normal    = normalize(i.normal);
    float3 vs_normal = normalize(mul((float3x3)UNITY_MATRIX_V, normal));
    float3 view      = normalize(i.view);
    float3 vs_view   = normalize(mul((float3x3)UNITY_MATRIX_V, view));
    float2 uv        = i.uv.xy;
    float4 vcol      = i.v_col;
    float3 light = _WorldSpaceLightPos0.xyz;
    float hair_alpha = 1.0f;
    float3 rim_light = (float3)0.0f;
    float3 specular = (float3)0.0f;
    float3 emission_color = (float3)0.0f;
    float emis_area = 0.0f;
    float3 test_normal = normal;
    float3 tangents = i.tangent.xyz;
    float4 color = ((0.0 /*_HairMaterial*/)) ? float4(1,1,1,1) * float4(1,1,1,1) : float4(1,1,1,1);
    if(!vface && (1.0 /*_backfdceuv2*/)) // use uv2 if vface is false
    { // so basically if its a backfacing face
        uv.xy = i.uv.zw;
        color = float4(1,1,1,1);
        normal.z = normal.z * -1.0f;
        tangents.z = tangents.z * -1.0f;
    }
    color.a = 1.0f; // this prevents issues with the alpha value of the material being less than 1
    if((0.0 /*_DissoveON*/))
    {
        dissolve_clip(ws_pos, i.dis_pos, i.dis_uv, uv);
    }
    float4 out_color = color;
    float3 half_vector = normalize(view + _WorldSpaceLightPos0);
    float ndotl = dot(normal, light);
    float ndoth = dot(normal, half_vector);
    float ndotv = dot(normal, view);
    float4 diffuse = _MainTex.Sample(sampler_MainTex, uv);
    float4 lightmap = _LightMap.Sample(sampler_linear_repeat, uv);
    float lightmap_alpha = _LightMap.Sample(sampler_linear_repeat, i.uv.xy).w;
    #if defined(faceishadow)
        float4 facemap = _FaceMap.Sample(sampler_linear_repeat, uv);
        float4 faceexp = _FaceExpression.Sample(sampler_linear_repeat, uv);
    #endif
    #if defined(use_emission)
        float4 emistex = _EmissionTex.Sample(sampler_linear_repeat, uv);
    #endif
    #if defined(second_diffuse)
        if((0.0 /*_UseSecondaryTex*/))
        {
            float4 secondary = _SecondaryDiff.Sample(sampler_linear_repeat, uv);
            diffuse = lerp(diffuse, secondary, (0.0 /*_SecondaryFade*/));
        }
    #endif
    #if defined(can_shift)
        float diffuse_mask = packed_channel_picker(sampler_linear_repeat, _HueMaskTexture, uv, (0.0 /*_DiffuseMaskSource*/));
        float rim_mask = packed_channel_picker(sampler_linear_repeat, _HueMaskTexture, uv, (0.0 /*_RimMaskSource*/));
        float emission_mask = packed_channel_picker(sampler_linear_repeat, _HueMaskTexture, uv, (0.0 /*_EmissionMaskSource*/));
        if(!(0.0 /*_UseHueMask*/)) 
        {
            diffuse_mask = 1.0f;
            rim_mask = 1.0f;
            emission_mask = 1.0f;
        }
    #endif
    float material_ID = floor(8.0f * lightmap.w);
    float ramp_ID     = ((material_ID * 2.0f + 1.0f) * 0.0625f);
    int curr_region = material_region(material_ID);
    float4 lut_speccol = _MaterialValuesPackLUT.Load(float4(material_ID, 0, 0, 0)); // xyz : color
    float4 lut_specval = _MaterialValuesPackLUT.Load(float4(material_ID, 1, 0, 0)); // x: shininess, y : roughness, z : intensity
    float4 lut_edgecol = _MaterialValuesPackLUT.Load(float4(material_ID, 2, 0, 0)); // xyz : color
    float4 lut_rimcol  = _MaterialValuesPackLUT.Load(float4(material_ID, 3, 0, 0)); // xyz : color
    float4 lut_rimval  = _MaterialValuesPackLUT.Load(float4(material_ID, 4, 0, 0)); // x : rim type, y : softness , z : dark
    float4 lut_rimscol = _MaterialValuesPackLUT.Load(float4(material_ID, 5, 0, 0)); // xyz : color
    float4 lut_rimsval = _MaterialValuesPackLUT.Load(float4(material_ID, 6, 0, 0)); // x: rim shadow width, y: rim shadow feather 
    float4 lut_bloomval = _MaterialValuesPackLUT.Load(float4(material_ID, 7, 0, 0)); // x: rim shadow width, y: rim shadow feather 
    #if defined (_IS_PASS_BASE)
        if(_EnableParticleSwirl)
        {
            swirl_dissolve(i, out_color);
        }
        float3 GI_color = DecodeLightProbe(normal);
        GI_color = GI_color < float3(1,1,1) ? GI_color : float3(1,1,1);
        float GI_intensity = 0.299f * GI_color.r + 0.587f * GI_color.g + 0.114f * GI_color.b;
        GI_intensity = GI_intensity < 1 ? GI_intensity : 1.0f;
        float3 ambient_color = max(half3(0.05f, 0.05f, 0.05f), max(ShadeSH9(half4(0.0, 0.0, 0.0, 1.0)),ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)).rgb));
        float3 light_color = max(ambient_color, _LightColor0.rgb);
        #if defined(use_rimlight)
            float rimwidth = (1.0 /*_RimWidth*/); 
            float2 rimoffset = float4(0,0,0,0);
            float2 esrimoffset = float4(0,0,0,0);
            if(isVR())
            {
                rimwidth = 0.5f;
                rimoffset = 0.0f;
                esrimoffset = 0.0f;
            }
            float4 rim_color[8] =
            {
                float4(1,1,1,1),
                float4(1,1,1,1),
                float4(1,1,1,1),
                float4(1,1,1,1), 
                float4(1,1,1,1),
                float4(1,1,1,1),
                float4(1,1,1,1),
                float4(1,1,1,1),   
            };
            float4 rim_values[8] = // x = width, y = softness, z = type, w = dark
            {
                float4(_RimWidth0, (0.1 /*_RimEdgeSoftness0*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark0*/))),
                float4(_RimWidth1, (0.1 /*_RimEdgeSoftness1*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark1*/))),
                float4(_RimWidth2, (0.1 /*_RimEdgeSoftness2*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark2*/))),
                float4(_RimWidth3, (0.1 /*_RimEdgeSoftness3*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark3*/))),
                float4(_RimWidth4, (0.1 /*_RimEdgeSoftness4*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark4*/))),
                float4(_RimWidth5, (0.1 /*_RimEdgeSoftness5*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark5*/))),
                float4(_RimWidth6, (0.1 /*_RimEdgeSoftness6*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark6*/))),
                float4(_RimWidth7, (0.1 /*_RimEdgeSoftness7*/), (1.0 /*_RimType0*/), saturate((0.5 /*_RimDark7*/))),
            }; // they have unused id specific rim widths but just in case they do end up using them in the future ill leave them be here
            if((0.0 /*_UseMaterialValuesLUT*/)) 
            {    
                rim_values[curr_region].yzw = lut_rimval.yxz; 
            }
            float2 screen_pos = i.ss_pos.xy / i.ss_pos.w;
            float3 wvp_pos = mul(UNITY_MATRIX_VP, ws_pos);
            float camera_dist = saturate(1.0f / distance(_WorldSpaceCameraPos.xyz, ws_pos));
            float fov = extract_fov();
            fov = clamp(fov, 0, 150);
            float range = fov_range(0, 180, fov);
            float width_depth = camera_dist / range;
            rimwidth = rimwidth * 0.25f;
            float rim_width = lerp(rimwidth * 0.5f, rimwidth * 0.45f, range) * width_depth;
            if(isVR())
            {
                rim_width = rim_width * 0.66f;
            }
            float org_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_pos.xy), screen_pos);
            float rim_side = (ws_pos.z * -vs_normal.x) - (ws_pos.x * -vs_normal.z);
            rim_side = (rim_side > 0.0f) ? 0.0f : 1.0f;
            float2 offset_uv = esrimoffset.xy - rimoffset.xy;
            offset_uv.x = lerp(offset_uv.x, -offset_uv.x, rim_side);
            float2 offset = ((rim_width * vs_normal) * 0.0055f);
            offset_uv.x = screen_pos.x + ((offset_uv.x * 0.01f + offset.x));
            offset_uv.y = screen_pos.y + (offset_uv.y * 0.01f + offset.y);
            float offset_depth = GetLinearZFromZDepth_WorksWithMirrors(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, offset_uv.xy), offset_uv);
            float rim_depth = (offset_depth - org_depth);
            rim_depth = pow(rim_depth, rim_values[curr_region].w); 
            rim_depth = smoothstep(0.0f, rim_width, rim_depth);
            rim_depth = rim_depth * saturate(lerp(1.0f, lightmap.r, (1.0 /*_RimLightMode*/)));
            if((0.0 /*_EnableRimLight*/)) rim_light = (rim_color[curr_region].xyz * rim_depth * (1.0 /*_Rimintensity*/)) * (0.1 /*_ES_Rimintensity*/) * max(0.5f, camera_dist) * saturate(vface);
            #if defined(can_shift)
                if((1.0 /*_EnableRimHue*/)) rim_light.xyz = hue_shift(rim_light.xyz, curr_region, (0.0 /*_RimHue*/), (0.0 /*_RimHue2*/), (0.0 /*_RimHue3*/), (0.0 /*_RimHue4*/), (0.0 /*_RimHue5*/), (0.0 /*_RimHue6*/), (0.0 /*_RimHue7*/), (0.0 /*_RimHue8*/), (0.0 /*_GlobalRimHue*/), (0.0 /*_AutomaticRimShift*/), (0.0 /*_ShiftRimSpeed*/), rim_mask);
            #endif
        #else
            rim_light = (float3)0.0f;
        #endif
        float unity_shadow = 1.0f;
        #if defined(self_shading)
            unity_shadow = SHADOW_ATTENUATION(i);
            unity_shadow = smoothstep(0.f, 1.f, unity_shadow);
            if(!(0.0 /*_UseSelfShadow*/)) 
            {
                unity_shadow = 1.f;
            }
        #endif
        float4 emission = diffuse.xyzw;
        #if defined(use_emission)
            if( (0 /*_EnableEmission*/) == 2)
            {
                emission.w = emistex.x;
            }
            emis_area = (emission.w - (0.5 /*_EmissionThreshold*/)) / max(0.001f, 1.0f - (0.5 /*_EmissionThreshold*/));
            emis_area = ((0.5 /*_EmissionThreshold*/) < emission.w * emistex.w) ? emis_area : 0.0f;
            emis_area = saturate(emis_area) * (0 /*_EnableEmission*/);
            emission_color = (1.0 /*_EmissionIntensity*/) * (emission.xyz * float4(1,1,1,1).xyz);
            #if defined(can_shift)
                if((1.0 /*_EnableEmissionHue*/)) emission_color.xyz =  hue_shift(emission_color.xyz, curr_region, (0.0 /*_EmissionHue*/), (0.0 /*_EmissionHue2*/), (0.0 /*_EmissionHue3*/), (0.0 /*_EmissionHue4*/), (0.0 /*_EmissionHue5*/), (0.0 /*_EmissionHue6*/), (0.0 /*_EmissionHue7*/), (0.0 /*_EmissionHue8*/), (0.0 /*_GlobalEmissionHue*/), (0.0 /*_AutomaticEmissionShift*/), (0.0 /*_ShiftEmissionSpeed*/), emission_mask);
            #endif
                if((1.0 /*_FaceMaterial*/))
            {
                #if defined(faceishadow)
                    float eye_emis = (facemap.x > 0.45f) && (facemap.x < 0.55f);
                    emis_area = emis_area + eye_emis;
                #endif
            }
        #endif
        float4 mat_color[8] = 
        {
            float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), float4(1,1,1,1), 
        };
        if(!(0.0 /*_HairMaterial*/))out_color = out_color * mat_color[material_ID];
        float3 shadow_color = (float3)1.0f;
        float shadow_area = 1.0f;
        #if defined(use_shadow)
            if((0.0 /*_EnableShadow*/) == 1)
            {
                shadow_area = shadow_rate((ndotl), (lightmap.y), vcol.x, (1.0 /*_ShadowRamp*/));
                if((0.0 /*_BaseMaterial*/)) shadow_area = lerp((0.0 /*_SelfShadowDarken*/), shadow_area, unity_shadow);
                float2 ramp_uv = {shadow_area, ramp_ID};
                float3 warm_ramp = _DiffuseRampMultiTex.Sample(sampler_linear_clamp, ramp_uv).xyz; 
                float3 cool_ramp = _DiffuseCoolRampMultiTex.Sample(sampler_linear_clamp, ramp_uv).xyz;
                shadow_color = lerp(warm_ramp, cool_ramp, 0.0f);
                #if defined(faceishadow)
                    if((1.0 /*_FaceMaterial*/))
                    {
                        float face_sdf_right = _FaceMap.Sample(sampler_linear_repeat, uv).w;
                        float face_sdf_left  = _FaceMap.Sample(sampler_linear_repeat, float2(1.0f - uv.x, uv.y)).w;
                        shadow_area = shadow_rate_face(uv, light);
                        shadow_color = lerp(float4(0.2140411,0.2140411,0.2140411,1), 1.0f, shadow_area);
                    }
                #endif
                if ((0.0 /*_ES_LEVEL_ADJUST_ON*/))
                {
                    float isSkin = (material_ID < 1) ? 0.0 : 1.0;
                    isSkin = ((1.0 /*_FaceMaterial*/)) ? 0.0 : isSkin;
                    isSkin = ((0.0 /*_HairMaterial*/)) ? 1.0 : isSkin;
                    float3 skinLightColorAdjustment = (float3)0.0;
                    float3 highlightColorAdjustment = (float3)0.0;
                    float3 skinShadowColorAdjustment = (float3)0.0;
                    float3 shadowColorAdjustment = (float3)0.0;
                    float3 isSkinVector = (float3)isSkin;
                    float3 tempAdjustment = (float3)0.0;
                    skinLightColorAdjustment = float4(1,1,1,0.5).www * float4(1,1,1,0.5).xyz;
                    skinLightColorAdjustment *= 2.0;
                    highlightColorAdjustment = float4(1,1,1,0.5).www * float4(1,1,1,0.5).xyz;
                    highlightColorAdjustment = (highlightColorAdjustment * 2.0) - skinLightColorAdjustment;
                    skinLightColorAdjustment = (isSkinVector * highlightColorAdjustment) + skinLightColorAdjustment;
                    skinLightColorAdjustment = max(skinLightColorAdjustment, 0.01f);
                    skinShadowColorAdjustment = float4(1,1,1,0.5).www * float4(1,1,1,0.5).xyz;
                    skinShadowColorAdjustment *= 2.0;
                    shadowColorAdjustment = float4(1,1,1,0.5).www * float4(1,1,1,0.5).xyz;
                    shadowColorAdjustment = (shadowColorAdjustment * 2.0) - skinShadowColorAdjustment;
                    skinShadowColorAdjustment = (isSkinVector * shadowColorAdjustment) + skinShadowColorAdjustment;
                    skinShadowColorAdjustment = max(skinShadowColorAdjustment, 0.01f);
                    shadowColorAdjustment = shadow_color.xyz - (float3((0.55 /*_ES_LevelMid*/), (0.55 /*_ES_LevelMid*/), (0.55 /*_ES_LevelMid*/)));
                    tempAdjustment.xz = float2((1.0 /*_ES_LevelHighLight*/), (0.55 /*_ES_LevelMid*/)) - float2((0.55 /*_ES_LevelMid*/), (0.0 /*_ES_LevelShadow*/));
                    shadowColorAdjustment /= tempAdjustment.xxx;
                    shadowColorAdjustment = (shadowColorAdjustment * 0.5) + 0.5;
                    shadowColorAdjustment = clamp(shadowColorAdjustment, 0.0, 1.0);
                    skinLightColorAdjustment *= shadowColorAdjustment;
                    shadowColorAdjustment = -shadow_color.xyz + float3((0.55 /*_ES_LevelMid*/), (0.55 /*_ES_LevelMid*/), (0.55 /*_ES_LevelMid*/));
                    shadowColorAdjustment /= tempAdjustment.zzz;
                    shadowColorAdjustment = (-shadowColorAdjustment * 0.5) + 0.5;
                    shadowColorAdjustment = clamp(shadowColorAdjustment, 0.0, 1.0);
                    skinShadowColorAdjustment *= shadowColorAdjustment;
                    shadow_color.xyz = (shadow_area < 0.9f) ? skinLightColorAdjustment : skinShadowColorAdjustment;
                }
            }
        #endif
        #if defined(use_specular)
            if((0.0 /*_EnableSpecular*/))
            {
                float4 specular_color[8] =
                {
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                    float4(1,1,1,1),
                };
                float3 specular_values[8] =
                {
                    float3((10.0 /*_SpecularShininess0*/), (0.02 /*_SpecularRoughness0*/), (1.0 /*_SpecularIntensity0*/)),
                    float3((10.0 /*_SpecularShininess1*/), (0.02 /*_SpecularRoughness1*/), (1.0 /*_SpecularIntensity1*/)),
                    float3((10.0 /*_SpecularShininess2*/), (0.02 /*_SpecularRoughness2*/), (1.0 /*_SpecularIntensity2*/)),
                    float3((10.0 /*_SpecularShininess3*/), (0.02 /*_SpecularRoughness3*/), (1.0 /*_SpecularIntensity3*/)),
                    float3((10.0 /*_SpecularShininess4*/), (0.02 /*_SpecularRoughness4*/), (1.0 /*_SpecularIntensity4*/)),
                    float3((10.0 /*_SpecularShininess5*/), (0.02 /*_SpecularRoughness5*/), (1.0 /*_SpecularIntensity5*/)),
                    float3((10.0 /*_SpecularShininess6*/), (0.02 /*_SpecularRoughness6*/), (1.0 /*_SpecularIntensity6*/)),
                    float3((10.0 /*_SpecularShininess7*/), (0.02 /*_SpecularRoughness7*/), (1.0 /*_SpecularIntensity7*/)),
                };
                if((0.0 /*_UseMaterialValuesLUT*/))
                {
                    specular_color[curr_region] = lut_speccol;
                    specular_values[curr_region] = lut_specval.xyz * float3(10.0f, 2.0f, 2.0f); // weird fix, not accurate to ingame code but whatever if it works it works
                }
                if((1.0 /*_FaceMaterial*/))
                {
                    specular_color[curr_region] = (float4)0.0f;
                }
                specular_values[curr_region].z = max(0.0f, specular_values[curr_region].z); // why would there ever be a reason for a negative specular intensity
                specular = specular_base(shadow_area, ndoth, lightmap.z, specular_color[curr_region], specular_values[curr_region], float4(1,1,1,1), (0.5 /*_ES_SPIntensity*/));
            }
          #endif
        #if defined(use_stocking)
            float2 tile_uv = uv.xy * float4(1,1,0,0).xy + float4(1,1,0,0).zw;
            float stock_tile = _StockRangeTex.Sample(sampler_linear_repeat, tile_uv).z; 
            stock_tile = stock_tile * 0.5f - 0.5f;
            stock_tile = (1.0 /*_StockRoughness*/) * stock_tile + 1.0f;
            float4 stocking_tex = _StockRangeTex.Sample(sampler_linear_repeat, uv.xy);
            float stock_area = (stocking_tex.x > 0.001f) ? 1.0f : 0.0f;
            float offset_ndotv = dot(normal, normalize(view - float4(0,0,0,0)));
            float stock_rim = max(0.001f, ndotv);
            float stock_power = max(0.039f, (1.0 /*_Stockpower*/));
            stock_rim = smoothstep(stock_power, (0.5 /*_StockDarkWidth*/) * stock_power, stock_rim) * (0.25 /*_StockSP*/);
            stocking_tex.x = stocking_tex.x * stock_area * stock_rim;
            float3 stock_dark_area = (float3)-1.0f * float4(1,1,1,1);
            stock_dark_area = stocking_tex.x * stock_dark_area + (float3)1.0f;
            stock_dark_area = diffuse.xyz * stock_dark_area + (float3)-1.0f;
            stock_dark_area = stocking_tex.x * stock_dark_area + (float3)1.0f;
            float3 stock_darkened = stock_dark_area * diffuse.xyz;
            float stock_spec = (1.0f - (0.25 /*_StockSP*/)) * (stocking_tex.y * stock_tile);
            stock_rim = saturate(max(0.004f, pow(ndotv, (1.0 /*_Stockpower1*/))) * stock_spec);
            float3 stocking = -diffuse.xyz * stock_dark_area + float4(1,1,1,1);
            stocking = stock_rim * stocking + stock_darkened;
        #endif
        #if defined(faceishadow)
            float3 nose_view = view;
            nose_view.y = nose_view.y * 0.5f;
            float nose_ndotv = max(dot(nose_view, normal), 0.0001f);
            float nose_power = max((1.0 /*_NoseLinePower*/) * 8.0f, 0.1f);
            nose_ndotv = pow(nose_ndotv, nose_power);
            float nose_area = facemap.z * nose_ndotv;
            nose_area = (nose_area > 0.1f) ? 1.0f : 0.0f;
            float3 expressions = 1.0f;
            float cheek_threshold = (0.5 /*_ExMapThreshold*/) < faceexp.x ? (faceexp.x - (0.5 /*_ExMapThreshold*/)) / (1.0f - (0.5 /*_ExMapThreshold*/)) : 0.0f;
            expressions = lerp((float3)1.0f, float4(1,1,1,1), cheek_threshold * (0.0 /*_ExCheekIntensity*/));
            float exp_shy = faceexp.y * (0.0 /*_ExShyIntensity*/);
            expressions = lerp(expressions, float4(1,1,1,1), exp_shy);
            float3 exp_shadow = faceexp.z * (0.0 /*_ExShadowIntensity*/);
            expressions = lerp(expressions, float4(1,1,1,1), exp_shadow);
            if((1.0 /*_FaceMaterial*/))
            {
                diffuse.xyz = lerp(diffuse.xyz, float4(1,1,1,1), nose_area); 
                diffuse.xyz = diffuse.xyz * expressions;
            } 
        #endif
        #if defined(use_stocking)
            if((0.0 /*_EnableStocking*/)) diffuse.xyz = stocking;
        #endif
        out_color = ((0.0 /*_StarrySky*/) && !(1.0 /*_FaceMaterial*/) && !(0.0 /*_HairMaterial*/)) ? starry_sky(diffuse, out_color, uv) : out_color * diffuse;
        if((0.0 /*_EnableAlphaCutoff*/)) clip(diffuse.w - saturate(testTresh));
        #if defined(use_shadow)
            out_color.xyz = ((0.0 /*_EnableShadow*/) == 1) ? out_color * shadow_color : out_color; 
        #endif
        #if defined(use_specular)
            out_color.xyz = ((0.0 /*_EnableSpecular*/) == 1) ? out_color + specular : out_color; 
        #endif
        #if defined(can_shift)
            if((1.0 /*_EnableColorHue*/)) out_color.xyz = hue_shift(out_color.xyz, curr_region, (0.0 /*_ColorHue*/), (0.0 /*_ColorHue2*/), (0.0 /*_ColorHue3*/), (0.0 /*_ColorHue4*/), (0.0 /*_ColorHue5*/), (0.0 /*_ColorHue6*/), (0.0 /*_ColorHue7*/), (0.0 /*_ColorHue8*/), (0.0 /*_GlobalColorHue*/), (0.0 /*_AutomaticColorShift*/), (0.0 /*_ShiftColorSpeed*/), diffuse_mask);
        #endif
        #if defined(use_emission)
            if((0 /*_EnableEmission*/) > 0) out_color.xyz = emis_area * (out_color.xyz * emission_color) + out_color.xyz;
        #endif
        #if defined(use_rimlight)
            if(!(1.0 /*_FaceMaterial*/) && (0.0 /*_EnableRimLight*/)) out_color.xyz = lerp(out_color.xyz.xyz - rim_light.xyz, out_color.xyz + rim_light.xyz, rim_values[curr_region].z);
        #endif
        if((0.0 /*_StarrySky*/)) out_color = starry_cloak(i.ss_pos, i.view, uv, i.ws_pos, tangents, out_color);
        if(!(0.0 /*_IsTransparent*/) && !(0.0 /*_EnableAlphaCutoff*/)) out_color.w = 1.0f;
        if((0.0 /*_EyeShadowMat*/)) out_color = float4(1,1,1,1);
        float3 up      = UnityObjectToWorldDir(float4(0,1,0,0).xyz);
        float3 forward = UnityObjectToWorldDir(float4(0,0,1,0).xyz);
        float3 right   = UnityObjectToWorldDir(float4(-1,0,0,0).xyz);
        float3 view_xz = normalize(view - dot(view, up) * up);
        float cosxz    = max(0.0f, dot(view_xz, forward));
        float alpha_a  = saturate((1.0f - cosxz) / 0.658f);
        float3 view_yz = normalize(view - dot(view, right) * right);
        float cosyz    = max(0.0f, dot(view_yz, forward));
        float alpha_b  = saturate((1.0f - cosyz) / 0.293f);
        #if defined(use_caustic)
            if((0.0 /*_CausToggle*/))
            {
                float2 caus_uv = ws_pos.xy;
                caus_uv.x = caus_uv.x + ws_pos.z; 
                if((0.0 /*_CausUV*/)) caus_uv = uv;
                float2 caus_uv_a = float4(1,1,0,0).xy * caus_uv + float4(1,1,0,0).zw;
                float2 caus_uv_b = float4(1,1,0,0).xy * caus_uv + float4(1,1,0,0).zw;
                caus_uv_a = (1.0 /*_CausSpeedA*/) * _Time.yy + caus_uv_a;
                caus_uv_b = (1.0 /*_CausSpeedB*/) * _Time.yy + caus_uv_b;
                float3 caus_a = (float3)0.0f;
                float3 caus_b = (float3)0.0f;
                if((0.0 /*_EnableSplit*/))
                {
                    float caus_a_r = _CausTexture.Sample(sampler_linear_repeat, caus_uv_a + float2((0.0 /*_CausSplit*/), (0.0 /*_CausSplit*/))).x;
                    float caus_a_g = _CausTexture.Sample(sampler_linear_repeat, caus_uv_a + float2((0.0 /*_CausSplit*/), -(0.0 /*_CausSplit*/))).x;
                    float caus_a_b = _CausTexture.Sample(sampler_linear_repeat, caus_uv_a + float2(-(0.0 /*_CausSplit*/), -(0.0 /*_CausSplit*/))).x;
                    float caus_b_r = _CausTexture.Sample(sampler_linear_repeat, caus_uv_b + float2((0.0 /*_CausSplit*/), (0.0 /*_CausSplit*/))).x;
                    float caus_b_g = _CausTexture.Sample(sampler_linear_repeat, caus_uv_b + float2((0.0 /*_CausSplit*/), -(0.0 /*_CausSplit*/))).x;
                    float caus_b_b = _CausTexture.Sample(sampler_linear_repeat, caus_uv_b + float2(-(0.0 /*_CausSplit*/), -(0.0 /*_CausSplit*/))).x;
                    caus_a = float3(caus_a_r, caus_a_g, caus_a_b);
                    caus_b = float3(caus_b_r, caus_b_g, caus_b_b);
                }
                else
                {
                    caus_a = _CausTexture.Sample(sampler_linear_repeat, caus_uv_a).xxx;
                    caus_b = _CausTexture.Sample(sampler_linear_repeat, caus_uv_b).xxx;
                }
                float3 caus = min(caus_a, caus_b);  
                caus = pow(caus, (1.0 /*_CausExp*/)) * float4(1,1,1,1) * (1.0 /*_CausInt*/);      
                out_color.xyz = out_color.xyz + caus;
            }   
        #endif 
        float filter = 1.0f;
        if((0.0 /*_StarrySky*/) && !(1.0 /*_StarAffectedByLight*/))
        {
            filter = saturate(1.0f - (_SkyMask.Sample(sampler_linear_repeat, uv * float4(1,1,0,0).xy + float4(1,1,0,0).zw).x + (0.0 /*_SkyRange*/)));
        }
        float3 light_applied_color = out_color.xyz * light_color;
        light_applied_color.xyz = light_applied_color.xyz + (GI_color * GI_intensity * _GI_Intensity * smoothstep(1.0f ,0.0f, GI_intensity / 2.0f));
        out_color.xyz = lerp(out_color.xyz, light_applied_color, filter);
        float shadow_mask = (dot(normal, light) * .5 + .5);
        shadow_mask = smoothstep(0.5, 0.7, shadow_mask);
        #if defined (_is_shadow)
            float shadow_view = 1.0f - dot(normal, view);
            shadow_view = smoothstep(0.4f, 0.5f, shadow_view);
            float mask = saturate( (1. - shadow_mask));
            float vertex_mask = (i.vertex.z * 0.5f + 0.5f);
            vertex_mask = step((1.0f - vertex_mask), 0.54);
            clip(vertex_mask - 0.01);
            out_color.xyz = lerp(saturate(float4(0.2140411,0.2140411,0.2140411,1)), 1.0f, mask);
            if(!_HairMaterial||!(0.0 /*_UseSelfShadow*/)) clip(-1);
        #endif
        if((0.0 /*_UseHeightLerp*/)) heightlightlerp(ws_pos, out_color);
        if((0.0 /*_DebugMode*/) && ((0.0 /*_DebugLights*/) == 1)) out_color.xyz = 0.0f;
    #endif
    #if defined (_IS_PASS_LIGHT)
        if((1.0 /*_FaceMaterial*/)) normal = float3(0.5f, 0.5f, 1.0f);
        #if defined(POINT) || defined(SPOT)
            light = normalize(_WorldSpaceLightPos0.xyz - i.ws_pos.xyz);
        #endif
        ndotl = dot(normal, light);
        float3 shadow_area = (float3)1.0f;
        shadow_area = shadow_rate(ndotl, lightmap.y, i.v_col.x, 1.0f);
        #if defined(faceishadow)
            ndotl = dot(float3(0.5f, 0.5f, 1.0f), light);
            if((1.0 /*_FaceMaterial*/)) shadow_area = ndotl;
        #endif
        float light_intesnity = max(0.001f, (0.299f * _LightColor0.r + 0.587f * _LightColor0.g + 0.114f * _LightColor0.b));
        float3 light_pass_color = ((diffuse.xyz * 1.0f) * _LightColor0.xyz) * atten * saturate(shadow_area);
        float3 light_color = lerp(light_pass_color.xyz, lerp(0.0f, min(light_pass_color, light_pass_color / light_intesnity), _WorldSpaceLightPos0.w), (1.0 /*_FilterLight*/)); // prevents lights from becoming too intense
        #if defined(POINT) || defined(SPOT)
        out_color.xyz = (light_color);
        #elif defined(DIRECTIONAL)
        out_color.xyz = 0.0f; // dont let extra directional lights add onto the model, this will fuck a lot of shit up
        #endif
    #endif
    #if defined (is_stencil) // so the hair and eyes dont lose their shading
        if((0.0 /*_EnableStencil*/))
        {
            if((1.0 /*_FaceMaterial*/))
            {
                #if defined(faceishadow)
                float side_mask = 1.0f;
                if((0 /*_HairSideChoose*/) == 1) side_mask = saturate(step(0, i.vertex.x));
                if((0 /*_HairSideChoose*/) == 2) side_mask = saturate(step(i.vertex.x, 0));
                float stencil_mask = facemap.y;
                if((2.0 /*_UseDifAlphaStencil*/) == 1) stencil_mask.x = diffuse.w;
                if((2.0 /*_UseDifAlphaStencil*/) == 2) stencil_mask.x = stencil_mask.x + diffuse.w;       
                float hair_blend = max(0.02, (0.5 /*_HairBlendSilhouette*/));
                clip(saturate(stencil_mask) * side_mask - hair_blend); // it is not accurate to use the diffuse alpha channel in this step
                #endif
            } 
            else if((0.0 /*_HairMaterial*/))
            {
                float3 up      = UnityObjectToWorldDir(float4(0,1,0,0).xyz);
                float3 forward = UnityObjectToWorldDir(float4(0,0,1,0).xyz);
                float3 right   = UnityObjectToWorldDir(float4(-1,0,0,0).xyz);
                float3 view_xz = normalize(view - dot(view, up) * up);
                float cosxz    = max(0.0f, dot(view_xz, forward));
                float alpha_a  = saturate((1.0f - cosxz) / 0.658f);
                float3 view_yz = normalize(view - dot(view, right) * right);
                float cosyz    = max(0.0f, dot(view_yz, forward));
                float alpha_b  = saturate((1.0f - cosyz) / 0.293f);
                float hair_blend = max(0.0, (0.5 /*_HairBlendSilhouette*/));
                hair_alpha = max(alpha_a, alpha_b);
                hair_alpha = ((0.0 /*_UseHairSideFade*/)) ? max(max(hair_alpha, hair_blend), 0.0f) : hair_blend;
                float side_mask = 1.0f;
                if((0 /*_HairSideChoose*/) == 1) side_mask = saturate(step(0, i.vertex.x));
                if((0 /*_HairSideChoose*/) == 2) side_mask = saturate(step(i.vertex.x, 0));
                hair_alpha = hair_alpha * saturate(side_mask);
                out_color.w = hair_alpha;
            }
            else
            {
                discard;
            }
        }
        else
        {
            discard;
        }
    #endif
    #if defined(debug_mode)
        if((0.0 /*_DebugMode*/))
        {
            if((0.0 /*_DebugDiffuse*/) == 1) return float4(diffuse.xyz, 1.0f);  
            if((0.0 /*_DebugDiffuse*/) == 2) return float4(diffuse.www, 1.0f);
            if((0.0 /*_DebugLightMap*/) == 1) return float4(lightmap.xxx, 1.0f);  
            if((0.0 /*_DebugLightMap*/) == 2) return float4(lightmap.yyy, 1.0f);  
            if((0.0 /*_DebugLightMap*/) == 3) return float4(lightmap.zzz, 1.0f);  
            if((0.0 /*_DebugLightMap*/) == 4) return float4(lightmap.www, 1.0f);  
            #if defined(faceishadow)
            if((0.0 /*_DebugFaceMap*/) == 1) return float4(facemap.xxx, 1.0f);  
            if((0.0 /*_DebugFaceMap*/) == 2) return float4(facemap.yyy, 1.0f);  
            if((0.0 /*_DebugFaceMap*/) == 3) return float4(facemap.zzz, 1.0f);  
            if((0.0 /*_DebugFaceMap*/) == 4) return float4(facemap.www, 1.0f);  
            if((0.0 /*_DebugFaceExp*/) == 1) return float4(faceexp.xxx, 1.0f);  
            if((0.0 /*_DebugFaceExp*/) == 2) return float4(faceexp.yyy, 1.0f);  
            if((0.0 /*_DebugFaceExp*/) == 3) return float4(faceexp.zzz, 1.0f);  
            if((0.0 /*_DebugFaceExp*/) == 4) return float4(faceexp.www, 1.0f); 
            #endif
            if((0.0 /*_DebugMLut*/)) // because of the nature of the mluts i had to expand the debugging like this 
            {
                float4 mlutdebug[8] =
                {
                    lut_speccol,
                    lut_specval, 
                    lut_edgecol,
                    lut_rimcol,
                    lut_rimval,
                    lut_rimscol,
                    lut_rimsval,
                    lut_bloomval
                };
                if((0.0 /*_DebugMLutChannel*/) == 1) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1].xxx, 1.0f);
                if((0.0 /*_DebugMLutChannel*/) == 2) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1].yyy, 1.0f);
                if((0.0 /*_DebugMLutChannel*/) == 3) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1].zzz, 1.0f);
                if((0.0 /*_DebugMLutChannel*/) == 4) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1].www, 1.0f);
                if((0.0 /*_DebugMLutChannel*/) == 5) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1].xyz, 1.0f);
                if((0.0 /*_DebugMLutChannel*/) == 6) return float4(mlutdebug[(0.0 /*_DebugMLut*/) - 1]);
            }
            if((0.0 /*_DebugVertexColor*/) == 1) return float4(i.v_col.xxx, 1.0f);
            if((0.0 /*_DebugVertexColor*/) == 2) return float4(i.v_col.yyy, 1.0f);
            if((0.0 /*_DebugVertexColor*/) == 3) return float4(i.v_col.zzz, 1.0f);
            if((0.0 /*_DebugVertexColor*/) == 4) return float4(i.v_col.www, 1.0f);
            if((0.0 /*_DebugRimLight*/) == 1) return float4(rim_light.xyz, 1.0f);
            if((0.0 /*_DebugNormalVector*/) == 1) return float4(normal.xyz * 0.5f + 0.5f, 1.0f);
            if((0.0 /*_DebugNormalVector*/) == 2) return float4(normal.xyz, 1.0f);
            if((0.0 /*_DebugTangent*/) == 1) return float4(i.tangent.xyz, 1.0f);
            if((0.0 /*_DebugSpecular*/) == 1) return float4(specular.xyz, 1.0f);
            if((0.0 /*_DebugEmission*/) == 1) return float4(emis_area.xxx, 1.0f);
            if((0.0 /*_DebugEmission*/) == 2) return float4(emission_color.xyz, 1.0f);
            if((0.0 /*_DebugEmission*/) == 3) return float4(emission_color.xyz * emis_area, 1.0f);
            if(((0.0 /*_DebugMaterialIDs*/) > 0) && ((0.0 /*_DebugMaterialIDs*/) != 9))
            {
                curr_region = curr_region + 1.0f;
                if((0.0 /*_DebugMaterialIDs*/) == curr_region)
                {
                    return (float4)1.0f;
                }
                else 
                {
                    return float4((float3)0.0f, 1.0f);
                }
            }
            if((0.0 /*_DebugMaterialIDs*/) == 9)
            {
                float4 debug_color = float4(0.0f, 0.0f, 0.0f, 1.0f);
                if(curr_region == 0)
                {
                    debug_color.xyz = float3(1.0f, 0.0f, 0.0f);
                }
                else if(curr_region == 1)
                {
                    debug_color.xyz = float3(0.0f, 1.0f, 0.0f);
                }
                else if(curr_region == 2)
                {
                    debug_color.xyz = float3(0.0f, 0.0f, 1.0f);
                }
                else if(curr_region == 3)
                {
                    debug_color.xyz = float3(1.0f, 0.0f, 1.0f);
                }
                else if(curr_region == 4)
                {
                    debug_color.xyz = float3(0.0f, 1.0f, 1.0f);
                }
                else if(curr_region == 5)
                {
                    debug_color.xyz = float3(1.0f, 1.0f, 0.0f);
                }
                else if(curr_region == 6)
                {
                    debug_color.xyz = float3(1.0f, 1.0f, 1.0f);
                }
                else if(curr_region == 7)
                {
                    debug_color.xyz = float3(0.0f, 0.0f, 0.0f);
                }
                return debug_color;
            }
            if((0.0 /*_DebugFaceVector*/) == 1) return float4(UnityObjectToWorldDir(float4(0,0,1,0).xyz), 1.0f);
            if((0.0 /*_DebugFaceVector*/) == 2) return float4(UnityObjectToWorldDir(float4(-1,0,0,0).xyz), 1.0f);
            if((0.0 /*_DebugFaceVector*/) == 3) return float4(UnityObjectToWorldDir(float4(0,1,0,0).xyz), 1.0f);
            if((0.0 /*_DebugHairFade*/) == 1) return float4(hair_alpha.xxx, 1.0f); 
        } 
    #endif
    #if defined(can_dissolve)
    if((0.0 /*_DissoveON*/))
    {
        dissolve_color(ws_pos, i.dis_pos, i.dis_uv, uv, diffuse, out_color);
    }
    #endif
    return out_color;
}
float4 ps_edge(vs_out i, bool vface : SV_IsFrontFace) : SV_Target
{
    float4 ws_pos = mul(unity_ObjectToWorld, i.ws_pos);
    float2 uv  = i.uv.xy;
    #if defined(can_dissolve)
    if((0.0 /*_DissoveON*/))
    {
        dissolve_clip(ws_pos, i.dis_pos, i.dis_uv, uv);
    }
    #endif
    float lightmap = _LightMap.Sample(sampler_linear_repeat, uv).w;
    float alpha = _MainTex.Sample(sampler_MainTex, uv).w;
    float3 GI_color = DecodeLightProbe(normalize(i.normal));
    GI_color = GI_color < float3(1,1,1) ? GI_color : float3(1,1,1);
    float GI_intensity = 0.299f * GI_color.r + 0.587f * GI_color.g + 0.114f * GI_color.b;
    GI_intensity = GI_intensity < 1 ? GI_intensity : 1.0f;  
    GI_color = (GI_color * GI_intensity * _GI_Intensity * smoothstep(1.0f ,0.0f, GI_intensity / 2.0f));
    float3 ambient_color = max(half3(0.05f, 0.05f, 0.05f), max(ShadeSH9(half4(0.0, 0.0, 0.0, 1.0)),ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)).rgb));
    float3 light_color = max(ambient_color, _LightColor0.rgb);
    int material_ID = floor(lightmap * 8.0f);
    int material = material_region(material_ID);
    float4 outline_color[8] =
    {
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
        float4(0,0,0,1),
    };
    if((0.0 /*_UseMaterialValuesLUT*/)) outline_color[material] = _MaterialValuesPackLUT.Load(float4(material_ID, 2, 0, 0));
    float4 out_color = outline_color[material];
    if((1.0 /*_FaceMaterial*/)) out_color = float4(0,0,0,1);
    out_color.a = 1.0f;
    #if defined(can_shift)
        float outline_mask = packed_channel_picker(sampler_linear_repeat, _HueMaskTexture, uv, (0.0 /*_OutlineMaskSource*/));
        if(!(0.0 /*_UseHueMask*/)) outline_mask = 1.0f;
        if((1.0 /*_EnableOutlineHue*/)) out_color.xyz = hue_shift(out_color.xyz, material, (0.0 /*_OutlineHue*/), (0.0 /*_OutlineHue2*/), (0.0 /*_OutlineHue3*/), (0.0 /*_OutlineHue4*/), (0.0 /*_OutlineHue5*/), (0.0 /*_OutlineHue6*/), (0.0 /*_OutlineHue7*/), (0.0 /*_OutlineHue8*/), (0.0 /*_GlobalOutlineHue*/), (0.0 /*_AutomaticOutlineShift*/), (0.0 /*_ShiftOutlineSpeed*/), outline_mask);
    #endif
    out_color.xyz = out_color.xyz * light_color + GI_color;
    #if defined(can_dissolve)
        if((0.0 /*_DissoveON*/))
        {
            dissolve_color(ws_pos, i.dis_pos, i.dis_uv, uv, out_color, out_color); 
        }
    #endif
    if(i.v_col.w < 0.05f) clip(-1); // discard all pixels with the a vertex color alpha value of less than 0.05f
    if((0.0 /*_EnableAlphaCutoff*/)) clip(alpha - (0.0 /*_AlphaCutoff*/));
    return out_color;
}
float4 ps_shadow(shadow_out i, bool vface : SV_ISFRONTFACE) : SV_TARGET
{
    float4 ws_pos = mul(unity_ObjectToWorld, i.ws_pos);
    float2 uv = (!vface) ? i.uv_a.zw : i.uv_a.xy;
    float testTresh = (0.0 /*_AlphaTestThreshold*/);
    if((0.0 /*_IsTransparent*/)) testTresh = 0.0f;
    float alpha = _MainTex.Sample(sampler_MainTex, uv).w;
    float4 out_color = (float4)0.0f;
    #if defined(can_dissolve)
    if((0.0 /*_DissoveON*/))
    {
        dissolve_clip(ws_pos, i.dis_pos, i.dis_uv, uv);
    }        
    #endif
    if((0.0 /*_EnableAlphaCutoff*/)) clip(alpha - saturate(testTresh));
    if(i.hide) clip(-1);
    return 0.0f;
}
