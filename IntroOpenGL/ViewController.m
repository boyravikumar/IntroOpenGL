//
//  ViewController.m
//  IntroOpenGL
//
//  Created by boyapati ravi kumar on 30/06/15.
//  Copyright (c) 2015 Custom Furniish. All rights reserved.
//

#import "ViewController.h"
#import "Sprite.h"

typedef struct{
    GLKVector3 positionCoordinates;
    GLKVector2 textureCoordinates;
} VertexData;





VertexData vertices [] = {

    { {0.0f, 0.0f, 0.0f},{0.0f, 0.0f} } ,
    {  {SQUARE_SIZE, 0.0f, 0.0f},{1.0f, 0.0f}} ,
    {{0.0f, SQUARE_SIZE, 0.0f},{0.0f, 1.0f}},
    {{0.0f, SQUARE_SIZE, 0.0f},{0.0f, 1.0f}},
    {{SQUARE_SIZE, 0.0f, 0.0f},{1.0f, 0.0f}},
    {{SQUARE_SIZE, SQUARE_SIZE, 0.0f}, {1.0f, 1.0f}}
    
};

@interface ViewController ()
@property (nonatomic,strong) EAGLContext *context;
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) Sprite *rocket;
@property (nonatomic, strong) NSMutableArray *rocks;
@end

@implementation ViewController {
    
    GLuint _vertexBufferID;
    GLKTextureInfo * textureInfoBall;
    GLKTextureInfo * textureInfoRock;
    GLKTextureInfo * textureInfoRocket;
    NSMutableArray *balls;
    float screenHeight;
    float screenWidth;
    
    float currentRockVelocity;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        balls = [[NSMutableArray alloc] initWithCapacity:20 ];
        self.rocks =  [[NSMutableArray alloc] initWithCapacity:20 ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"viewDidLoad");
    
    self.context = [ [EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *) self.view;
    view.context = self.context;
    
    [EAGLContext setCurrentContext:self.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init ];
    self.baseEffect.useConstantColor= YES;
    
    CGSize screensize =[[UIScreen mainScreen ] bounds ].size;
    screenHeight = screensize.height;
    screenWidth = screensize.width;

    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, screensize.width, 0, screensize.height, 0, 1);
    
    
    glClearColor(1.0f,1.0f, 1.0f, 1.0f);
    
    
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER,sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid *) offsetof(VertexData, positionCoordinates) );
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, FALSE, sizeof (VertexData), (GLvoid *) offsetof(VertexData, textureCoordinates));
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    UITapGestureRecognizer *gestureRecognizer = [ [UITapGestureRecognizer alloc] initWithTarget:self action: @selector(changeRocketLocation:)];
    [self.view addGestureRecognizer:gestureRecognizer ];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shoot:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp ];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    textureInfoBall = [ self loadTextureFromImage:@"ball.png" ];
    textureInfoRock = [ self loadTextureFromImage:@"rock.png" ];
    textureInfoRocket = [ self loadTextureFromImage:@"rocket.png" ];
    
    
    
    self.rocket = [[Sprite alloc] initWithEffect:self.baseEffect];
    self.rocket.textureInfo = textureInfoRocket;
    self.rocket.position = GLKVector2Make(screensize.width - SQUARE_SIZE, 0 );
    self.rocket.rotation = 0;
    
    currentRockVelocity = 5;
    
}

- (GLKTextureInfo *) loadTextureFromImage: (NSString *) pngName
{
    GLKTextureInfo * textureInfo;
    CGImageRef imageReference =  [ [UIImage imageNamed: pngName] CGImage ];
    textureInfo = [GLKTextureLoader textureWithCGImage:imageReference
                                                   options: [ NSDictionary
                                                             dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                             forKey:GLKTextureLoaderOriginBottomLeft ]
                                                     error:NULL];
    return textureInfo;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1,&_vertexBufferID);
    
    GLuint textureBufferId = self.rocket.textureInfo.name;
    glDeleteTextures(1, &textureBufferId);
    
    textureBufferId = textureInfoBall.name;
    glDeleteTextures(1, &textureBufferId);
    
    textureBufferId = textureInfoRock.name;
    glDeleteTextures(1, &textureBufferId);
    
    self.baseEffect = nil;
    self.context = nil;
    
    [EAGLContext setCurrentContext:nil ];
    
}


- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.rocket render];
 
    for (Sprite *ball in balls) {
 
        if(!(ball.position.y > self.view.bounds.size.height * 2)) {
            [ball render ];
        }        
        
    }
    
    for (Sprite *rock in self.rocks) {
        
        if(rock.position.y > 0 - SQUARE_SIZE) {
            [rock render ];
        }
        
    }
}

-(void) addRock {
    
    Sprite * newRock;
    
    int xLocation = (  arc4random() %  (int)(screenWidth - SQUARE_SIZE) ) ;
    
    
    int yLocation = screenHeight;
    
    for (Sprite *rock in self.rocks) {
        
        if  ( !(rock.position.y > 0 - SQUARE_SIZE) ){
            newRock= rock;
            newRock.position = GLKVector2Make(xLocation, yLocation-1);
            newRock.velocity = GLKVector2Make(0.0f, -currentRockVelocity);
            //NSLog(@"xLocation is %d", xLocation);
            break;
        }
    }
    
    if(newRock == nil) {
        
        newRock=  [ [Sprite alloc] initWithEffect:self.baseEffect ];
        newRock.textureInfo = textureInfoRock;
        newRock.position = GLKVector2Make(xLocation, yLocation -1);
        newRock.velocity = GLKVector2Make(0.0f, -currentRockVelocity);
        newRock.rotation = 10;
        newRock.rotationVelocity = 10;
        
        [self.rocks addObject:newRock ];
        //NSLog(@"xLocation is %d", xLocation);
    }
    
}

- (BOOL) checkForCollision:(Sprite * ) obj1 :(Sprite * ) obj2 {
    
    if( obj1.position.x + SQUARE_SIZE <= obj2.position.x ||
        obj1.position.x >= obj2.position.x + SQUARE_SIZE ||
        obj1.position.y + SQUARE_SIZE <= obj2.position.y ||
        obj1.position.y >= obj2.position.y + SQUARE_SIZE
       ) {
        return NO;
    }
    return YES;
}

- (void) update
{
    static int collissionCount = 0;
    
    for (Sprite * rock in self.rocks) {
        
        if ([self checkForCollision:rock : self.rocket]) {
            rock.position = GLKVector2Make(0.0f, 0 - SQUARE_SIZE);
        }
        for (Sprite * ball in balls) {
            if  ( [ self checkForCollision:rock :ball ] ) {
                collissionCount += 1;
                
                if(collissionCount == 10 ) {
                    collissionCount=0;
                    currentRockVelocity +=1;
                }
                rock.position = GLKVector2Make(0.0f, 0 - SQUARE_SIZE);
                ball.position = GLKVector2Make(0.0f, screenHeight);;
            }
        }
    }
        
    static double lastRock = 0.0f;
    
    lastRock += self.timeSinceLastUpdate;
    
    if(lastRock >= 1.0f) {
        [self addRock ];
        lastRock = 0.0f;
    }
    
    [self.rocket update];
    
    for (Sprite *ball in balls) {
        
        if(!(ball.position.y > screenHeight)) {
            [ball update ];
        }
        
    }
    
    for (Sprite *rock in self.rocks) {
        
        if( rock.position.y > 0 - SQUARE_SIZE) {
            [rock update ];
        }
        
    }
}

-(void) shoot:(UISwipeGestureRecognizer *) gestureRecognizer {
    
    NSLog(@"SWIPE RECOGNIZED");
    
    Sprite * ball;
    
    for (Sprite * newBall  in balls) {
        if (newBall.position.y > screenHeight) {
            ball = newBall;
            ball.position = GLKVector2Add(self.rocket.position, GLKVector2Make(0.0f, 0.8 * SQUARE_SIZE));
            ball.rotation = 0;
        
            break;
        }
    }
    
    if(ball == nil ){
        ball =  [[Sprite alloc] initWithEffect:self.baseEffect];
        ball.textureInfo = textureInfoBall;
        ball.position = GLKVector2Add(self.rocket.position, GLKVector2Make(0.0f, 0.8 * SQUARE_SIZE));
        ball.velocity = GLKVector2Make(0.0f, 10.0f);
        ball.rotation = 0;
        ball.rotationVelocity = 10;
        [balls addObject:ball];

    }
    
}



-(void) changeRocketLocation:(UITapGestureRecognizer *) gestureRecognizer {
    
    int xLocation = [gestureRecognizer locationInView:self.view].x;
    
    if (xLocation >  screenWidth - SQUARE_SIZE) {
        xLocation = screenWidth - SQUARE_SIZE;
    }
    self.rocket.position = GLKVector2Make(xLocation, 0);
    
    
}

@end
