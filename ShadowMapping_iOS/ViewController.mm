
//
//  ViewController.m
//  ShadowMapping_iOS
//
//  Created by Alun on 5/24/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//

#define BUFFER_OFFSET(i) ((char *)NULL + i)
#define RENDERTEXTURE_A_RES 1024

#import "ViewController.h"
#import "Shader.h"

#import <stdio.h>
#include <map>
#include <string>
#include <vector>
#import <sys/stat.h>

//Data for a floor object
GLfloat FloorVertexData[32] =
{
    -1000.0,-2.0,1000.0,    0.0,1.0,0.0,    1.0,0.0,
    1000.0,-2.0,1000.0,    0.0,1.0,0.0,    1.0,0.0,
    -1000.0,-2.0,-1000.0,    0.0,1.0,0.0,    1.0,0.0,
    1000.0,-2.0,-1000.0,    0.0,1.0,0.0,    1.0,0.0,
    
};
GLuint FloorIndicesData[6] =
{
    0, 1, 3,        0, 3, 2,
};

//Data for a screen quad (for testing renders to texture)
GLfloat ScreenVertexData[32] =
{
    -1, -1, 0, 0, 0, -1, 0, 0,
    -1,  1, 0, 0, 0, -1, 0, 1,
    1,  1, 0, 0, 0, -1, 1, 1,
    1, -1, 0, 0, 0, -1, 1, 0
};
GLuint ScreenIndicesData[6] =
{
    0, 1, 2,
    2, 3, 0
};

//Data for a cube
GLfloat CubeVertexData[192] =
{
    // right 0
    0.5f, -0.5f, -0.5f,    1.0f, 0.0f, 0.0f,   1.0f, 0.0f,
    0.5f,  0.5f, -0.5f,    1.0f, 0.0f, 0.0f,   1.0f, 1.0f,
    0.5f,  0.5f,  0.5f,    1.0f, 0.0f, 0.0f,   0.0f, 1.0f,
    0.5f, -0.5f,  0.5f,    1.0f, 0.0f, 0.0f,   0.0f, 0.0f,
    
    // top 4
    0.5f,  0.5f, -0.5f,    0.0f, 1.0f, 0.0f,   1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,    0.0f, 1.0f, 0.0f,   0.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,    0.0f, 1.0f, 0.0f,   0.0f, 0.0f,
    0.5f,  0.5f,  0.5f,    0.0f, 1.0f, 0.0f,   1.0f, 0.0f,
    
    // left 8
    -0.5f,  0.5f, -0.5f,    -1.0f, 0.0f, 0.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,    -1.0f, 0.0f, 0.0f,  0.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,    -1.0f, 0.0f, 0.0f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,    -1.0f, 0.0f, 0.0f,  1.0f, 1.0f,
    
    // bottom 12
    -0.5f, -0.5f, -0.5f,    0.0f, -1.0f, 0.0f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,    0.0f, -1.0f, 0.0f,  0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,    0.0f, -1.0f, 0.0f,  0.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,    0.0f, -1.0f, 0.0f,  0.0f, 0.0f,
    
    // front 16
    0.5f,  0.5f,  0.5f,    0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,    0.0f, 0.0f, 1.0f,   0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,    0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    0.5f, -0.5f,  0.5f,    0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    
    // back 20
    0.5f,  0.5f, -0.5f,    0.0f, 0.0f, -1.0f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,    0.0f, 0.0f, -1.0f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,    0.0f, 0.0f, -1.0f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,    0.0f, 0.0f, -1.0f,  1.0f, 1.0f,
};
GLuint CubeIndicesData[36] =
{
    // right
    0, 1, 2,        2, 3, 0,
    
    // top
    4, 5, 6,        6, 7, 4,
    
    // left
    8, 9, 10,       10, 11, 8,
    
    // bottom
    12, 13, 14,     14, 15, 12,
    
    // front
    16, 17, 18,     18, 19, 16,
    
    // back
    20, 21, 22,     22, 23, 20
};



/*** ATTRIBUTES & UNIFORMS 
    these attributes must be in the same order
    as those in the NSArrays used at Shader init
 ***/
typedef enum {
    MainShaderAttributeVertex,
    MainShaderAttributeNormal
} MainShaderAttribute;

typedef enum {
    MainShaderUniformMatrixModel,
    MainShaderUniformMatrixModelView,
    MainShaderUniformMatrixProjection,
    MainShaderUniformMatrixNormalModel,
    MainShaderUniformMatrixDepthBiasMVP,
    MainShaderUniformMaterialColor,
    MainShaderUniformMaterialAmbient,
    MainShaderUniformLightIntensity,
    MainShaderUniformLightDirection,
    MainShaderUniformLightPosition,
    MainShaderUniformShadowSampler,
    MainShaderUniformEdgeSampler,
    MainShaderUniformShadowMapResolution,
    MainShaderUniformLightViewMatrix
} MainShaderUniform;

typedef enum {
    PhongShaderUniformMatrixModel,
    PhongShaderUniformMatrixModelView,
    PhongShaderUniformMatrixProjection,
    PhongShaderUniformMatrixNormalModel,
    PhongShaderUniformMaterialColor,
    PhongShaderUniformMaterialAmbient,
    PhongShaderUniformLightIntensity,
    PhongShaderUniformLightDirection,
    PhongShaderUniformLightPosition,
    PhongShaderUniformLightViewMatrix
} PhongShaderUniform;

