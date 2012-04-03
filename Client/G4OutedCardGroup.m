//
//  G4OutedCardGroup.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4OutedCardGroup.h"
#import "G4CardSize.h"
#import "G4CardImage.h"
#import "G4ViewController.h"


@implementation G4OutedCardGroup

@synthesize groupDirection;
@synthesize cardCenterX;

-(id)initWith:(CALayer*)superLayer:(char)direction:(CGRect)frame
{
    if(self = [super init])
    {
        _superLayer = [superLayer retain];
        _cardArray = [[NSMutableArray alloc] init];
        groupDirection = direction;
        _groupLayer = [[CALayer layer] retain];
        [_groupLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderWidth:0];
        
        [_groupLayer setFrame:[self calcGroupFrame:frame]];
//        _groupLayer.shadowOffset = CGSizeMake(0, 2);
//        _groupLayer.shadowRadius = 5;
//        _groupLayer.shadowColor = [UIColor blackColor].CGColor;
//        _groupLayer.shadowOpacity = 0.4;   
        _groupLayer.delegate = self;
        if(groupDirection == GROUP_DIRECTION_ME)
            _animation = [[CABasicAnimation animationWithKeyPath:@"transform.translation"] retain];
        else
            _animation = [[CABasicAnimation animationWithKeyPath:@"transform.scale"] retain];
        [_animation setDelegate:self];
        _animation.duration = 0.2f;
        return self;
    }
    return nil;
}

-(void)dealloc
{
    [_superLayer release];
    [_cardArray release];
    [_groupLayer release];
    [_animation release];
    [super dealloc];
}

-(CGRect)calcGroupFrame:(CGRect)frame
{
    if(groupDirection == GROUP_DIRECTION_LEFT || groupDirection == GROUP_DIRECTION_RIGHT)
        frame.size = [G4CardSize swapSizeWidthHeight:frame.size];
    return frame;
}

-(void)addCard:(char)cardNumber
{
    [_cardArray addObject:[NSNumber numberWithChar:cardNumber]];
}

-(void)showGroup:(BOOL)show
{
    if(show)
    {
        if(_groupLayer.superlayer == nil)
        {
            [_groupLayer setNeedsDisplay];
            [_superLayer addSublayer:_groupLayer];
            if(groupDirection == GROUP_DIRECTION_ME)
            {
                float tranlation_x = cardCenterX - (_groupLayer.frame.origin.x + _groupLayer.frame.size.width / 2);
                float tranlation_y = [G4CardSize deviceViewSize].height - [G4CardSize edgeSpace] - [G4CardSize cardHeight] / 2 - (_groupLayer.frame.origin.y + _groupLayer.frame.size.height / 2);
                NSLog(@"%@ Show OutedCardGroup,CardCenterX%.2f\n", self, cardCenterX);
                [self animation:CGPointMake(tranlation_x, tranlation_y)];  
            }
            else
            {
                NSLog(@"Show OutedCard,direction=%d\n", groupDirection);
                [self animation];
            }
        }
    }
    else
    {
        [_groupLayer removeFromSuperlayer];
        [self removeAllCards];
    }
}

-(void)drawAllCards
{
    int cardCount = [_cardArray count];
    float width = _groupLayer.frame.size.width;
    if(groupDirection == GROUP_DIRECTION_LEFT || groupDirection == GROUP_DIRECTION_RIGHT)
        width = _groupLayer.frame.size.height;
//    float needWidth = _cardShowWidth * (cardCount - 1) + [G4CardSize cardWidth];
    float cardShowWidth = [G4CardSize cardWidth];
    float needWidth = cardShowWidth;
    if(cardCount > 1)
    {
        cardShowWidth = (width - [G4CardSize cardWidth]) / (float)(cardCount - 1);
        if(cardShowWidth >= [G4CardSize cardMaxShowWidth])
            cardShowWidth = [G4CardSize cardMaxShowWidth];
        
        if(cardShowWidth < [G4CardSize cardMinShowWidth])
            cardShowWidth = [G4CardSize cardMinShowWidth];
        needWidth = cardShowWidth * (cardCount - 1) + [G4CardSize cardWidth];
    }
    
    CGSize size = CGSizeMake(needWidth, [G4CardSize cardHeight]);
    
    UIGraphicsBeginImageContext(size);
    
    NSNumber* number;
    float x = 0;

    for(int i = 0; i < cardCount - 1; i++)
    {
        number = (NSNumber*)[_cardArray objectAtIndex:i];
        [G4OutedCardGroup drawCard:x:[number charValue] :cardShowWidth];
        x += cardShowWidth;
    }
    number = [_cardArray lastObject];
    [G4OutedCardGroup drawCard:x:[number charValue]:[G4CardSize cardWidth]];
    CGImageRef imageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIImage* image = [[UIImage alloc] initWithCGImage:imageRef];
    CFRelease(imageRef);
    UIGraphicsEndImageContext();
    

    x = 0;
    float drawWidth = width;
    if(needWidth < width)
    {
        x = (width - needWidth) / 2;
        drawWidth = needWidth;
    }
    CGRect cardRect;
    if(groupDirection == GROUP_DIRECTION_LEFT || groupDirection == GROUP_DIRECTION_RIGHT)
        cardRect = CGRectMake(0, x, drawWidth, [G4CardSize cardHeight]);
    else
        cardRect = CGRectMake(x, 0, drawWidth, [G4CardSize cardHeight]);
    
//    G4ViewController* controller = (G4ViewController*) [UIApplication sharedApplication].delegate.window.rootViewController;
//    [controller drawImageForTest:image];
    char direction = groupDirection;
    if(direction == GROUP_DIRECTION_UP)
        direction = 0;
    [G4CardImage drawImage:image :direction :cardRect];
    [image release];
        
}

+(void)drawCard:(float)x:(char)cardNumber:(float)cardShowWidth
{
    CGPoint offset = CGPointMake(x, 0);
    CGRect cardRect = CGRectMake(x, 0, [G4CardSize cardWidth], [G4CardSize cardHeight]);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:cardRect cornerRadius:[G4CardSize cardCorner]];
    [[UIColor whiteColor] set];
    [path fill];
    [[UIColor blackColor] set];
    [path stroke];
    float y = [G4CardImage drawCardDigit:offset:cardNumber:cardShowWidth];
    [G4CardImage drawTypeImage:offset:cardNumber :cardShowWidth :y];
    [G4CardImage drawCenterImage:offset:cardNumber :cardShowWidth:2];
}

-(void)removeAllCards
{
    [_cardArray removeAllObjects];
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    [self drawAllCards];
    UIGraphicsPopContext();
}

-(void)animation:(CGPoint)from
{
    [_groupLayer removeAllAnimations];
    _animation.fromValue = [NSValue valueWithCGPoint:from];
    _animation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    NSLog(@"Outed Card animation:(%.2f,%0.2f)", from.x, from.y);
    [_groupLayer addAnimation:_animation forKey:@"for me out card"];
}

-(void)animation
{
    [_groupLayer removeAllAnimations];
    _animation.fromValue = [NSNumber numberWithFloat:0.1f];
    _animation.toValue = [NSNumber numberWithFloat:1.0f];
    [_groupLayer addAnimation:_animation forKey:@"for out card"];
}
@end
