//
//  G4CardGroup.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4PokerCard.h"


@interface G4CardGroup : NSObject
{
@private
    NSMutableArray* _cardArray;
    CALayer* _groupLayer;
    CALayer* _superLayer;
    CABasicAnimation* _animation;
    char _animationState;
    float _cardShowWidth;
    CGRect _frame;
}

@property(nonatomic)char playerId;
@property(nonatomic)char maxCardCount;

-(id)initWithSuperLayer:(CALayer*)superLayer andFrame:(CGRect)frame;
-(void)dealloc;
-(void)showGroup:(BOOL)show;
-(float)addPokerCard:(char)cardNumber;
-(void)addPokerCard:(NSMutableArray*)cardArray:(G4PokerCard *)card;
-(void)rmvPokerCard:(char)cardNumber;
-(void)resortCards;
-(BOOL)isReachMaxCardCount;
-(float)layoutCards;
-(void)relayout;
-(void)animationFrom:(float)from:(float)to:(float)duration;
-(void)setMaxCardCount:(char)max;
-(void)cardSwitchSelect:(CGPoint)point;
-(char)getSelectedCard:(char*)cardNumbers;
-(void)unSelectAllCard;
-(float)getGroupCenterX;
-(float)getFirstSelectX;
@end