typedef enum {
    ShadowShaderUniformDepthMVP
} ShadowShaderUniform;

typedef enum {
    ScreenShaderUniformTextureSampler
} ScreenShaderUniform;

//a simple enum to enable us to switch between shadow modes at runtime
typedef enum {
    ShadowModeHard = 0,
    ShadowModeSoft,
    ShadowModeVariable
} ShadowMode;

/*** START MAIN CLASS ***/
//Because we only really have one class, I just use a bunch of
//global vars
@interface ViewController ()
{
    //camera vectors & matrices
    GLKMatrix4 _modelMatrix;
    GLKMatrix4 _viewMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLKMatrix4 _projectionMatrix;
    GLKVector3 _cameraPosition; //kept apart to rotate it on touch
    //light vectors & matrices
    GLKMatrix4 _viewMatrixLight;
    GLKMatrix4 _modelViewMatrixLight;
    GLKMatrix4 _projectionMatrixLight;
    GLKMatrix4 _depthMVPMatrix;
    GLKMatrix4 _depthBiasMVP;
    GLKVector3 _lightPosition;
    GLKVector3 _lightTarget;
    
    //Various vert and ind buffer objects
    GLuint _cubeVerticesVBO;
    GLuint _cubeIndicesVBO;
    GLuint _cubeVAO;
    
    GLuint _floorVerticesVBO;
    GLuint _floorIndicesVBO;
    GLuint _floorVAO;
    
    GLuint _OBJVerticesVBO;
    GLuint _OBJIndicesVBO;
    GLuint _OBJVAO;
    GLuint _OBJIndexCount;
    
    GLuint _screenVerticesVBO;
    GLuint _screenIndicesVBO;
    GLuint _screenVAO;
    
    //target for shadow pass
    GLuint _renderBufferA;
    GLuint _renderTextureA;
    //target for edge pass
    GLuint _renderBufferB;
    GLuint _renderTextureB;
    
    //various shaders which we precompile for speed
    Shader *_mainShader;
    Shader *_mainShaderHard;
    Shader *_mainShaderSoft;
    Shader *_mainShaderVariable;
    Shader *_shadowShader;
    Shader *_screenShader;
    Shader *_edgeShader;
    Shader *_phongShader;
    
