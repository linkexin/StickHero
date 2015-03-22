//
//  tryAgain.h
//  StickHero
//
//  Created by apple on 14-11-27.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class tryAgain;

@protocol tryAgainDelegate <NSObject>
-(void)restartView:(tryAgain *)tryAgain;
@end


@interface tryAgain : SKSpriteNode

@property (weak, nonatomic)id <tryAgainDelegate> delegate;
+(instancetype)initButton:(CGSize)size;
-(void)showInscene:(SKScene *)scene;

@end
