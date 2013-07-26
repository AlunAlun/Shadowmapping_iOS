//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
precision highp float;

uniform highp mat4 u_m;
uniform highp mat4 u_mv;
uniform highp mat4 u_p;
uniform highp mat3 u_normal_model;

attribute highp vec3 a_vertex;
attribute highp vec3 a_normal;

varying highp vec3 v_normal;
varying highp vec3 v_pos;
varying highp vec4 v_WorldPosition4;

uniform highp mat4 u_depthBiasMVP;
varying highp vec4 v_shadowCoord;


void main(void)
{
    /* world space lighting */
    v_pos = (u_m * vec4(a_vertex,1.0)).xyz;
    v_WorldPosition4 = u_m * vec4(a_vertex,1.0);
    v_normal = u_normal_model * a_normal;
    
    /* Transform the vertex data in eye coordinates */
    highp vec3 position = vec3(u_mv * vec4(a_vertex, 1.0));
    
    /* get shadow coordinate according to biased light MVP matrix */
    v_shadowCoord = u_depthBiasMVP * vec4(a_vertex, 1.0);
    
    /* Transform the positions from eye coordinates to clip coordinates */
    gl_Position = u_p * vec4(position, 1.0);
    
}
