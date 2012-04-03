//
//  G4ResultLayer.m
//  DDZ
//
//  Created by gyf on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4ResultLayer.h"
#import "G4CardSize.h"

@implementation G4ResultLayer

@synthesize deleate;
@synthesize showTimer;
@synthesize callBackWhenHided;

-(id)initWithSuperLayer:(CALayer*)superLayer : (G4GameManager*) gameManager
{
    if(!(self = [super init]))
        return nil;
    float width = [G4CardSize resultNameWidth] + [G4CardSize resultRoundScoreWidth] + [G4CardSize resultTotalScoreWidth];
    float height = [G4CardSize resultCellHeight] * 6;
    
    float x = ([G4CardSize deviceViewSize].width - width) / 2;
    float y = ([G4CardSize deviceViewSize].height - height) / 2;
    if(y + height < [G4CardSize cmdPannelRect].origin.y)
        y = [G4CardSize cmdPannelRect].origin.y - height - 2;
    if(y < 1.0f)
        y = 1.0f;
    
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    _resultLayer = [[CALayer layer] retain];
    UIColor* color = [UIColor whiteColor];
    //color = [color colorWithAlphaComponent:0.9];
    [_resultLayer setBackgroundColor:color.CGColor];
    [_resultLayer setBorderColor:[UIColor blackColor].CGColor];
    [_resultLayer setBorderWidth:[G4CardSize lineWidth]];
    [_resultLayer setCornerRadius:[G4CardSize cardCorner]];
    
    
    
    _resultLayer.shadowOffset = CGSizeMake(0, 2);
    _resultLayer.shadowRadius = 5;
    _resultLayer.shadowColor = [UIColor blackColor].CGColor;
    _resultLayer.shadowOpacity = 0.4;
    
    _resultLayer.delegate = self;

    _superLayer = [superLayer retain];
    
    [_resultLayer setFrame:frame];
    _gameManager = [gameManager retain];
#ifdef ANIMATION_SCALE
    _animationShow = [[CABasicAnimation animationWithKeyPath:@"transform.scale"] retain];
    _animationShow.delegate = self;
#else    
    _animationShow = [[CABasicAnimation animationWithKeyPath:@"transform.translation.y"] retain];       
    _animationShow.delegate = self;
#endif
    _animationShow.fillMode=kCAFillModeForwards;
    _animationShow.removedOnCompletion=NO;
    _animationShow.duration = 0.4f;
    _animationShow.delegate = self;
    _animationState = 0;
    
    self.callBackWhenHided = YES;
    self.showTimer = YES;
    return self;
}

-(void)dealloc
{
    [_resultLayer removeFromSuperlayer];
    [_superLayer release];
    [_resultLayer release];
    [_gameManager release];
    [_animationShow release];
    if([_timer isValid])
        [_timer invalidate];
    [_timer release];
}

-(void)show:(BOOL)animation:(float)interval
{
    _showAnimation = animation;
    [_resultLayer setNeedsDisplay];
    [_superLayer addSublayer:_resultLayer];
    if(animation && _animationState == 0)
    {
#ifndef ANIMATION_SCALE
        float from = -_resultLayer.frame.size.height - _resultLayer.frame.origin.y;
        _animationShow.fromValue = [NSNumber numberWithFloat:from];
        _animationShow.toValue = [NSNumber numberWithFloat:0];
#else
        _animationShow.fromValue = [NSNumber numberWithFloat:0.1];
        _animationShow.toValue = [NSNumber numberWithFloat:1.0];
#endif
        [_resultLayer addAnimation:_animationShow forKey:nil];
        _animationState = 1;
    }
    if(interval > 0.5)
    {
        _timerCount = (int)(interval + 0.5);
        if(_timer && [_timer isValid])
        {
            [_timer invalidate];
            [_timer release];
        }
        _timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFunc) userInfo:nil repeats:YES] retain];
    }
}

-(void)hide:(BOOL)animation
{
    if(animation && _animationState == 0)
    {
#ifndef ANIMATION_SCALE
        float to = -_resultLayer.frame.size.height - _resultLayer.frame.origin.y;
        _animationShow.fromValue = [NSNumber numberWithFloat:0];
        _animationShow.toValue = [NSNumber numberWithFloat:to];
#else
        _animationShow.fromValue = [NSNumber numberWithFloat:1.0];
        _animationShow.toValue = [NSNumber numberWithFloat:0.1];
#endif
        [_resultLayer addAnimation:_animationShow forKey:nil];
        _animationState = 2;
    }
    else
        [_resultLayer removeFromSuperlayer];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self drawCell];
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize resultFontSize]];
    [self drawRounds:font];
    [self drawSeconds:font];
    [self drawHeader:font];
    [self drawScores:font];
    UIGraphicsPopContext();
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_resultLayer removeAllAnimations];
    if(_animationState == 2)
    {
        [_resultLayer removeFromSuperlayer];
        [deleate resultHided];
    }
    _animationState = 0;
}

