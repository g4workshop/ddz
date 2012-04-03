//
//  G4ResultLayer.h
//  DDZ
//
//  Created by gyf on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "G4GamePlayer.h"

//#define ANIMATION_SCALE

@protocol G4ResultDelegate <NSObject>

-(void)resultHided;
//-(void)resultShowed;

@end

@interface G4ResultLayer : NSObject
{
@private
    CALayer* _superLayer;
    CABasicAnimation* _animationShow;
    CALayer* _resultLayer;
    NSTimer* _timer;
    char _timerCount;
    char _animationState; 
    G4GameManager* _gameManager;
    BOOL _showAnimation;
}

@property(nonatomic,assign)NSObject<G4ResultDelegate>* deleate;
@property(nonatomic)BOOL showTimer;
@property(nonatomic)BOOL callBackWhenHided;

-(id)initWithSuperLayer:(CALayer*)superLayer : (G4GameManager*)gameManager;
-(void)dealloc;

-(void)show:(BOOL)animation:(float)interval;
-(void)hide:(BOOL)animation;

-(void)drawCell;
-(void)drawRounds:(UIFont*)font;
-(void)drawSeconds:(UIFont*)font;

-(void)drawHeader:(UIFont*)font;
-(void)drawScores:(UIFont*)font;
-(void)drawPlayerScore:(G4GamePlayer*)player:(UIFont*)font;

-(void)drawInNameRect:(NSString*)string:(char)index:(UIFont*)font;
-(void)drawInRoundScoreRect:(NSString*)string:(char)index:(UIFont*)font;
-(void)drawInTotalScoreRect:(NSString*)string:(char)index:(UIFont*)font;

-(void)drawFromX:(float)x andWidth:(float)width:(NSString*)string:(char)index:(UIFont*)font;


-(void)timerFunc;

@end