    //variables used for UI
    ShadowMode _shadowMode;
    UILabel *_textLabel;
    float _xTouchLoc;
    float _yTouchLoc;
    GLfloat _lastScale;
    bool _showEdgeMap;
}
//I have no idea why I declared these as property and not
//global vars like the others. THere's no real reason.
@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic, assign) int screenWidth;
@property(nonatomic, assign) int screenHeight;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //setup OpenGL ES 2.0
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (![EAGLContext setCurrentContext:self.context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
    // Initialize view, set context, and store dimensions
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    self.screenWidth = view.bounds.size.width*[[UIScreen mainScreen] scale];
    self.screenHeight = view.bounds.size.height*[[UIScreen mainScreen] scale];
    
    // Set depth format, multisamples, and preferred Max FPS
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    self.preferredFramesPerSecond = 60; //Max is 60 thnx to iPhone/iPad screen refresh rate
    
    // set flags 
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    /*** COMPILE SHADERS ***/
    
    //general attributes
    NSArray *atts = [[NSArray alloc] initWithObjects:@"a_vertex", @"a_normal", nil];
    
    // compiler macros (enable disable features of shaders)
    NSArray *hardFlags = [[NSArray alloc] initWithObjects: @"USE_HARD_SHADOWS",nil];
    NSArray *softFlags = [[NSArray alloc] initWithObjects: @"USE_SOFT_SHADOWS", nil];
    NSArray *variableFlags = [[NSArray alloc] initWithObjects: @"USE_VARIABLE_SHADOWS",nil];
    NSArray *emptyFlags = [[NSArray alloc] initWithObjects: nil];

    
    //Main shaders used for painting shadows
    printf("Compiling main shader\n");
    NSArray *unis = [[NSArray alloc] initWithObjects:
                     @"u_m",
                     @"u_mv",
                     @"u_p",
                     @"u_normal_model",
                     @"u_depthBiasMVP",
                     @"u_mat_color",
                     @"u_mat_ambient",
                     @"u_light_intensity",
                     @"u_light_dir",
                     @"u_light_pos",
                     @"u_shadowMap",
                     @"u_edgeMap",
                     @"u_shadowMapRes",
                     @"u_light_view",
                     nil];
    _mainShaderHard = [[Shader alloc] initProgramWithVertex:@"PCFEdgeShadowVertex"
                                                       Fragment:@"PCFEdgeShadowFragment"
                                                           Attributes:atts
                                                          Uniforms:unis Flags:hardFlags];
    
    _mainShaderSoft = [[Shader alloc] initProgramWithVertex:@"PCFEdgeShadowVertex"
                                                   Fragment:@"PCFEdgeShadowFragment"
                                                 Attributes:atts
                                                   Uniforms:unis Flags:softFlags];
    
    _mainShaderVariable = [[Shader alloc] initProgramWithVertex:@"PCFEdgeShadowVertex"
                                                   Fragment:@"PCFEdgeShadowFragment"
                                                 Attributes:atts
                                                   Uniforms:unis Flags:variableFlags];
    
    //start with standard PCF shader
    _mainShader = _mainShaderSoft;
    _shadowMode = ShadowModeSoft;
    
    //shader used for drawing object
    unis = [[NSArray alloc] initWithObjects:
                     @"u_m",
                     @"u_mv",
                     @"u_p",
                     @"u_normal_model",
                     @"u_mat_color",
                     @"u_mat_ambient",
                     @"u_light_intensity",
                     @"u_light_dir",
                     @"u_light_pos",
                     @"u_light_view",
                     nil];
    _phongShader = [[Shader alloc] initProgramWithVertex:@"PhongVertex"
                                               Fragment:@"PhongFragment"
                                             Attributes:atts
                                               Uniforms:unis Flags:emptyFlags];
    
    // shader used for shadow pass
    printf("Compiling shadow pass shader\n");
    unis = [[NSArray alloc] initWithObjects: @"u_depthMVP", nil];
    _shadowShader = [[Shader alloc] initProgramWithVertex:@"ShaderShadowMapVertex"
                                                        Fragment:@"ShaderShadowMapFragment"
                                                      Attributes:atts
                                                           Uniforms:unis Flags:emptyFlags];
    
    //shader used to paint screen quad
    printf("Compiling screen shader\n");
    unis = [[NSArray alloc] initWithObjects:@"u_textureSampler",nil];
    _screenShader = [[Shader alloc] initProgramWithVertex:@"ShaderScreenSpaceVertex" Fragment:@"ShaderScreenSpaceFragment"
                                               Attributes:atts
                                                 Uniforms:unis Flags:emptyFlags];
    
    //shader used to paint screen quad
    printf("Compiling screen shader\n");
    unis = [[NSArray alloc] initWithObjects:@"u_textureSampler",nil];
    _edgeShader = [[Shader alloc] initProgramWithVertex:@"EdgeDetectVertex" Fragment:@"EdgeDetectFragment"
                                               Attributes:atts
                                                 Uniforms:unis Flags:emptyFlags];
    
    
    /*** CAMERA MATRICES ***/
    _modelMatrix = GLKMatrix4Identity; // no object movement in this app

    _cameraPosition = GLKVector3Make(0.0, 400.0, 100.0);
    
    _viewMatrix = GLKMatrix4MakeLookAt(_cameraPosition.x, _cameraPosition.y, _cameraPosition.z,
                                       90.0, 140.0, 0.0,
                                       0.0f, 1.0f, 0.0f);
    
    _modelViewMatrix = GLKMatrix4Multiply(_viewMatrix, _modelMatrix);
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0),
                                                  (float)self.screenWidth/(float)self.screenHeight,
                                                  1.0, 500.0);
    
    /*** LIGHT SETUP ***/
    _lightPosition = GLKVector3Make(-150.0, 300.0, 10.1);
    _lightTarget = GLKVector3Make(0.0, 70.0, 0.0);
    
    
    /*** SHADOW MATRICES ***/
    _viewMatrixLight = GLKMatrix4MakeLookAt(_lightPosition.x, _lightPosition.y, _lightPosition.z,
                                            _lightTarget.x, _lightTarget.y, _lightTarget.z,
                                            0.0f, 1.0f, 0.0f);
    _projectionMatrixLight = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0),
                                                       (float)self.screenWidth/(float)self.screenHeight,
                                                       50.0, 500.0);
    
    _modelViewMatrixLight = GLKMatrix4Multiply(_viewMatrixLight, GLKMatrix4Identity);
    _depthMVPMatrix = GLKMatrix4Multiply(_projectionMatrixLight, _modelViewMatrixLight);
    GLKMatrix4 biasMatrix = GLKMatrix4Make(
                                           0.5, 0.0, 0.0, 0.0,
                                           0.0, 0.5, 0.0, 0.0,
                                           0.0, 0.0, 0.5, 0.0,
                                           0.5, 0.5, 0.5, 1.0
                                           );
    _depthBiasMVP = GLKMatrix4Multiply(biasMatrix, _depthMVPMatrix);
    
    /*** UI setup ***/
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(Scale:)];
	[view addGestureRecognizer:pinchRecognizer];
    _lastScale = 1.0;

    UITapGestureRecognizer *tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    tapRecogniser.numberOfTapsRequired = 2;
    [view addGestureRecognizer:tapRecogniser];
    
    UITapGestureRecognizer *tap22Recogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap22:)];
    tap22Recogniser.numberOfTapsRequired = 2;
    tap22Recogniser.numberOfTouchesRequired = 2;
    [view addGestureRecognizer:tap22Recogniser];
    _showEdgeMap = false;
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 800, 100)];
    [_textLabel setText:[NSString stringWithFormat:@"iOS Shadowing. MSAA enabled. 6700ish faces. \nSwipe to rotate. \nDouble-tap-two-fingers to see edge map.\nDouble-tap-one-finger to change shadowing mode. \nCurrent Mode: %@", [self currentShadowModeString]]];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textColor = [UIColor whiteColor];
    [_textLabel setFont:[UIFont systemFontOfSize:12]];
    _textLabel.numberOfLines = 0;
    [view addSubview:_textLabel];
    
    /*** SETUP GL BUFFERS ***/
    //glEnable(GL_CULL_FACE);
    
    //[self setupCubeBuffers];
    [self setupFloorBuffers];
    [self setupOBJBuffers:@"avatar_girl.obj"];
    
    [self setupScreenSpaceQuad];
    [self setupRenderBufferTextureA];
    [self setupRenderBufferTextureB];
}