-(void)drawRounds:(UIFont*)font
{
    NSString* roundString = [NSString stringWithFormat:@"第%d局", _gameManager._roundCount];
    CGSize size = [roundString sizeWithFont:font];
    float x = ([G4CardSize resultNameWidth] + [G4CardSize resultRoundScoreWidth] - size.width) / 2;
    float y = ([G4CardSize resultCellHeight] - size.height) / 2;
    
    [roundString drawAtPoint:CGPointMake(x, y) withFont:font];
}

-(void)drawSeconds:(UIFont*)font
{
    NSString* secondString = [NSString stringWithFormat:@"%d", _timerCount];
    CGSize size = [secondString sizeWithFont:font];
    float x = ([G4CardSize resultTotalScoreWidth] - size.width) / 2 + [G4CardSize resultNameWidth] + [G4CardSize resultRoundScoreWidth];
    float y = ([G4CardSize resultCellHeight] - size.height) / 2;
    
    if(_timerCount <= 5)
        [[UIColor redColor] set];
    else
        [[UIColor blackColor] set];
    [secondString drawAtPoint:CGPointMake(x, y) withFont:font];   
}

-(void)drawHeader:(UIFont*)font
{
    [self drawInNameRect:@"玩家" :0 :font];
    [self drawInRoundScoreRect:@"本局" :0 :font];
    [self drawInTotalScoreRect:@"一共" :0 :font];
}

-(void)drawScores:(UIFont*)font
{
    for(char i = 0; i < [_gameManager countOfPlayer]; i++)
    {
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        [self drawPlayerScore:player :font];
    }
}

-(void)drawPlayerScore:(G4GamePlayer*)player:(UIFont*)font
{
    [self drawInNameRect:[player getPlayerName] :player._playerId + 1:font];
    NSString* tmp = [NSString stringWithFormat:@"%d", player._roundScore];
    [self drawInRoundScoreRect:tmp :player._playerId + 1 :font];
    tmp = [NSString stringWithFormat:@"%d", player._totalScore];
    [self drawInTotalScoreRect:tmp :player._playerId + 1 :font];
}

-(void)drawInNameRect:(NSString*)string:(char)index:(UIFont*)font
{
    [self drawFromX:0 andWidth:[G4CardSize resultNameWidth] :string :index :font];
}

-(void)drawInRoundScoreRect:(NSString*)string:(char)index:(UIFont*)font
{
    [self drawFromX:[G4CardSize resultNameWidth] andWidth:[G4CardSize resultRoundScoreWidth] :string :index :font];
}

-(void)drawInTotalScoreRect:(NSString*)string:(char)index:(UIFont*)font
{
    [self drawFromX:[G4CardSize resultNameWidth] + [G4CardSize resultRoundScoreWidth] andWidth:[G4CardSize resultTotalScoreWidth] :string :index :font];
}

-(void)drawFromX:(float)x andWidth:(float)width:(NSString*)string:(char)index:(UIFont*)font
{
    CGSize size = [string sizeWithFont:font];
    x += (width - size.width) / 2;
    float y = (index + 1) * [G4CardSize resultCellHeight] + ([G4CardSize resultCellHeight] - size.height) / 2;
    [string drawAtPoint:CGPointMake(x, y) withFont:font];
}

-(void)drawCell
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    float x = 0;
    float y = 0;
    for(int i = 0; i < 5; i++)
    {
        y += [G4CardSize resultCellHeight];
        [path moveToPoint:CGPointMake(x, y)];
        [path addLineToPoint:CGPointMake(_resultLayer.frame.size.width, y)];
    }
    float y1 = [G4CardSize resultCellHeight];
    float y2 = _resultLayer.frame.size.height;
    
    float x1[] = {[G4CardSize resultNameWidth], [G4CardSize resultRoundScoreWidth]};
    x = 0;
    for(int i = 0; i < 2; i++)
    {
        x += x1[i];
        [path moveToPoint:CGPointMake(x, y1)];
        [path addLineToPoint:CGPointMake(x, y2)];
    }
    
    [path setLineWidth:[G4CardSize lineWidth]];
    [[UIColor blackColor] set];
    [path stroke];
}

-(void)timerFunc
{
    _timerCount --;
    if(_timerCount <= 0)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        [self hide:_showAnimation];
        return;
    }
    float x = [G4CardSize resultNameWidth] + [G4CardSize resultRoundScoreWidth];
    [_resultLayer setNeedsDisplayInRect:CGRectMake(x, 0, [G4CardSize resultTotalScoreWidth], [G4CardSize resultCellHeight])];
}

@end
