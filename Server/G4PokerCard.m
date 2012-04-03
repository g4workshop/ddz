//
//  G4PokerCard.m
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
@synthesize selected;

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
        selected = NO;
        return self;
    }
    return nil;
}

-(void)addToSuperLayer:(CALayer*)superLayer
{
    _superLayer = [superLayer retain];
    [_cardLayer removeFromSuperlayer];
    [superLayer addSublayer:_cardLayer];
    [_cardLayer setNeedsDisplay];
}

-(float)getX
{
    return _cardLayer.frame.origin.x;
}

-(void)dealloc
{
    NSLog(@"card %d dealloc\n", cardNumber);
    [_superLayer release];
    [_cardLayer removeFromSuperlayer];
    [_cardLayer release];
    [super dealloc];
}

-(void)draw
{
    CGPoint offset = CGPointMake(0, 0);
//    CGRect rect = CGRectMake(0, 0, [G4CardSize cardWidth], [G4CardSize cardHeight]);
//    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:[G4CardSize cardCorner]];
//    [path setLineWidth:[G4CardSize cardBorderWidth]];
//    [[UIColor blackColor] set];
//    [path stroke];
//    [[UIColor whiteColor] set];
//    [path fill];
    [G4CardImage drawTypeImage:offset:cardNumber :cardShowWidth :[G4CardImage drawCardDigit:offset:cardNumber :cardShowWidth]];
    [G4CardImage drawCenterImage:offset:cardNumber :cardShowWidth:0];
}

-(void)switchSelect
{
    CGRect rect = _cardLayer.frame;
    if(selected)
        rect.origin.y += [G4CardSize cardSelectedUp];
    else
        rect.origin.y -= [G4CardSize cardSelectedUp];
    _cardLayer.frame = rect;
    selected = !selected;
}

-(void)selectCard:(BOOL)select
{
    if(self.selected != select)
        [self switchSelect];
}

-(BOOL)isInRangeFromX:(float)fromX toX:(float)toX
{
    return (_cardLayer.frame.origin.x > fromX && _cardLayer.frame.origin.x < toX);
}

-(BOOL)containtsPoint:(CGPoint)point
{
    return CGRectContainsPoint(_cardLayer.frame, point);
}

-(BOOL)containtsX:(float)x
{
    return (x >= _cardLayer.frame.origin.x && x <= _cardLayer.frame.origin.x + self.cardShowWidth);
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
    //rect.size.width = cardShowWidth + [G4CardSize cardCorner];
    [_cardLayer setFrame:rect];
    [_cardLayer setNeedsDisplay];
}

-(void)layout:(float)x:(float)y:(float)width
{
    CGRect rect = _cardLayer.frame;
    cardShowWidth = width;
    rect.origin.x = x;
    rect.origin.y = y;
    [_cardLayer setFrame:rect];
    [_cardLayer setNeedsDisplay];
}

-(void)setCardWidth:(float)width
{
//    CGRect rect = _cardLayer.frame;
//    rect.size.width = width + [G4CardSize cardCorner];
//    [_cardLayer setFrame:rect];
//    [_cardLayer setNeedsDisplay];
    cardShowWidth = width;
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

-(void)showCard:(BOOL)show
{
    if(show)
    {
        if(_cardLayer.superlayer == nil)
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
