//
//  tryAgain.m
//  StickHero
//
//  Created by apple on 14-11-27.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "tryAgain.h"
#define NAME_BACKGROUNG @"background"
#define NAME_AGAIN @"again"

@interface tryAgain()
@property (strong, nonatomic)SKSpriteNode *background;
@property (strong, nonatomic)SKLabelNode *again;
@end

@implementation tryAgain

-(instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    if(self = [super initWithColor:color size:size])
    {
        self.userInteractionEnabled = YES;
        
        self.background = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(150, 60)];
        self.background.position = CGPointMake(self.position.x / 2, self.position.y / 2);
        self.background.name = NAME_BACKGROUNG;
        [self addChild:self.background];
        
        self.again = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        self.again.text = @"😂Try Again";
        self.again.fontColor = [SKColor blackColor];
        self.again.fontSize = 30;
        self.again.name = NAME_AGAIN;
        self.again.position = CGPointMake(self.background.position.x / 2, self.background.position.y / 2);
        [self.background addChild:self.again];
    }
    return self;
}

+(instancetype)initButton:(CGSize)size
{
    tryAgain *tryAgainView = [tryAgain spriteNodeWithColor:[SKColor colorWithRed:255 green:255 blue:255 alpha:0.7] size:size];
    return tryAgainView;
}

-(void)showInscene:(SKScene *)scene
{
    [scene addChild:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];//确定触摸点处存在的节点
    
    if([[touchNode name]isEqualToString:NAME_BACKGROUNG] || [[touchNode name]isEqualToString:NAME_AGAIN])
    {
        [self removeFromParent];
        [self.delegate restartView:self];
    }
}

@end
