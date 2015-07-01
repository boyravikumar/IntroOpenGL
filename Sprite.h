//
//  Sprite.h
//  IntroOpenGL
//
//  Created by boyapati ravi kumar on 30/06/15.
//  Copyright (c) 2015 Custom Furniish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


#define SQUARE_SIZE 40.0f

@interface Sprite : NSObject

-(id)initWithEffect : (GLKBaseEffect *) baseEffect;

@property(nonatomic,strong) GLKTextureInfo * textureInfo;
@property(assign) GLKVector2 position;
@property (assign) float rotation;
@property (assign) GLKVector2 velocity;
@property (assign) float rotationVelocity;

- (void) render;

- (void) update;

@end
