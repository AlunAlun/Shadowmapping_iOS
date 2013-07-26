const highp vec2 madd=vec2(0.5,0.5);
attribute highp vec2 a_vertex;
varying highp vec2 v_textureCoord;
varying highp vec2 v_kernel[4];

const highp float d = 1.0/1024.0;
void main() {
    v_textureCoord = a_vertex.xy*madd+madd; // scale vertex attribute to [0-1] range
    v_kernel[0] = v_textureCoord + vec2(-d,0.0);
     v_kernel[1] = v_textureCoord + vec2(d,0.0);
     v_kernel[2] = v_textureCoord + vec2(0.0,d);
     v_kernel[3] = v_textureCoord + vec2(0.0,-d);
    
   /* v_kernel[4] = v_textureCoord + vec2(-d,-d);
    v_kernel[5] = v_textureCoord + vec2(d,-d);
    v_kernel[6] = v_textureCoord + vec2(-d,d);
    v_kernel[7] = v_textureCoord + vec2(d,d);*/
    
    gl_Position = vec4(a_vertex.xy,0.0,1.0);
}