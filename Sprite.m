//
//  Sprite.m
//  IntroOpenGL
//
//  Created by boyapati ravi kumar on 30/06/15.
//  Copyright (c) 2015 Custom Furniish. All rights reserved.
//

#import "Sprite.h"

@interface Sprite()

@property (nonatomic, weak) GLKBaseEffect *baseEffect;

@end

@implementation Sprite

- (id)initWithEffect:(GLKBaseEffect *)baseEffect {
    
    if( (self = [super init])) {
        self.baseEffect = baseEffect;
       
    }
    
    return self;    
}

- (void) render {
    
    self.baseEffect.texture2d0.name = self.textureInfo.name;
    self.baseEffect.texture2d0.target = self.textureInfo.target;
    
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, self.position.x, self.position.y, 0);
 
    GLKMatrix4 modelViewMatrixTranslate = GLKMatrix4Translate(modelViewMatrix, SQUARE_SIZE /2 , SQUARE_SIZE / 2, 0);
    
    GLKMatrix4 modelViewMatrixRotation = GLKMatrix4Rotate(modelViewMatrixTranslate, GLKMathDegreesToRadians(self.rotation), 0.f, 0.f, 1.f);
    
    GLKMatrix4 modelViewMatrixReTranslate = GLKMatrix4Translate(modelViewMatrixRotation, - SQUARE_SIZE /2 , - SQUARE_SIZE / 2, 0);
    
    
    self.baseEffect.transform.modelviewMatrix = modelViewMatrixReTranslate;
    
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void) update {
    self.position = GLKVector2Add(self.position , self.velocity);
    self.rotation += self.rotationVelocity;
}
@end