// Main draw method
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Store screen FBO ref so we can draw into it after
    // drawing into any other FBOs
    GLint oldFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    

    
    /*** START SHADOW PASS ***/
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _renderBufferA);
        //glCullFace(GL_FRONT); //cull front faces for shadow pass - only works for double sided meshes
        glViewport(0, 0, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );

        //drawcube with Shadow shader
        //[self drawCubeShadow];
        [self drawFloorShadow];
        [self drawOBJShadow];

    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
     /*** END SHADOW PASS ***/
    
    
    
    /*** START EDGE PASS ***/
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _renderBufferB);
        //glCullFace(GL_BACK);
        glViewport(0, 0, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES);
        glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
    
        glDisable(GL_CULL_FACE);
        
        [self drawScreenQuadwithTexture:_renderTextureA andShader:_edgeShader];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
    /*** END EDGE PASS ***/
    
    
    
    /*** START RENDER TO SCREEN ***/
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
        //glCullFace(GL_BACK);         //Cull back faces now - only works for double sided meshes
        glViewport(0, 0, self.screenWidth, self.screenHeight);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );

        //draw scene
        [self drawFloor];
        //[self drawCube];
        [self drawOBJ];
    
        //draw edge map texture to screen if true
        if (_showEdgeMap)
            [self drawScreenQuadwithTexture:_renderTextureB andShader:_screenShader];
     glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFBO);
    /*** END RENDER TO SCREEN ***/
    
}

-(void)setupCubeBuffers
{
    // Make the vertex buffer
    glGenBuffers( 1, &_cubeVerticesVBO );
    glBindBuffer( GL_ARRAY_BUFFER, _cubeVerticesVBO );
    glBufferData( GL_ARRAY_BUFFER, sizeof(CubeVertexData), CubeVertexData, GL_STATIC_DRAW );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    
    // Make the indices buffer
    glGenBuffers( 1, &_cubeIndicesVBO );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _cubeIndicesVBO );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(CubeIndicesData), CubeIndicesData, GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
    //Create VAO
    glGenVertexArraysOES( 1, &_cubeVAO );
}

-(void)drawCube
{
    glUseProgram( _phongShader.program );
    [self setPhongUniforms];
    
    glBindVertexArrayOES( _cubeVAO );
    
    //Bind attributes
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _cubeVerticesVBO );
    
    glEnableVertexAttribArray( MainShaderAttributeVertex );
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );

    glEnableVertexAttribArray( MainShaderAttributeNormal );
    glVertexAttribPointer( MainShaderAttributeNormal, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET( stride*3/8 ) );
    
    glUniform4f(_phongShader.uniforms[PhongShaderUniformMaterialColor], 0.0, 0.65, 0.0, 1.0f);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _cubeIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, sizeof(CubeIndicesData)/sizeof(GLuint), GL_UNSIGNED_INT, NULL );
    
    glBindVertexArrayOES( 0 );
}

-(void)drawCubeShadow
{
    glUseProgram( _shadowShader.program );

    glBindVertexArrayOES( _cubeVAO );
    
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _cubeVerticesVBO );
    
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glUniformMatrix4fv(_shadowShader.uniforms[ShadowShaderUniformDepthMVP], 1, GL_FALSE, _depthMVPMatrix.m);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _cubeIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, sizeof(CubeIndicesData)/sizeof(GLuint), GL_UNSIGNED_INT, NULL );
    
    glBindVertexArrayOES( 0 );
}

-(void)setupFloorBuffers
{
    // Make the vertex buffer
    glGenBuffers( 1, &_floorVerticesVBO );
    glBindBuffer( GL_ARRAY_BUFFER, _floorVerticesVBO );
    glBufferData( GL_ARRAY_BUFFER, sizeof(FloorVertexData), FloorVertexData, GL_STATIC_DRAW );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    
    // Make the indices buffer
    glGenBuffers( 1, &_floorIndicesVBO );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _floorIndicesVBO );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(FloorIndicesData), FloorIndicesData, GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
    //Create VAO
    glGenVertexArraysOES( 1, &_floorVAO );

}

-(void)drawFloor
{
    glUseProgram( _mainShader.program );
    [self setUniforms];
    
    glBindVertexArrayOES( _floorVAO );
    
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _floorVerticesVBO );
    
    glEnableVertexAttribArray( MainShaderAttributeVertex );
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glEnableVertexAttribArray( MainShaderAttributeNormal );
    glVertexAttribPointer( MainShaderAttributeNormal, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET( stride*3/8 ) );
    
    glUniform4f(_mainShader.uniforms[MainShaderUniformMaterialColor], 0.65, 0.65, 0.65, 1.0f);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _floorIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, sizeof(FloorIndicesData)/sizeof(GLuint), GL_UNSIGNED_INT, NULL );
    
    glBindVertexArrayOES( 0 );
}

-(void)drawFloorShadow
{
    glUseProgram( _shadowShader.program );
    
    glBindVertexArrayOES( _floorVAO );
    
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _floorVerticesVBO );
    
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glUniformMatrix4fv(_shadowShader.uniforms[ShadowShaderUniformDepthMVP], 1, GL_FALSE, _depthMVPMatrix.m);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _floorIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, sizeof(FloorIndicesData)/sizeof(GLuint), GL_UNSIGNED_INT, NULL );
    
    glBindVertexArrayOES( 0 );
    
}

