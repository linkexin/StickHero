//
//  MyScene.m
//  StickHero
//
//  Created by apple on 14-11-24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "MyScene.h"
#import "tryAgain.h"
#define ARC4RANDOM_MAX 0x100000000

#define HIGH_HERO 18
#define HIGH_COLUMN self.frame.size.height * .3
#define WIDE_HERO 16
#define WIDE_STICK 2

#define NAME_HERO @"hero"
#define NAME_COLUMN @"column1"
#define NAME_COLUMN2 @"column2"
#define NAME_STICK @"stick"
#define ACTION_WALK @"walk"

#define POSITION_COLUMN self.frame.size.width * .15
#define ZPOSITION_SCORE 3;
#define ZPOSITION_HERO 1;
#define ZPOSITION_COLUMN 2;
#define ZPOSITION_GAMEOVER 4;

#define ACTION_STICK @"long"
#define ACTION_COLUMNMOVE @"columnmove"
#define ACTION_HEROMOVE @"heromove"

@interface MyScene()<SKPhysicsContactDelegate, tryAgainDelegate>
@property (strong, nonatomic)SKSpriteNode *worldNode;
@property (strong, nonatomic)SKSpriteNode *hero;
@property (strong, nonatomic)SKLabelNode *score;
@property (strong, nonatomic)SKLabelNode *addOne;
@property (strong, nonatomic)SKLabelNode *getScore;
@property (strong, nonatomic)SKAction *actionWalk;

@property (nonatomic)float columnDistance;
@property (nonatomic)float columnWide1;
@property (nonatomic)float columnWide2;
@property (nonatomic)float columnHigh;
@property (nonatomic)int scoreNum;
@property (nonatomic)BOOL isLengthen;
@property (nonatomic)BOOL isAllow;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.physicsWorld.contactDelegate = self;
        NSMutableArray *bg = [[NSMutableArray alloc]initWithCapacity:5];
        for(int i = 0; i < 4; i++)
        {
            NSString *str = [NSString stringWithFormat:@"bg%d.png", i + 1];
            [bg addObject:str];
        }
        
        self.getScore = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        self.getScore.text = @"+1";
        self.getScore.fontSize = 15;
        
        self.score = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        self.score.text = @"0";
        self.score.fontColor = [SKColor blackColor];
        self.score.fontSize = 35;
        self.score.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - 100);
        self.score.zPosition = ZPOSITION_SCORE;
        [self start];
    }
    return self;
}

-(void)start
{
    //背景
    self.backgroundColor = [SKColor whiteColor];
    self.worldNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"bg%d.png", arc4random() % 5 + 1]] size:CGSizeMake(self.scene.size.width, self.scene.size.height)];
    self.worldNode.position = CGPointMake(self.scene.size.width / 2, self.scene.size.height / 2);
    [self addChild:self.worldNode];
    
    self.columnWide1 = arc4random() % 50 + 15;
    self.columnWide2 = arc4random() % 50 + 15;
    self.columnDistance = arc4random() % 240;
    while (self.columnDistance <= (self.columnWide1 / 2 + self.columnWide2 / 2 + 3))
        self.columnDistance = arc4random() % 240;
    [self addHeroNode];
    self.isLengthen = NO;
    self.isAllow = NO;
    self.scoreNum = 0;
    
    self.score.text = @"0";
    [self addChild:self.score];
    
    SKSpriteNode *column1 = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.columnWide1, HIGH_COLUMN)];
    column1.name = NAME_COLUMN;
    column1.position = CGPointMake(POSITION_COLUMN, HIGH_COLUMN / 2);
    SKSpriteNode *column2 = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.columnWide2, HIGH_COLUMN)];
    column2.name = NAME_COLUMN;
    column2.position = CGPointMake(column1.position.x + self.columnDistance, HIGH_COLUMN / 2);
    [self addChild:column1];
    [self addChild:column2];
}

