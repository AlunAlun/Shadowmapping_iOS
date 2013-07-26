//  ShadowTest_Hard
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//
varying highp vec4 pos;

void main(void)
{

    gl_FragColor.a = 1.0;
    gl_FragColor.rgb=vec3(gl_FragCoord.z);
    
}