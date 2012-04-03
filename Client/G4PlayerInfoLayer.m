//
//  G4PlayerInfoLayer.m
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4PlayerInfoLayer.h"
#import "G4CardSize.h"
#import "G4CardImage.h"

@implementation G4PlayerInfoLayer

-(id)init:(CALayer*)superLayer:(CGPoint)point
{
    if(self = [super init])
    {
        _layer = [[CALayer layer] retain];
        
        CGRect frame;
        frame.origin = point;
        frame.size = CGSizeMake([G4CardSize playerInfoBoardSize], [G4CardSize playerInfoBoardSize]);
        [_layer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor];
        [_layer setBorderColor:[UIColor whiteColor].CGColor];
        [_layer setBorderWidth:[G4CardSize lineWidth]];
        [_layer setFrame:frame];
        _layer.delegate = self;
        _layer.shadowOffset = CGSizeMake(0, 2);
        _layer.shadowRadius = 5;
        _layer.shadowColor = [UIColor blackColor].CGColor;
        _layer.shadowOpacity = 0.6; 
        _superLayer = [superLayer retain];
    }
    return self;
}

-(void)show:(BOOL)show
{
    if(show)
    {
        if(_layer.superlayer == nil)
            [_superLayer addSublayer:_layer];
    }
    else
        [_layer removeFromSuperlayer];
}

-(void)drawCardCount
{
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize playerBoardFontSize]];
    float x = [G4CardSize playerImageSize] + [G4CardSize edgeSpace];
    NSString* cardCountString = [NSString stringWithFormat:@"%d", _cardCount];
    CGSize fontSize = [cardCountString sizeWithFont:font];
    float y = ([G4CardSize playerImageSize] - fontSize.height) / 2;
    [cardCountString drawAtPoint:CGPointMake(x, y) withFont:font];
}

-(void)drawPlayerImage
{
    CGRect rect = CGRectMake(0, 0, [G4CardSize playerImageSize], [G4CardSize playerImageSize]);
    
    [[G4CardImage playerImage:1] drawInRect:rect];
}

-(void)drawPlayerName
{
    float y = [G4CardSize playerImageSize] + [G4CardSize edgeSpace];
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize playerBoardFontSize]];
    NSString* nameString = [NSString stringWithFormat:@"%@[%d]", _playerName, _playerId];
    CGSize fontSize = [nameString sizeWithFont:font];
    float x = ([G4CardSize playerInfoBoardSize] - fontSize.width) / 2;
    [nameString drawAtPoint:CGPointMake(x, y) withFont:font];
}

-(void)setCardCount:(char)cardCount
{
    _cardCount = cardCount;
    CGRect rect = CGRectMake([G4CardSize playerImageSize], 0, [G4CardSize playerInfoBoardSize] - [G4CardSize playerImageSize], [G4CardSize playerImageSize]);
    [_layer setNeedsDisplayInRect:rect];
}

-(void)setPlayerName:(NSString *)playerName:(char)playerId
{
    _playerName = [playerName retain];
    _playerId = playerId;
    [_layer setNeedsDisplay];
}

-(void)dealloc
{
    [_superLayer release];
    [_layer release];
    [_playerName release];
    [super dealloc];
}

-(void)draw
{
    [self drawPlayerImage];
    [[UIColor blackColor] set];
    [self drawPlayerName];
    [self drawCardCount];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self draw];
    UIGraphicsPopContext();
}
@end
