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

-(id)init;
-(void)dealloc;

-(void)draw;
-(void)redraw;
-(char)cardDigit;
-(char)cardType;
-(void)addToSuperLayer:(CALayer*)superLayer:(BOOL)atFirst;
-(void)layoutX:(float)x:(float)width;
-(void)layout:(float)x:(float)y;
-(void)startAnimation:(CAAnimation*)animation;
-(void)stopAnimation;
-(void)showCard:(BOOL)show:(CALayer*)above;
@end
