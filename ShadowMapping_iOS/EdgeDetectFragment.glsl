precision highp float;
varying highp vec2 v_textureCoord;
uniform sampler2D u_textureSampler;
varying highp vec2 v_kernel[4];

const highp float d = 1.0/1024.0;

void main() {
    
    highp vec4 diffuse_color = texture2D(u_textureSampler, v_textureCoord);
    highp vec4 diffuse_colorL = texture2D(u_textureSampler, v_kernel[0]);
    highp vec4 diffuse_colorR = texture2D(u_textureSampler, v_kernel[1]);
    highp vec4 diffuse_colorA = texture2D(u_textureSampler, v_kernel[2]);
    highp vec4 diffuse_colorB = texture2D(u_textureSampler, v_kernel[3]);
    
    /*highp vec4 diffuse_colorL2 = texture2D(u_textureSampler, v_kernel[4]);
    highp vec4 diffuse_colorR2 = texture2D(u_textureSampler, v_kernel[5]);
    highp vec4 diffuse_colorA2 = texture2D(u_textureSampler, v_kernel[6]);
    highp vec4 diffuse_colorB2 = texture2D(u_textureSampler, v_kernel[7]);*/

    
    
    highp vec4 edgeColor = ((diffuse_colorL + diffuse_colorR +diffuse_colorA + diffuse_colorB ) - (4.0 *diffuse_color))*5.0;
    
   /* highp vec4 edgeColor = ((diffuse_colorL + diffuse_colorR +diffuse_colorA + diffuse_colorB
                             + diffuse_colorL2 + diffuse_colorR2 +diffuse_colorA2 + diffuse_colorB2
                             ) - (8.0 *diffuse_color))*5.0;*/
    //gl_FragColor = edgeColor;
     
    
    
    highp vec4 finalColor = vec4(0.0, 0.0, 0.0, 1.0);
    if (edgeColor.r > 0.3)
        finalColor = vec4(1.0, 0.0, 0.0, 1.0);
    if (edgeColor.r > 0.6)
        finalColor = vec4(0.0, 1.0, 0.0, 1.0);
    if (edgeColor.r > 0.9)
        finalColor = vec4(0.0, 0.0, 1.0, 1.0);

    gl_FragColor = finalColor;
     
    
    //highp float bob = (edgeColor.r > 0.03) ? 1.0 : 0.0;
    //gl_FragColor = vec4(bob, bob, bob, 1.0);

    
   
}


/*
 float distFar = 10000.0;
 if (bob > 0.1)
 {
 if (diffuse_colorL < distFar) distFar = diffuse_colorL;
 if (diffuse_colorR < distFar) distFar = diffuse_colorR;
 if (diffuse_colorA < distFar) distFar = diffuse_colorA;
 if (diffuse_colorB < distFar) distFar = diffuse_colorB;
 
 float widthPenum = (distFar - diffuse_color)/
 }*/


/*
 highp vec4 diffuse_color = texture2D(u_textureSampler, v_textureCoord);
 highp vec4 diffuse_colorL = texture2D(u_textureSampler, v_textureCoord + vec2(-d,0.0)); //left
 highp vec4 diffuse_colorR = texture2D(u_textureSampler, v_textureCoord + vec2(d,0.0)); //right
 highp vec4 diffuse_colorA = texture2D(u_textureSampler, v_textureCoord + vec2(0.0,d)); //top
 highp vec4 diffuse_colorB = texture2D(u_textureSampler, v_textureCoord + vec2(0.0,-d)); //bottom
 highp vec4 diffuse_colorLT = texture2D(u_textureSampler, v_textureCoord + vec2(-d,d)); //lefttop
 highp vec4 diffuse_colorRT = texture2D(u_textureSampler, v_textureCoord + vec2(d,d)); //righttop
 highp vec4 diffuse_colorLB = texture2D(u_textureSampler, v_textureCoord + vec2(-d,-d)); //top
 highp vec4 diffuse_colorRB = texture2D(u_textureSampler, v_textureCoord + vec2(d,-d)); //bottom
 
 gl_FragColor = (diffuse_colorL + diffuse_colorR +diffuse_colorA + diffuse_colorB + diffuse_colorLT + diffuse_colorRT + diffuse_colorLB + diffuse_colorRB) - (8.0 *diffuse_color);
 */



//gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);