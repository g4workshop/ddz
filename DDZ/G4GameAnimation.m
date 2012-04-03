//
//  G4GameAnimation.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GameAnimation.h"
#import "G4CardGroup.h"
#import "G4CardSize.h"
#import "G4GameFSM.h"

@implementation G4ViewController(G4GameAnimation)

-(void)beginDealCard
{
    [G4CardSize setMaxAnimationDuration:0.2f];
    [_selfInfo._cardGroup show:0 :YES];
//    [_selfInfo._cardGroup showGroup:YES];
//    [_selfInfo._cardGroup setMaxCardCount:[_gamePlayer[_selfInfo._playerId] countOfCard]];
//    _dealingInfo._currentDealIndex = 0;
//    _dealingInfo._dealCardAnimation.duration = 0.1f;
//    [self dealACard:0];
}

-(void)beginDealDZCard
{
 /*   [_selfInfo._cardGroup setMaxCardCount:[_gamePlayer[_selfInfo._playerId] countOfCard]];
    float x = [_selfInfo._cardGroup layoutCards];
    _dealingInfo._currentDealIndex = 25;
    _dealingInfo._dealCardAnimation.duration = 0.1f;
    [self dealACard:x];*/
}

-(void)dealACard:(float)x
{
 /*   [_dealingInfo._dealingCard stopAnimation];
    [_dealingInfo._dealingCard release];
    _dealingInfo._dealingCard = nil;
    if([_selfInfo._cardGroup isReachMaxCardCount])
    {
        [_selfInfo._cardGroup resortCards];
        if(_gameState == GAME_DEALING_CARD)
            [self setGameState:GAME_WAITING_QDZ];
        else
            [self setGameState:GAME_OUTING_CARD];
        return;
    }
    
    CGMutablePathRef animationPath = CGPathCreateMutable();
    
    float from_x = [G4CardSize deviceViewSize].width / 2;
    float from_y = [G4CardSize deviceViewSize].height / 2;
    
    CGPathMoveToPoint(animationPath, NULL, from_x, from_y);
    
    float to_x = x + [G4CardSize cardWidth] / 2;
    float to_y = [G4CardSize deviceViewSize].height - [G4CardSize edgeSpace] - [G4CardSize cardHeight] / 2;
    
    CGPathAddLineToPoint(animationPath, NULL, to_x, to_y);
    
    _dealingInfo._dealCardAnimation.path = animationPath;
    
    CGPathRelease(animationPath);
    
    _dealingInfo._dealingCard = [[G4PokerCard alloc] init];
    [_dealingInfo._dealingCard layout:([G4CardSize deviceViewSize].width - [G4CardSize cardWidth]) / 2
 :([G4CardSize deviceViewSize].height - [G4CardSize cardHeight]) / 2];
    [_dealingInfo._dealingCard addToSuperLayer:self.view.layer :NO];
    
    _dealingInfo._dealingCard.cardNumber = [_gamePlayer[_selfInfo._playerId] getCard:_dealingInfo._currentDealIndex++];
    
    [_dealingInfo._dealingCard startAnimation:_dealingInfo._dealCardAnimation];*/
}

-(void)initCardGroup
{
    float x = [G4CardSize edgeSpace];
    float y = [G4CardSize deviceViewSize].height - [G4CardSize edgeSpace] - [G4CardSize cardHeight];
    CGRect groupFrame = CGRectMake(x, y, [G4CardSize deviceViewSize].width - 2 * [G4CardSize edgeSpace], [G4CardSize cardHeight]);
    _selfInfo._cardGroup = [[G4CardGroup alloc] initWithSuperLayer:self.view.layer andFrame:groupFrame];
    _selfInfo._cardGroup.delegate = self;
    //[_selfInfo._cardGroup showGroup:YES];
}

-(void)initAnimation
{
    _dealingInfo._dealCardAnimation = [[CAKeyframeAnimation animationWithKeyPath:@"position"] retain];
    [_dealingInfo._dealCardAnimation setDelegate:self];
    [_dealingInfo._dealCardAnimation setDuration:0.2f];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    float x = [_selfInfo._cardGroup addPokerCard:_dealingInfo._dealingCard.cardNumber];
    [self dealACard:x];
}

@end