-(void)setupOBJBuffers:(NSString*)filename
{
    std::vector<GLfloat> vecData;
    std::vector<GLuint> vecIndex;
    [self LoadWaveFrontOBJ:filename vecVerts:&vecData vecInds:&vecIndex];
    _OBJIndexCount = vecIndex.size();
    
    NSLog(@"vecData: %ld", vecData.size());
    NSLog(@"vecData: %ld", vecIndex.size());
    
    // Make the vertex buffer
    glGenBuffers( 1, &_OBJVerticesVBO );
    glBindBuffer( GL_ARRAY_BUFFER, _OBJVerticesVBO );
    glBufferData( GL_ARRAY_BUFFER, vecData.size()*sizeof(GLfloat), &(vecData[0]), GL_STATIC_DRAW );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    		
    // Make the indices buffer
    glGenBuffers( 1, &_OBJIndicesVBO );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _OBJIndicesVBO );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, vecIndex.size()*sizeof(GLuint), &(vecIndex[0]), GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
    //Create VAO
    glGenVertexArraysOES( 1, &_OBJVAO );
    
}

-(void)drawOBJ
{
    glUseProgram( _phongShader.program );
    [self setPhongUniforms];
    
    glBindVertexArrayOES( _OBJVAO );
    
    //Bind attributes
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _OBJVerticesVBO );
    
    glEnableVertexAttribArray( MainShaderAttributeVertex );
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glEnableVertexAttribArray( MainShaderAttributeNormal );
    glVertexAttribPointer( MainShaderAttributeNormal, 3, GL_FLOAT, GL_FALSE, stride, BUFFER_OFFSET( stride*3/8 ) );
    
    glUniform4f(_phongShader.uniforms[PhongShaderUniformMaterialColor], 0.0, 0.65, 0.0, 1.0f);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _OBJIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, _OBJIndexCount, GL_UNSIGNED_INT, NULL );
    glBindVertexArrayOES( 0 );
}

-(void)drawOBJShadow
{
    glUseProgram( _shadowShader.program );
    
    glBindVertexArrayOES( _OBJVAO );
    
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glBindBuffer( GL_ARRAY_BUFFER, _OBJVerticesVBO );
    
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glUniformMatrix4fv(_shadowShader.uniforms[ShadowShaderUniformDepthMVP], 1, GL_FALSE, _depthMVPMatrix.m);
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _OBJIndicesVBO );
    
    glDrawElements( GL_TRIANGLES, _OBJIndexCount, GL_UNSIGNED_INT, NULL );
    
    glBindVertexArrayOES( 0 );
}

-(void)setupScreenSpaceQuad
{
    glUseProgram( _screenShader.program );
    
    // Make the vertex buffer
    glGenBuffers( 1, &_screenVerticesVBO );
    glBindBuffer( GL_ARRAY_BUFFER, _screenVerticesVBO );
    glBufferData( GL_ARRAY_BUFFER, sizeof(ScreenVertexData), ScreenVertexData, GL_STATIC_DRAW );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    
    // Make the indices buffer
    glGenBuffers( 1, &_screenIndicesVBO );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _screenIndicesVBO );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(ScreenIndicesData), ScreenIndicesData, GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
    // Bind the attribute pointers to the VAO
    GLsizei stride = sizeof(GLfloat) * 8; // 3 vert, 3 normal, 2 texture
    glGenVertexArraysOES( 1, &_screenVAO );
    glBindVertexArrayOES( _screenVAO );
    
    glBindBuffer( GL_ARRAY_BUFFER, _screenVerticesVBO );
    
    glEnableVertexAttribArray( MainShaderAttributeVertex );
    glVertexAttribPointer( MainShaderAttributeVertex, 3, GL_FLOAT, GL_FALSE, stride, NULL );
    
    glUniform1i(_screenShader.uniforms[ScreenShaderUniformTextureSampler], 0); //Texture unit 0 is for base images.
    
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, _screenIndicesVBO );
    
    glBindVertexArrayOES( 0 );
}

-(void)drawScreenQuadwithTexture:(GLuint)texture andShader:(Shader*)shader
{
    //DRAW SCREEN QUAD
    glDisable(GL_CULL_FACE);
    glBindVertexArrayOES( _screenVAO );
    glUseProgram( shader.program );
    glActiveTexture(GL_TEXTURE0 + 0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glGenerateMipmapOES(GL_TEXTURE_2D);
    glDrawElements( GL_TRIANGLES, sizeof(ScreenIndicesData)/sizeof(GLuint), GL_UNSIGNED_INT, NULL );
}



-(void)setupRenderBufferTextureA
{
    glGenTextures(1, &_renderTextureA);
    glBindTexture(GL_TEXTURE_2D, _renderTextureA);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glGenerateMipmapOES(GL_TEXTURE_2D);
    
    
    // create framebuffer
    glGenFramebuffersOES(1, &_renderBufferA);//1
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _renderBufferA);//2
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _renderTextureA, 0);
    
    GLuint depthbuffer;
    glGenRenderbuffers(1, &depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthbuffer);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER_OES);
    if(status != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Framebuffer status: %x", (int)status);
    
    // unbind frame buffer
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
}

