//
//  Shader.h
//
//  Created by Alun on 4/3/13.
//  Copyright (c) 2013 GTI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shader : NSObject

@property (assign) GLint program;
@property (nonatomic, assign) NSUInteger numAttributes;
@property (nonatomic, readonly) GLuint *uniforms;


-(id)initProgramWithVertex:(NSString*)vertex Fragment:(NSString*)fragment Attributes:(NSArray*)attributes Uniforms:(NSArray*)uniforms Flags:(NSArray*)flags;

@end
