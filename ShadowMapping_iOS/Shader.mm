//
//  ShaderLoader.m
//  ios3D
//
//  Created by Alun on 4/3/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//

#import "Shader.h"


@implementation Shader

@synthesize program;


- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType Uniforms:(NSArray *)uniforms Flags:(NSArray*)flags
{
    // Load the shader in memory
    /*NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];*/
    // Load the shader in memory
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderPreString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    NSString *shaderString;
    if ([flags count] > 0){
        //add flags at start of each shaderstring
        NSString *preDefines = [flags componentsJoinedByString:@"\n #define "];
        
        shaderString = [NSString stringWithFormat:@"#define %@\n %@",preDefines, shaderPreString];
    }
    else
        shaderString = shaderPreString;
    
    if(!shaderString)
    {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // Create the shader inside openGL
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // Give that shader the source code loaded in memory
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // Compile the source code
    glCompileShader(shaderHandle);
    
    // Get the error messages in case the compiling has failed
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLint logLength;
        glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &logLength);
        if(logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shaderHandle, logLength, &logLength, log);
            NSLog(@"Shader compile log:\n%s", log);
            free(log);
        }
        exit(1);
    }
    
    return shaderHandle;
}

-(id)initProgramWithVertex:(NSString*)vertex Fragment:(NSString*)fragment Attributes:(NSArray*)attributes Uniforms:(NSArray*)uniforms Flags:(NSArray *)flags
{
    if ((self = [super init])) {
        

        // Compile both shaders
        GLuint vertexShader = [self compileShader:vertex withType:GL_VERTEX_SHADER Uniforms:uniforms Flags:flags];
        GLuint fragmentShader = [self compileShader:fragment withType:GL_FRAGMENT_SHADER Uniforms:uniforms Flags:flags];
        
        // Create the program in openGL, attach the shaders and link them
        GLuint programHandle = glCreateProgram();
        glAttachShader(programHandle, vertexShader);
        glAttachShader(programHandle, fragmentShader);
        
        self.numAttributes = attributes.count;
        for (GLuint i = 0; i < self.numAttributes; i++) {
            glBindAttribLocation(self.program, i, [[attributes objectAtIndex:i] UTF8String]);
        }
        
        glLinkProgram(programHandle);
        
        // Get the error message in case the linking has failed
        GLint linkSuccess;
        glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
        if (linkSuccess == GL_FALSE)
        {
            GLint logLength;
            glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &logLength);
            if(logLength > 0)
            {
                GLchar *log = (GLchar *)malloc(logLength);
                glGetProgramInfoLog(programHandle, logLength, &logLength, log);
                NSLog(@"Program link log:\n%s", log);
                free(log);
            }
            exit(1);
        }
        self.program = programHandle;
        
        
        
        _uniforms = (GLuint*)malloc(uniforms.count * sizeof(GLuint));
        for (NSUInteger i = 0; i < uniforms.count; i ++) {
            _uniforms[i] = glGetUniformLocation(self.program, [[uniforms objectAtIndex:i] UTF8String]);
            if (_uniforms[i] == (NSUInteger)-1)
                NSLog(@"uniform with name %@ is disabled", [uniforms objectAtIndex:i]);
        }
        
        
        
        // Release vertex and fragment shaders
        if (vertexShader)
            glDeleteShader(vertexShader);
        if (fragmentShader)
            glDeleteShader(fragmentShader);
    }
    
    //_program = programHandle;
    return self;
}



@end