-(void)setupRenderBufferTextureB
{
    glGenTextures(1, &_renderTextureB);
    glBindTexture(GL_TEXTURE_2D, _renderTextureB);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glGenerateMipmapOES(GL_TEXTURE_2D);
    
    // create framebuffer
    glGenFramebuffersOES(1, &_renderBufferB);//1
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _renderBufferB);//2
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _renderTextureB, 0);
    
    GLuint depthbuffer;
    glGenRenderbuffers(1, &depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, RENDERTEXTURE_A_RES, RENDERTEXTURE_A_RES);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthbuffer);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER_OES);
    if(status != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Framebuffer status: %x", (int)status);
    
    // unbind frame buffer
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, 0);
}

-(void)setUniforms
{
    glUniformMatrix4fv(_mainShader.uniforms[MainShaderUniformMatrixModel], 1, GL_FALSE, _modelMatrix.m);
    glUniformMatrix4fv(_mainShader.uniforms[MainShaderUniformMatrixModelView], 1, GL_FALSE, _modelViewMatrix.m);
    glUniformMatrix4fv(_mainShader.uniforms[MainShaderUniformMatrixProjection], 1, GL_FALSE, _projectionMatrix.m);
    bool success;
    GLKMatrix4 normalMatrix4 = GLKMatrix4InvertAndTranspose(_modelMatrix, &success);
    if (success) {
        GLKMatrix3 normalMatrix3 = GLKMatrix4GetMatrix3(normalMatrix4);
        glUniformMatrix3fv(_mainShader.uniforms[MainShaderUniformMatrixNormalModel], 1, GL_FALSE, normalMatrix3.m);
    }
    glUniformMatrix4fv(_mainShader.uniforms[MainShaderUniformMatrixDepthBiasMVP], 1, GL_FALSE, _depthBiasMVP.m);
    glUniform3f(_mainShader.uniforms[MainShaderUniformLightPosition], _lightPosition.x, _lightPosition.y, _lightPosition.z);
    glUniformMatrix4fv(_mainShader.uniforms[MainShaderUniformLightViewMatrix], 1, GL_FALSE, _viewMatrixLight.m);
    glUniform1f(_mainShader.uniforms[MainShaderUniformLightIntensity], 1.0);
    glUniform4f(_mainShader.uniforms[MainShaderUniformMaterialColor], 0.65, 0.65, 0.65, 1.0f);
    glUniform4f(_mainShader.uniforms[MainShaderUniformMaterialAmbient], 0.1, 0.1, 0.1, 1.0f);
    glUniform1f(_mainShader.uniforms[MainShaderUniformShadowMapResolution], RENDERTEXTURE_A_RES);
    glUniform1i(_mainShader.uniforms[MainShaderUniformShadowSampler], 0); //Texture unit 0 is for shadowmaps
    glActiveTexture(GL_TEXTURE0 + 0);
    glBindTexture(GL_TEXTURE_2D, _renderTextureA);
    glUniform1i(_mainShader.uniforms[MainShaderUniformEdgeSampler], 2); //Texture unit 0 is for edgemaps
    glActiveTexture(GL_TEXTURE0 + 2);
    glBindTexture(GL_TEXTURE_2D, _renderTextureB);
    glGenerateMipmapOES(GL_TEXTURE_2D);
    
}

-(void)setPhongUniforms
{
    glUniformMatrix4fv(_phongShader.uniforms[PhongShaderUniformMatrixModel], 1, GL_FALSE, _modelMatrix.m);
    glUniformMatrix4fv(_phongShader.uniforms[PhongShaderUniformMatrixModelView], 1, GL_FALSE, _modelViewMatrix.m);
    glUniformMatrix4fv(_phongShader.uniforms[PhongShaderUniformMatrixProjection], 1, GL_FALSE, _projectionMatrix.m);
    bool success;
    GLKMatrix4 normalMatrix4 = GLKMatrix4InvertAndTranspose(_modelMatrix, &success);
    if (success) {
        GLKMatrix3 normalMatrix3 = GLKMatrix4GetMatrix3(normalMatrix4);
        glUniformMatrix3fv(_phongShader.uniforms[PhongShaderUniformMatrixNormalModel], 1, GL_FALSE, normalMatrix3.m);
    }

    glUniform3f(_phongShader.uniforms[PhongShaderUniformLightPosition], _lightPosition.x, _lightPosition.y, _lightPosition.z);
    glUniformMatrix4fv(_phongShader.uniforms[PhongShaderUniformLightViewMatrix], 1, GL_FALSE, _viewMatrixLight.m);
    glUniform1f(_phongShader.uniforms[PhongShaderUniformLightIntensity], 1.0);
    glUniform4f(_phongShader.uniforms[PhongShaderUniformMaterialColor], 0.65, 0.65, 0.65, 1.0f);
    glUniform4f(_phongShader.uniforms[PhongShaderUniformMaterialAmbient], 0.5, 0.5, 0.5, 1.0f);
}

/* UI METHODS */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    _xTouchLoc = location.x;
    _yTouchLoc = location.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    
    //rotate whole scene
    GLKMatrix4 rotatedSceneModel = GLKMatrix4RotateY(GLKMatrix4Identity,(location.x-_xTouchLoc)*0.005);
    //_modelMatrix = rotatedSceneModel;
    //_modelViewMatrix = GLKMatrix4Multiply(_viewMatrix,_modelMatrix);
    
    _cameraPosition = GLKMatrix4MultiplyVector3(rotatedSceneModel, _cameraPosition);
    _viewMatrix = GLKMatrix4MakeLookAt(_cameraPosition.x, _cameraPosition.y, _cameraPosition.z,
                                       90.0, 140.0, 0.0,
                                       0.0f, 1.0f, 0.0f);
    _modelViewMatrix = GLKMatrix4Multiply(_viewMatrix,_modelMatrix);
    
    _xTouchLoc = location.x;
    _yTouchLoc = location.y;
}

