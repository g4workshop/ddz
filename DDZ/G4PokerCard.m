//
//  G4CardLayer.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4PokerCard.h"
#import "G4CardSize.h"
#import "G4CardImage.h"

@implementation G4PokerCard

@synthesize cardNumber;
@synthesize cardShowWidth;

-(id)init
{
    if(self = [super init])
    {   
        _cardLayer = [[CALayer layer] retain];
        [_cardLayer setBackgroundColor:[UIColor whiteColor].CGColor];
        [_cardLayer setBorderColor:[UIColor blackColor].CGColor];
        [_cardLayer setCornerRadius:[G4CardSize cardCorner]];
        [_cardLayer setBorderWidth:[G4CardSize cardBorderWidth]];
        [_cardLayer setDelegate:self];
        [_cardLayer setFrame:CGRectMake(0, 0, [G4CardSize cardWidth], [G4CardSize cardHeight])];        
        return self;
    }
    return nil;
}

-(void)addToSuperLayer:(CALayer*)superLayer:(BOOL)atFirst
{
    _superLayer = [superLayer retain];
    [_cardLayer removeFromSuperlayer];
    if(atFirst)
        [superLayer insertSublayer:_cardLayer atIndex:0];
    else
        [superLayer addSublayer:_cardLayer];
    [_cardLayer setNeedsDisplay];
}

-(void)dealloc
{
    [_superLayer release];
    [_cardLayer removeFromSuperlayer];
    [_cardLayer release];
    [super dealloc];
}

-(void)draw
{
    CGPoint offset = CGPointMake(0, 0);
    [G4CardImage drawTypeImage:offset:cardNumber :cardShowWidth :[G4CardImage drawCardDigit:offset:cardNumber :cardShowWidth]];
    [G4CardImage drawCenterImage:offset:cardNumber :cardShowWidth:0];
}

-(char)cardDigit
{
    return cardNumber / 4;
}
-(char)cardType
{
    return cardNumber % 4;
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self draw];
    UIGraphicsPopContext();
}

-(void)layoutX:(float)x:(float)width
{
    CGRect rect = _cardLayer.frame;
    cardShowWidth = width;
    rect.origin.x = x;
    [_cardLayer setFrame:rect];
}

-(void)layout:(float)x :(float)y
{
    CGRect rect = _cardLayer.frame;
    rect.origin.x = x;
    rect.origin.y = y;
    [_cardLayer setFrame:rect];
}

-(void)startAnimation:(CAAnimation*)animation
{
    [_cardLayer addAnimation:animation forKey:@"card move"];
}

-(void)stopAnimation
{
    [_cardLayer removeAllAnimations];
}

-(void)showCard:(BOOL)show:(CALayer*)above
{
    if(show)
    {
        if(_cardLayer.superlayer == nil)
            if(above != nil)
                [_superLayer insertSublayer:_cardLayer above:above];
            else
                [_superLayer addSublayer:_cardLayer];
    }
    else
        [_cardLayer removeFromSuperlayer];
}

-(void)redraw
{
    [_cardLayer setNeedsDisplay];
}
@end
