//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
attribute highp vec3 a_vertex;
uniform highp mat4 u_depthMVP;

varying highp vec4 pos;

void main(void)
{
    gl_Position = pos = u_depthMVP * vec4(a_vertex, 1.0);
}