-(void)Scale:(UIPinchGestureRecognizer*)sender
{
    
    CGFloat scale = _lastScale + (1.0 - [(UIPinchGestureRecognizer*)sender scale])*0.5;
    
    float newScale = MAX(0.1, MIN(scale, 3));
    _projectionMatrix = GLKMatrix4MakePerspective(newScale*GLKMathDegreesToRadians(45.0),
                                                  (float)self.screenWidth/(float)self.screenHeight,
                                                  1.0, 500.0);
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		_lastScale = newScale;
		return;
	}
}

-(void)Tap:(UITapGestureRecognizer*)sender
{
    //increment shadowmode
    _shadowMode = (ShadowMode)((_shadowMode+1)%3);
    //change shader
    switch (_shadowMode)
    {
        case ShadowModeHard:
            _mainShader = _mainShaderHard;
            break;
        case ShadowModeSoft:
            _mainShader = _mainShaderSoft;
            break;
        case ShadowModeVariable:
            _mainShader = _mainShaderVariable;
            break;
        default:
            _mainShader = _mainShaderHard;
            
    }
    //update UI
    [_textLabel setText:[NSString stringWithFormat:@"iOS Shadowing. MSAA enabled. 6700ish faces. \nSwipe to rotate. \nDouble-tap-two-fingers to see edge map.\nDouble-tap-one-finger to change shadowing mode. \nCurrent Mode: %@", [self currentShadowModeString]]];
}

-(void)Tap22:(UITapGestureRecognizer*)sender
{
    _showEdgeMap = !_showEdgeMap;
}

