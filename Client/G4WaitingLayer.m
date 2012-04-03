//
//  G4WaitingLayer.m
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4WaitingLayer.h"
#import "G4CardSize.h"
#import "G4CardImage.h"

@implementation G4WaitingLayer


-(id)init:(CALayer*)superLayer:(CGRect)frame:(G4GameManager*)gameManager;
{
    if(self = [super init])
    {
        _layer = [[CALayer layer] retain];
        [_layer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor];
        [_layer setBorderColor:[UIColor whiteColor].CGColor];
        [_layer setBorderWidth:[G4CardSize lineWidth]];
        [_layer setCornerRadius:[G4CardSize cardCorner]];
        

        _layer.shadowOffset = CGSizeMake(0, 2);
        _layer.shadowRadius = 5;
        _layer.shadowColor = [UIColor blackColor].CGColor;
        _layer.shadowOpacity = 0.4;
        
        _layer.delegate = self;
        [superLayer addSublayer:_layer];
        
        UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize waitingViewFontSize]];
        _fontHeight = [@"我" sizeWithFont:font].height;
        [self setFrame:frame];
        _gameManager = [gameManager retain];
        [_layer setNeedsDisplay];
                
    }
    return self;
}

-(void)dealloc
{
    [_layer removeFromSuperlayer];
    [_layer release];
    [_gameManager release];
    [super dealloc];
}

-(void)drawName
{
    
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize waitingViewFontSize]];
    [[UIColor whiteColor] set];
    
    int drawCount = 0;
    for(char i = 0; i < [_gameManager countOfPlayer]; i++)
    {
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        if(player._isSelf)
            continue;
        NSString* name = [NSString stringWithFormat:@"%@[%d]", [player getPlayerName], player._randomId];
        float y = [G4CardSize waitingViewPlayerNameY] + drawCount * [G4CardSize waitingViewPlayerNameHeight];

        float x = [G4CardSize waitingViewInfoEdge] + [G4CardSize waitingViewInfoX];
        float y1 = y;
        y1 += ([G4CardSize waitingViewPlayerNameHeight] - _fontHeight) / 2;
        [name drawAtPoint:CGPointMake(x, y1) withFont:font];
        
        [self drawPlayerImage:drawCount :player];
        drawCount++;
    }    
    if([_gameManager isServer])
    {
        for(; drawCount < 3; drawCount++)
            [self drawPlayerImage:drawCount :nil];
    }
}

-(void)redraw
{
    [_layer setNeedsDisplay];
}

-(void)drawPlayerImage:(int)index :(G4GamePlayer *)player
{
    UIImage* image;
    if(player == nil || player._computerPlayer)
        image = [G4CardImage computerImage];
    else
        image = [G4CardImage playerImage:index];
    
    float imageHeight = [G4CardSize waitingViewImageHeight];    
    float scaled = imageHeight / image.size.height;
    
    float imageWidth = image.size.width * scaled;
    
    float y = [G4CardSize waitingViewPlayerNameY] + index * [G4CardSize waitingViewPlayerNameHeight];
    
    y += ([G4CardSize waitingViewPlayerNameHeight] - imageHeight) / 2;

    float imageX = _layer.frame.size.width - [G4CardSize waitingViewInfoX] - [G4CardSize waitingViewInfoEdge] - imageWidth;
    
    [image drawInRect:CGRectMake(imageX, y, imageWidth, imageHeight)];
}

-(void)draw
{
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize waitingViewFontSize]];
    [[UIColor whiteColor] set];
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._selfId];

    NSString* topString = [NSString stringWithFormat:@"%@[%d]您好...", [player getPlayerName], player._randomId];
    CGSize size = [topString sizeWithFont:font];
    float x = (_layer.frame.size.width - size.width) / 2;
    [topString drawAtPoint:CGPointMake(x, [G4CardSize waitingViewInfoEdge]) withFont:font];

    x = [G4CardSize waitingViewInfoX];
    
    float y = [G4CardSize waitingViewPlayerNameY];
    float width = _layer.frame.size.width - x * 2;
    float height = [G4CardSize waitingViewPlayerNameHeight] * 3;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, width, height) cornerRadius:10];

    [path setLineWidth:[G4CardSize lineWidth]];
    
    y += [G4CardSize waitingViewPlayerNameHeight];
    
   
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(x + width, y)];
    
    y += [G4CardSize waitingViewPlayerNameHeight];

    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(x + width, y)];
    [path stroke];
    
    [self drawName];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self draw];
    UIGraphicsPopContext();
}

-(void)setFrame:(CGRect)viewFrame
{
    
    float y = (viewFrame.size.height - [G4CardSize waitingViewHeight]) / 3;
    
    float x = (viewFrame.size.width  - [G4CardSize waitingViewWidth]) / 2;
    
    _layer.frame = CGRectMake(x, y, [G4CardSize waitingViewWidth], [G4CardSize waitingViewHeight]);
}

-(BOOL)hitTest:(CGPoint)pt
{
    CGPoint selfPt = [_layer convertPoint:pt fromLayer:_layer.superlayer];
    
    int count = [_gameManager countOfPlayer] - 1;
    UIImage* image = [G4CardImage computerImage];
    float imageHeight = [G4CardSize waitingViewImageHeight];    
    float scaled = imageHeight / image.size.height;
    
    float imageWidth = image.size.width * scaled;
        
    for(int i = count; i < 3; i++)
    {
        float y = [G4CardSize waitingViewPlayerNameY] + i * [G4CardSize waitingViewPlayerNameHeight];
        
        y += ([G4CardSize waitingViewPlayerNameHeight] - imageHeight) / 2;
        
        float imageX = _layer.frame.size.width - [G4CardSize waitingViewInfoX] - [G4CardSize waitingViewInfoEdge] - imageWidth;
        
        CGRect rect = CGRectMake(imageX, y, imageWidth, imageHeight);
        
        if(CGRectContainsPoint(rect, selfPt))
            return YES;
    }
    return NO;
}

@end
