//
//  G4AdLayer.m
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4AdLayer.h"
#import "G4CardSize.h"

@implementation G4AdLayer

-(id)init:(CALayer*)superLayer
{
    if(self = [super init])
    {
        _layer = [[CALayer layer] retain];
        [_layer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor];       
        
        _superLayer = [superLayer retain];
        //[superLayer addSublayer:_layer];

        CGSize viewSize = [G4CardSize deviceViewSize];
        CGRect rect = CGRectMake(0, viewSize.height - [G4CardSize adViewHeight], viewSize.width, [G4CardSize adViewHeight]);   
        
        _layer.frame = rect;
        _layer.delegate = self;
        [_layer setNeedsDisplay];
    }
    return self;
}

-(void)dealloc
{
    [_layer release];
    [_superLayer release];
    [super dealloc];
}

-(void)showAd:(BOOL)show
{
    float from;
    float to;
    if(show)
    {
        if(_layer.superlayer == nil)
            [_superLayer addSublayer:_layer];
        from = [G4CardSize adViewHeight];
        to = 0;
    }
    else
    {
        [_layer removeFromSuperlayer];
        to = [G4CardSize adViewHeight];
        from = 0;
    }
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    _animation.fromValue = [NSNumber numberWithFloat:from];
    _animation.toValue = [NSNumber numberWithFloat:to];
    _animation.duration = 1.0f;
    _animation.fillMode=kCAFillModeForwards;
    _animation.removedOnCompletion=NO;
    _animation.delegate = self;
    [_layer addAnimation:_animation forKey:nil];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    float x = 100;
    float y = 20;
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize waitingViewFontSize]];
    [[UIColor whiteColor] set];
    [@"我     是     广      告" drawAtPoint:CGPointMake(x, y) withFont:font];
    UIGraphicsPopContext();
}
@end
