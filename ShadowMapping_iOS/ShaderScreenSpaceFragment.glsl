#extension GL_EXT_shader_texture_lod : require

//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
varying highp vec2 v_textureCoord;
uniform sampler2D u_textureSampler;


void main() {
    highp vec4 color1 = texture2D(u_textureSampler,v_textureCoord);
    //highp vec4 color1 = texture2DLodEXT (u_textureSampler, v_textureCoord, 5.0);
    //if (color1.x > 0.01)
        //color1 = vec4(1.0,1.0,1.0,1.0);
    /*else if (color1.y > 0.001)
        color1 = vec4(0.0,1.0,0.0,1.0);
    else if (color1.z > 0.001)
        color1 = vec4(0.0,0.0,1.0,1.0);*/
    gl_FragColor = color1;
}

