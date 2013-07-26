//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
#extension GL_EXT_shader_texture_lod : require

precision highp float;

uniform lowp vec4 u_mat_color;
uniform lowp vec4 u_mat_ambient;
uniform lowp float u_light_intensity;
uniform highp vec3 u_light_dir;
uniform highp vec3 u_light_pos;
uniform highp mat4 u_light_view;

varying highp vec3 v_normal;
varying highp vec3 v_pos;
varying highp vec4 v_WorldPosition4;

varying highp vec4 v_shadowCoord;
uniform sampler2D u_shadowMap;
uniform sampler2D u_edgeMap;
uniform highp float u_shadowMapRes;

//#if defined (USE_SOFT_SHADOWS) | defined (USE_VARIABLE_SHADOWS)
 
float getShadowJitter(sampler2D map, vec2 coords, vec2 texMapScale)
{
    float bias = 0.01;
    float shadow = 0.0;
    highp vec4 sample =  v_shadowCoord + vec4(coords.x * texMapScale.x * v_shadowCoord.w, coords.y * texMapScale.y * v_shadowCoord.w, 0.05,0.0);
    
    float sampleDepth = texture2DProj(map, sample).x;
    float depth = (sampleDepth == 1.0) ? 1.0e9 : sampleDepth; //on empty data send it to far away
    float PdivQ = v_shadowCoord.p / v_shadowCoord.q;
    shadow = (PdivQ-bias <= depth) ? 0.0 : 1.0;

    return shadow;
    
}

//#endif

void main(void)
{
    
    //normalize all first
    highp vec3 L = normalize(u_light_pos-v_pos);
    highp vec3 N = normalize(v_normal);
    highp vec3 D = normalize(u_light_dir);
    
    highp vec3 lightPos = (u_light_view * v_WorldPosition4).xyz;
    
    highp vec4 finalColor = u_mat_ambient;

      
    float shadow = 0.0;
    float bias = 0.01;
    float sampleDepth = texture2DProj(u_shadowMap, v_shadowCoord).x;
    float depth = (sampleDepth == 1.0) ? 1.0e9 : sampleDepth; //on empty data send it to far away
    float PdivQ = v_shadowCoord.p / v_shadowCoord.q;


    vec2 jitterFactor = vec2(1.0,1.0);
#ifdef USE_JITTER
    jitterFactor.x = fract( v_shadowCoord.x * 18428.4) * 2.0 - 1.0;
    jitterFactor.y = fract( v_shadowCoord.y * 23614.3) * 2.0 - 1.0;
#endif
    vec2 texMapScale;
    texMapScale.x = (1.0/(u_shadowMapRes))*jitterFactor.x;
    texMapScale.y = (1.0/(u_shadowMapRes))*jitterFactor.y;
    float spread = (1.0/(u_shadowMapRes));
    float y = 0.0; float x = 0.0;
   
    float red = 0.0; float green = 0.0; float blue = 0.0;

  
#ifdef USE_VARIABLE_SHADOWS
    if (texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).x > 0.005)
    {
        //red = 1.0;
        texMapScale.x = (1.0/(u_shadowMapRes/1.2))*jitterFactor.x;
        texMapScale.y = (1.0/(u_shadowMapRes/1.2))*jitterFactor.y;
        for (y = -0.5; y <= 0.5; y += 1.0)
            for (x = -0.5; x <= 0.5; x += 1.0)
                shadow += getShadowJitter(u_shadowMap, vec2( x, y ), texMapScale);
        shadow = 1.0 - (shadow/4.0);
        if (shadow > 0.99999 || shadow < 0.001)
            shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
    }
    else if (texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).y > 0.005)
    {
        //green = 1.0;
        texMapScale.x = (1.0/(u_shadowMapRes/1.2))*jitterFactor.x;
        texMapScale.y = (1.0/(u_shadowMapRes/1.2))*jitterFactor.y;
        for (y = -1.5; y <= 1.5; y += 1.0)
            for (x = -1.5; x <= 1.5; x += 1.0)
                shadow += getShadowJitter(u_shadowMap, vec2( x, y ), texMapScale);
        shadow = 1.0 - (shadow/16.0);
        if (shadow > 0.99999 || shadow < 0.001)
            shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
        
    }
    else if (texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).z > 0.005)
    {
        //blue = 1.0;
        texMapScale.x = (1.0/(u_shadowMapRes/1.0))*jitterFactor.x;
        texMapScale.y = (1.0/(u_shadowMapRes/1.0))*jitterFactor.y;
        for (y = -3.0; y <= 3.0; y += 1.0)
            for (x = -3.0; x <= 3.0; x += 1.0)
                shadow += getShadowJitter(u_shadowMap, vec2( x, y ), texMapScale);
        shadow = 1.0 - (shadow/49.0);
        if (shadow > 0.99999 || shadow < 0.001)
            shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;

    }
    else
        shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
#endif //end USE_VARIABLE_SHADOWS
    
#ifdef USE_SOFT_SHADOWS  
    if (texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).x > 0.005
        || texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).y > 0.005
        || texture2DProjLodEXT(u_edgeMap, v_shadowCoord, 5.0).z > 0.005){
        //red = 1.0;
        for (y = -1.0; y <= 1.0; y += 1.0)
            for (x = -1.0; x <= 1.0; x += 1.0)
                shadow += getShadowJitter(u_shadowMap, vec2( x, y ), texMapScale);
        shadow = 1.0 - (shadow/9.0);
        if (shadow > 0.99999 || shadow < 0.001)
            shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
    }
    else
        shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
#endif //end USE_SOFT_SHADOWS
    
#ifdef USE_HARD_SHADOWS
    shadow = (PdivQ-bias <= depth) ? 1.0 : 0.0;
#endif
    
    
    

    float ndotl = max(dot(N, L), 0.0);
    highp vec3 diffuse_light = vec3(ndotl);
    finalColor += vec4(diffuse_light, 1.0) * u_mat_color *shadow;
    
    gl_FragColor = finalColor;
    if (red > 0.0) gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    if (green > 0.0) gl_FragColor = vec4(0.0,1.0,0.0,1.0);
    if (blue > 0.0) gl_FragColor = vec4(0.0,0.0,1.0,1.0);
       

    
}

