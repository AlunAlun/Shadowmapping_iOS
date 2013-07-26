//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//


#extension GL_EXT_shadow_samplers : require

precision highp float;

uniform lowp vec4 u_mat_color;
uniform lowp vec4 u_mat_ambient;
uniform lowp float u_light_intensity;
uniform highp vec3 u_light_dir;
uniform highp vec3 u_light_pos;

varying highp vec3 v_normal;
varying highp vec3 v_pos;


void main(void)
{
    
    //normalize all first
    highp vec3 L = normalize(u_light_pos-v_pos);
    highp vec3 N = normalize(v_normal);
    highp vec3 D = normalize(u_light_dir);
    
    //base color * ambient
    highp vec4 finalColor = u_mat_color;
    finalColor *= u_mat_ambient;

    
    // diffuse light
    float ndotl = max(dot(N, L), 0.0);
    highp vec3 diffuse_light = vec3(ndotl);
    finalColor += vec4(diffuse_light, 1.0) * u_mat_color * u_light_intensity;
    
    gl_FragColor = finalColor ;
}

