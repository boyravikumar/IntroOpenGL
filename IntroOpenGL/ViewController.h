//
//  ViewController.h
//  IntroOpenGL
//
//  Created by boyapati ravi kumar on 30/06/15.
//  Copyright (c) 2015 Custom Furniish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController

-(void) changeRocketLocation:(UITapGestureRecognizer *) gestureRecognizer;
-(void) shoot:(UISwipeGestureRecognizer *) gestureRecognizer;

@end