-(void)addHeroNode
{
    NSMutableArray *textures = [[NSMutableArray alloc]initWithCapacity:3];
    
    for(int i = 0; i < 2; i++)
    {
        NSString *str = [NSString stringWithFormat:@"human%d.png", i + 1];
        SKTexture *tex = [SKTexture textureWithImageNamed:str];
        [textures addObject:tex];
    }
    
    SKAction *actionWalk1 = [SKAction setTexture:[textures objectAtIndex:0]];
    SKAction *actionWalk2 = [SKAction setTexture:[textures objectAtIndex:1]];
    SKAction *wait = [SKAction waitForDuration:0.15];
    self.actionWalk = [SKAction sequence:@[actionWalk1, wait, actionWalk2, wait, actionWalk1]];
    self.hero = [SKSpriteNode spriteNodeWithImageNamed:@"human.png"];
    //self.hero = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(WIDE_HERO, HIGH_HERO)];
    self.hero.size = CGSizeMake(WIDE_HERO, HIGH_HERO);
    self.hero.name = NAME_HERO;
    self.hero.zPosition = ZPOSITION_HERO;
    float temp = self.columnWide1 / 2 > (WIDE_HERO / 2 + 3) ? self.columnWide1 / 2 - (WIDE_HERO / 2 + 3) : 0;
    self.hero.position = CGPointMake(POSITION_COLUMN + temp, HIGH_COLUMN + HIGH_HERO / 2);
    self.hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(WIDE_HERO, HIGH_HERO)];
    self.hero.physicsBody.affectedByGravity = NO;
    self.hero.physicsBody.allowsRotation = NO;
    
    [self addChild:self.hero];
}

-(void)addColumnNode
{
    SKSpriteNode *stick = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(WIDE_STICK, 1)];
    stick.name = NAME_STICK;
    stick.size = CGSizeMake(WIDE_STICK, 1);
    stick.position = CGPointMake(self.hero.position.x + 5 + 3, HIGH_COLUMN - 1);
    [self addChild:stick];
    //NSLog(@"%f %f", stick.size.width, stick.size.height);
    self.columnWide1 = self.columnWide2;
    self.columnWide2 = arc4random() % 50 + 15;
    self.columnDistance = arc4random() % 240;
    while (self.columnDistance <= (self.columnWide1 / 2 + self.columnWide2 / 2 + 3))
        self.columnDistance = arc4random() % 240;
    
    SKSpriteNode *column = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(self.columnWide2, HIGH_COLUMN)];
    column.name = NAME_COLUMN;
    column.position = CGPointMake(self.size.width + self.columnWide2 / 2, HIGH_COLUMN / 2);
    SKAction *columnMove = [SKAction moveToX:self.columnDistance + POSITION_COLUMN duration:0.5];
    [column runAction:columnMove];
    [self addChild:column];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isLengthen == NO && self.isAllow == NO)
    {
        self.isLengthen = YES;
        SKSpriteNode *stick = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(WIDE_STICK, 1)];
        stick.name = NAME_STICK;
        stick.position = CGPointMake(self.hero.position.x + 5 + 3, HIGH_COLUMN - 1);
        stick.anchorPoint = CGPointMake(1, 0);
        [self addChild:stick];
        
        int high = self.size.height - HIGH_COLUMN;
        SKAction *addStick = [SKAction resizeToHeight:stick.size.height + high duration:1.5];
        
        [stick runAction:addStick withKey:ACTION_STICK];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isLengthen == YES && self.isAllow == NO)
    {
        self.isAllow = YES;
        [self enumerateChildNodesWithName:NAME_STICK usingBlock:^(SKNode *node, BOOL *stop){
            [node removeActionForKey:ACTION_STICK];
        }];
    
        SKAction *getDown = [SKAction rotateToAngle:-M_PI / 2 duration:0.4];
    
        [self enumerateChildNodesWithName:NAME_STICK usingBlock:^(SKNode *node, BOOL *stop){
            [node runAction: getDown];
            self.columnHigh = ((SKSpriteNode *)node).size.height;
        }];
    
        [self heroGo];
    }
}

