//
//  G4OutedCardGroup.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface G4OutedCardGroup : NSObject
{
@private
    CALayer* _groupLayer;
    CALayer* _superLayer;
    NSMutableArray* _cardArray;
    CABasicAnimation* _animation;
}

@property(nonatomic)char groupDirection;
@property(nonatomic)float cardCenterX;

-(id)initWith:(CALayer*)superLayer:(char)direction:(CGRect)frame;
-(void)dealloc;

-(void)addCard:(char)cardNumber;
-(void)showGroup:(BOOL)show;
-(void)removeAllCards;
-(void)drawAllCards;
+(void)drawCard:(float)x:(char)cardNumber:(float)cardShowWidth;

-(CGRect)calcGroupFrame:(CGRect)frame;

-(void)animation;
-(void)animation:(CGPoint)from;

@end
