//
//  G4FloatInfoLayer.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4FloatInfoLayer.h"
#import "G4CardSize.h"

@implementation G4FloatInfoLayer

-(id)init:(CALayer*)superLayer:(CGRect)frame
{
    if(self = [super init])
    {
        _infoLayer = [[CALayer layer] retain];
        
        [_infoLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [_infoLayer setBorderColor:[UIColor clearColor].CGColor];
        [_infoLayer setFrame:frame];
        _infoLayer.delegate = self;
        
        _superLayer = [superLayer retain];
    }
    return self;
}

-(void)dealloc
{
    [_infoLayer release];
    [_superLayer release];
    [_showInfo release];
    [_showTimer invalidate];
    [_showTimer release];
}

-(void)showInfo:(NSString*)info:(float)maxTime
{
    _showInfo = [info retain];
    if(maxTime > 0.0f)
        _showTimer = [NSTimer scheduledTimerWithTimeInterval:maxTime target:self selector:@selector(timed) userInfo:nil repeats:NO];
    [_infoLayer setNeedsDisplay];
    
    [_superLayer addSublayer:_infoLayer];
}

-(void)hideInfo
{
    [_showTimer invalidate];
    [_showTimer release];
    _showTimer = nil;
    [_infoLayer removeFromSuperlayer];
    [_showInfo release];
    _showInfo = nil;
}

-(void)timed
{
    [self hideInfo];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self draw];
    UIGraphicsPopContext();
}

-(void)draw
{
    CGRect frame = _infoLayer.frame;
    frame.origin = CGPointMake(0, 0);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:frame];
    
    [[[UIColor blackColor] colorWithAlphaComponent:0.5] set];
    
    [path fill];
    
    [[UIColor whiteColor] set];
    [path stroke];
    
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize floatInfoFontSize]];

    CGSize fontSize = [_showInfo sizeWithFont:font];
 
    float x = (_infoLayer.frame.size.width - fontSize.width) / 2;
    float y = (_infoLayer.frame.size.height - fontSize.height) / 2;
    
    [_showInfo drawAtPoint:CGPointMake(x, y) withFont:font];
    
}

@end
