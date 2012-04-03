//
//  G4Watcher.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Watcher.h"
#import "G4CardSize.h"
#import "G4CardImage.h"

@implementation G4Watcher

@synthesize delegate;

-(id)init:(CALayer*)superLayer
{
    if(self = [super init])
    {
        _layer = [[CALayer layer] retain];
        
        CGRect frame;
        frame.origin = CGPointMake(0, 0);
        frame.size = CGSizeMake([G4CardSize watcherSize], [G4CardSize watcherSize]);
        [_layer setBackgroundColor:[UIColor clearColor].CGColor];
        [_layer setBorderColor:[UIColor clearColor].CGColor];
        [_layer setBorderWidth:[G4CardSize lineWidth]];
        [_layer setFrame:frame];
        _layer.delegate = self;
        _superLayer = [superLayer retain];
    }
    return self;
}

-(void)show:(float)interval atPoint:(CGPoint)point;
{
    if(_layer.superlayer != nil)
        [self hide];
    CGRect frame = _layer.frame;
    frame.origin = point;
    _layer.frame = frame;
    
    _interval = interval;
    _currentTimes = 0;
    [self calcParameters];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:_intervalPerTime target:self selector:@selector(timeOut) userInfo:nil repeats:YES] retain];
    [_superLayer addSublayer:_layer];
}

-(void)hide
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [_layer removeFromSuperlayer];
}

-(void)dealloc
{
    [_timer invalidate];
    [_timer release];
    [_layer release];
    [_superLayer release];
}

-(void)timeOut
{
    if(_currentTimes >= _times)
    {
        [self hide];
        [delegate timeReached];
        return;
    }
    _currentTimes ++;
    [_layer setNeedsDisplay];
}

#define MAX_TIMES       180

#define MIN_INTERVAL    0.1

-(void)calcParameters
{
    _times = _interval / MIN_INTERVAL;
    if(_times > MAX_TIMES)
        _times = MAX_TIMES;
    _intervalPerTime = _interval / _times;
    _angle = (2 * M_PI) / _times;
}

-(void)draw
{
    UIImage* image = [G4CardImage watcherImage];
    float width = image.size.width;
    float scaled = _layer.frame.size.width / width;
    
    float height = image.size.height * scaled;
    
    CGRect imageRect = CGRectMake(0, 0, _layer.frame.size.width, height);
    
    [[G4CardImage watcherImage] drawInRect:imageRect]; 
    
    float x = _layer.frame.size.width / 2;
    
    float edge = 15.0f * scaled;
    
    UIBezierPath* path3 = [UIBezierPath bezierPath];
    [path3 moveToPoint:CGPointMake(x, x)];
    [path3 addLineToPoint:CGPointMake(x, edge)];
    [path3 addArcWithCenter:CGPointMake(x, x) radius:_layer.frame.size.width / 2 - edge startAngle:-M_PI_2 endAngle:-M_PI_2 + _angle * _currentTimes clockwise:YES];
    [path3 closePath];
    [[UIColor redColor] set];
    [path3 fill];
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self draw];
    UIGraphicsPopContext();
}

@end