-(void)heroGo
{
    /*
    NSLog(@"columnHigh = %f", self.columnHigh);
    NSLog(@"distance = %f", self.columnDistance);
    NSLog(@"wide1 = %f", self.columnWide1);
    NSLog(@"wide2 = %f", self.columnWide2);
     */
    float speed = 110;
    float dis;
    if(self.columnHigh > (self.columnDistance - self.columnWide1 / 2 + self.columnWide2 / 2) || self.columnHigh < (self.columnDistance - self.columnWide1 / 2 - self.columnWide2 / 2))
    {
        dis = self.hero.position.x + self.columnHigh + WIDE_HERO + 3;
        SKAction *heroMove = [SKAction moveToX:dis duration:self.columnHigh / speed];
        [self.hero runAction:[SKAction sequence:@[[SKAction waitForDuration:0.7], heroMove]]];
        
        [self.hero runAction:[SKAction sequence:@[[SKAction waitForDuration:0.7], [SKAction repeatActionForever:self.actionWalk]]]withKey:ACTION_WALK];
        
        [self.hero runAction:[SKAction sequence:@[[SKAction waitForDuration:self.columnHigh / speed + 0.7], [SKAction performSelector:@selector(changeGravity) onTarget:self], [SKAction waitForDuration:0.6], [SKAction performSelector:@selector(gameOver) onTarget:self]]]];
    }
    else
    {
        dis = self.columnWide2 / 2 > (WIDE_HERO / 2 + 3) ? self.columnWide2 / 2 - (WIDE_HERO / 2 + 3) : 0;
        dis += (self.columnDistance + POSITION_COLUMN);
        SKAction *heroMove = [SKAction moveToX:dis duration:self.columnDistance / speed];
        [self.hero runAction:[SKAction sequence:@[[SKAction waitForDuration:0.7], heroMove]]];
        [self.hero runAction:[SKAction sequence:@[[SKAction waitForDuration:0.7], [SKAction repeatActionForever:self.actionWalk]]]withKey:ACTION_WALK];
        
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:(dis - POSITION_COLUMN) / speed + 0.7], [SKAction performSelector:@selector(changeColumnPosition) onTarget:self]]]];
            }
}


-(void)changeColumnPosition
{
    [self.hero removeActionForKey:ACTION_WALK];
    self.getScore.position = CGPointMake(self.hero.position.x + 5, self.hero.position.y + 10);
    [self addChild:self.getScore];
    [self enumerateChildNodesWithName:NAME_COLUMN usingBlock:^(SKNode *node, BOOL *stop){
        if(((SKSpriteNode *)node).position.x <= POSITION_COLUMN)
            [node runAction: [SKAction sequence:@[[SKAction moveToX:-((SKSpriteNode *)node).size.width duration:0.3]]]];
        else if(((SKSpriteNode *)node).position.x < 0)
            [node removeFromParent];
        else
            [node runAction:[SKAction moveToX:POSITION_COLUMN duration:0.5]];
    }];
    
    [self enumerateChildNodesWithName:NAME_STICK usingBlock:^(SKNode *node, BOOL *stop){
        [node runAction:[SKAction sequence:@[[SKAction moveToX:-self.columnHigh duration:0.3],[SKAction performSelector:@selector(removeStickNode)onTarget:self]]]];
    }];
    
    [self enumerateChildNodesWithName:NAME_HERO usingBlock:^(SKNode *node, BOOL *stop){
        float temp = self.columnWide2 / 2 >= (WIDE_HERO / 2 + 3) ? self.columnWide2 / 2 - (WIDE_HERO / 2 + 3) : 0;
        [node runAction:[SKAction sequence:@[[SKAction moveToX:POSITION_COLUMN + temp duration:0.5], [SKAction performSelector:@selector(changeBool) onTarget:self]]]];
    }];
    
    [self addColumnNode];
    self.scoreNum ++;
    self.score.text = [NSString stringWithFormat:@"%d", self.scoreNum];
    
}

-(void)changeBool
{
    [self.getScore removeFromParent];
    self.isLengthen = NO;
    self.isAllow = NO;
}


-(void)changeGravity
{
    self.hero.physicsBody.affectedByGravity = YES;
    [self enumerateChildNodesWithName:NAME_STICK usingBlock:^(SKNode *node, BOOL *stop){
        [node runAction:[SKAction rotateByAngle:-M_PI / 2 duration:0.4]];
    }];
}

-(void)removeStickNode
{
    [self enumerateChildNodesWithName:NAME_STICK usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)update:(CFTimeInterval)currentTime
{
    
}

-(void)gameOver
{
    [self.hero removeActionForKey:ACTION_WALK];
    tryAgain *gameView = [tryAgain initButton:self.size];
    gameView.delegate = self;
    gameView.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    gameView.zPosition = ZPOSITION_GAMEOVER;
    [gameView showInscene:self];
}

-(void)restartView:(tryAgain *)tryAgain
{
    [self removeAllChildren];
    [self start];
}

@end