//quick method to return a string for current shadow mode
-(NSString*)currentShadowModeString
{
    NSString *currMode = @"";
    switch (_shadowMode)
    {
        case ShadowModeHard:
            currMode = @"Hard Shadows";
            break;
        case ShadowModeSoft:
            currMode = @"Soft Shadows";
            break;
        case ShadowModeVariable:
            currMode = @"Variable Shadows";
            break;
        default:
            currMode = @"Error!";
            
    }
    return currMode;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* OBJ IMPORTER */

//helper function for object parsing
- (NSString *)trimWhitespace:(NSString*)str {
    NSMutableString *mStr = [str mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mStr);
    return [mStr copy];
}

- (void)LoadWaveFrontOBJ:(NSString*)fileName vecVerts:(std::vector<GLfloat>*)vecData vecInds:(std::vector<GLuint>*)vecIndex
{
    NSLog(@"Loading %@",fileName);
    
    //init vars
    int vertexCount = 0, normalCount = 0, faceCount = 0, textureCoordsCount=0, quadTriError = 0, mapCounter = 0;
    GLubyte valuesPerCoord; BOOL firstTextureCoords = YES;
    std::map <std::string, int> mapVertexCombinations; //hashtable for reverse lookup speed
    std::vector<std::string> vecVertexCombinations; //vector for forward lookup speed
    std::vector<std::string> vecIndexArray; //store all face infices
    
    vecVertexCombinations.reserve(32768);
    
    //get data
    NSString *baseName = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *fileType = [[fileName componentsSeparatedByString:@"."] objectAtIndex:1];
    NSString *path = [[NSBundle mainBundle] pathForResource:baseName ofType:fileType];
    NSString *objData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    //first loop
    NSArray *lines = [objData componentsSeparatedByString:@"\n"];
    for (NSString * line in lines)
    {
        
        if ([line hasPrefix:@"v "]) vertexCount++;
        else if ([line hasPrefix:@"vn "]) normalCount++;
        else if ([line hasPrefix:@"vt "])
        {
            textureCoordsCount++;
            if (firstTextureCoords) // count to see how many texture coords there
            {
                firstTextureCoords = NO;
                NSString *texLine = [line substringFromIndex:3];
                texLine = [self trimWhitespace:texLine];
                NSArray *texParts = [texLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                valuesPerCoord = [texParts count];
            }
        }
        else if ([line hasPrefix:@"f"])
        {
            NSString *faceLine = [line substringFromIndex:2];
            faceLine = [self trimWhitespace:faceLine];
            NSArray *faces = [faceLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([faces count] == 3){ //tris okay no problem
                faceCount++;
                vecIndexArray.push_back([[faces objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:2] cStringUsingEncoding:NSUTF8StringEncoding]);
                for (NSString *oneFace in faces)
                {
                    
                    std::map<std::string,int>::iterator it = mapVertexCombinations.find([oneFace cStringUsingEncoding:NSUTF8StringEncoding]);
                    if (it == mapVertexCombinations.end())
                    {
                        mapVertexCombinations[[oneFace cStringUsingEncoding:NSUTF8StringEncoding]] = mapCounter;
                        mapCounter++;
                        vecVertexCombinations.push_back([oneFace cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                }
            }
            else if ([faces count] == 4) //make two tris from quad
            {
                faceCount+=2;
                // 0-1-2 0-2-3
                vecIndexArray.push_back([[faces objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:2] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:2] cStringUsingEncoding:NSUTF8StringEncoding]);
                vecIndexArray.push_back([[faces objectAtIndex:3] cStringUsingEncoding:NSUTF8StringEncoding]);
                for (NSString *oneFace in faces)
                {
                    std::map<std::string,int>::iterator it = mapVertexCombinations.find([oneFace cStringUsingEncoding:NSUTF8StringEncoding]);
                    if (it == mapVertexCombinations.end())
                    {
                        mapVertexCombinations[[oneFace cStringUsingEncoding:NSUTF8StringEncoding]] = mapCounter;
                        mapCounter++;
                        vecVertexCombinations.push_back([oneFace cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                }
            }
            else quadTriError = 1;
        }
    }
    
    //initialise raw data arrays
    GLfloat RawVertexData[vertexCount*3];
    GLfloat RawNormalData[normalCount*3];
    GLfloat RawTextureData[textureCoordsCount*2];
    int vertexCountx3 = 0;
    int normCountx3 = 0;
    int texCountx2 = 0;
    
    //second loop
    for (NSString * line in lines)
    {
        if ([line hasPrefix:@"v "])
        {
            NSString *lineTrunc = [line substringFromIndex:2];
            lineTrunc = [self trimWhitespace:lineTrunc];
            NSArray *lineVertices = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            RawVertexData[vertexCountx3] = [[lineVertices objectAtIndex:0] floatValue];
            RawVertexData[vertexCountx3+1] = [[lineVertices objectAtIndex:1] floatValue];
            RawVertexData[vertexCountx3+2] = [[lineVertices objectAtIndex:2] floatValue];
            vertexCountx3+=3;
        }
        
        else if ([line hasPrefix: @"vn "])
        {
            NSString *lineTrunc = [line substringFromIndex:3];
            lineTrunc = [self trimWhitespace:lineTrunc];
            NSArray *lineNorms = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            RawNormalData[normCountx3] = [[lineNorms objectAtIndex:0] floatValue];
            RawNormalData[normCountx3+1] = [[lineNorms objectAtIndex:1] floatValue];
            RawNormalData[normCountx3+2] = [[lineNorms objectAtIndex:2] floatValue];
            normCountx3+=3;
            
        }
        else if ([line hasPrefix: @"vt "])
        {
            NSString *lineTrunc = [line substringFromIndex:3];
            lineTrunc = [self trimWhitespace:lineTrunc];
            NSArray *lineCoords = [lineTrunc componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            RawTextureData[texCountx2++] = [[lineCoords objectAtIndex:0] floatValue];
            RawTextureData[texCountx2++] = [[lineCoords objectAtIndex:1] floatValue];
        }
    }
    
    //Fill final data arrays
    GLuint dataBufferSize = mapVertexCombinations.size();
    GLfloat dataBuffer[dataBufferSize*8];
    int buffPos = 0;


    
    for (int i = 0; i<vecVertexCombinations.size(); i++)
    {
        
        const char *key = "bob";
        std::string currFace = vecVertexCombinations[i];
        std::map<std::string,int>::iterator it = mapVertexCombinations.find(currFace);
        
        if (it != mapVertexCombinations.end())
            key = it->first.c_str();
        
        NSString *pair = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
        NSArray *pairParts = [pair componentsSeparatedByString:@"/"];
        int currVertexPos = [[pairParts objectAtIndex:0] intValue]-1; // we substract one because file string is not 0-based
        //int currTextPos = [[pairParts objectAtIndex:1] intValue]-1; //only used with textures
        int currNormalPos = [[pairParts objectAtIndex:2] intValue]-1;
        
        //add three vert coords
        dataBuffer[buffPos] = RawVertexData[currVertexPos*3];
        dataBuffer[buffPos+1] = RawVertexData[currVertexPos*3+1];
        dataBuffer[buffPos+2] = RawVertexData[currVertexPos*3+2];
        
        //add three normal coords
        dataBuffer[buffPos+3] = RawNormalData[currNormalPos*3];
        dataBuffer[buffPos+4] = RawNormalData[currNormalPos*3+1];
        dataBuffer[buffPos+5] = RawNormalData[currNormalPos*3+2];
        
        //add three text coords
        dataBuffer[buffPos+6] = 0.0;//RawTextureData[currTextPos*2];
        dataBuffer[buffPos+7] = 0.0;//(1-RawTextureData[currTextPos*2+1]);
        
        buffPos+=8;
    }
    
    //  Create new index buffer by searching for i/j/k string
    GLuint indexBuffer[faceCount*3];
    //indexBuffer = (GLuint*)malloc(faceCount*8 * sizeof(GLuint));
    GLuint indexBufferSize = faceCount*3;
    
    for (int i = 0; i < faceCount*3; i+=3)
    {
        
        std::map<std::string,int>::iterator it = mapVertexCombinations.find(vecIndexArray[i]);
        if (it != mapVertexCombinations.end())
            indexBuffer[i] = it->second;
        
        it = mapVertexCombinations.find(vecIndexArray[i+1]);
        if (it != mapVertexCombinations.end())
            indexBuffer[i+1] = it->second;
        
        it = mapVertexCombinations.find(vecIndexArray[i+2]);
        if (it != mapVertexCombinations.end())
            indexBuffer[i+2] = it->second;
    }
    
    //push constructed buffers into stl vectors for ease of transport
    GLuint dbSize =dataBufferSize*8;
    
    for(int i=0;i<dbSize;i++)
        vecData->push_back(dataBuffer[i]);
    for(int i=0;i<indexBufferSize;i++)
        vecIndex->push_back(indexBuffer[i]);
    

}


@end
