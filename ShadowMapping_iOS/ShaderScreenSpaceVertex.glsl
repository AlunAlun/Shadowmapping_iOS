//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
attribute highp vec2 a_vertex;
varying highp vec2 v_textureCoord;

const highp vec2 madd=vec2(0.5,0.5);

void main() {
    v_textureCoord = a_vertex.xy*madd+madd; // scale vertex attribute to [0-1] range
    gl_Position = vec4(a_vertex.xy,0.0,1.0);
}