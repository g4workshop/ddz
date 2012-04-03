//
//  G4CardLayer.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>



@interface G4PokerCard : NSObject
{
@private
    CALayer* _cardLayer;
    CALayer* _superLayer;
}

@property(nonatomic)char cardNumber;
@property(nonatomic)short cardShowWidth;
@property(nonatomic)BOOL selected;

-(id)init;
-(void)dealloc;

-(void)draw;
-(void)redraw;
-(char)cardDigit;
-(char)cardType;
-(void)addToSuperLayer:(CALayer*)superLayer;
-(void)layoutX:(float)x:(float)width;
-(void)setCardWidth:(float)width;
-(void)layout:(float)x:(float)y;
-(void)layout:(float)x:(float)y:(float)width;
-(void)startAnimation:(CAAnimation*)animation;
-(void)stopAnimation;
-(void)showCard:(BOOL)show;
-(void)switchSelect;
-(void)selectCard:(BOOL)select;
-(BOOL)containtsPoint:(CGPoint)point;
-(BOOL)containtsX:(float)x;
-(float)getX;

@end
