//
//  G4CardGroup.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4CardGroup.h"
#import "G4CardSize.h"
#import "G4DDZRuler.h"

@implementation G4CardGroup

//@synthesize groupDirection;
@synthesize playerId;
@synthesize maxCardCount;

-(id)initWithSuperLayer:(CALayer*)superLayer andFrame:(CGRect)frame
{
    if(self = [super init])
    {
        _frame = frame;
        //_frame.origin.y = 0;
        _superLayer = [superLayer retain];
        _cardArray = [[NSMutableArray alloc] init];
        
        _groupLayer = [[CALayer layer] retain];
        [_groupLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderWidth:0];
                
        [_groupLayer setFrame:frame];
        _groupLayer.shadowOffset = CGSizeMake(0, 2);
        _groupLayer.shadowRadius = 5;
        _groupLayer.shadowColor = [UIColor blackColor].CGColor;
        _groupLayer.shadowOpacity = 0.4;
//        
        //_groupLayer.delegate = self;
        //[_groupLayer setNeedsDisplay];

        return self;
    }
    return nil;
}

-(void)dealloc
{
    NSLog(@"Card Group dealloced\n");
    [_superLayer release];
    [_cardArray release];
    [_groupLayer release];
    [super dealloc];
}

-(void)showGroup:(BOOL)show
{
    if(show)
    {
        if(_groupLayer.superlayer == nil)
            [_superLayer addSublayer:_groupLayer];
    }
    else
        [_groupLayer removeFromSuperlayer];
}

-(void)setMaxCardCount:(char)max
{
    maxCardCount = max;
    float width = _frame.size.width;//_groupLayer.frame.size.width;
    _cardShowWidth = (width - [G4CardSize cardWidth]) / (float)(maxCardCount - 1);
    if(_cardShowWidth >= [G4CardSize cardMaxShowWidth])
        _cardShowWidth = [G4CardSize cardMaxShowWidth];
}

-(float)addPokerCard:(char)cardNumber
{
    if([_cardArray count] != 0)
        [((G4PokerCard*)[_cardArray lastObject]) setCardWidth:_cardShowWidth];
    float x = [_cardArray count] * _cardShowWidth;

    G4PokerCard* card = [[G4PokerCard alloc] init];
    [card layout:x:_frame.origin.y:[G4CardSize cardWidth]];
    card.cardNumber = cardNumber;
    [_cardArray addObject:card];
    [card addToSuperLayer:_superLayer:NO];
    [card release];
    return x + _cardShowWidth;
}

-(void)rmvPokerCard:(char)cardNumber
{
    for(G4PokerCard* card in _cardArray)
    {
        if(card.cardNumber == cardNumber)
        {
            [_cardArray removeObject:card];
            break;
        }
    }
}

-(void)relayout
{
    int count = [_cardArray count];
    if(count == 0)
        return;
    if(count == 1)
        _cardShowWidth = [G4CardSize cardWidth];
    else
    {
        float width = _groupLayer.frame.size.width;
        _cardShowWidth = (width - [G4CardSize cardWidth]) / (float)(count - 1);
        if(_cardShowWidth >= [G4CardSize cardMaxShowWidth])
            _cardShowWidth = [G4CardSize cardMaxShowWidth];
    }
    [self layoutCards];
}

-(float)layoutCards
{
    float x = 0;
    for(G4PokerCard* card in _cardArray)
    {
        [card layoutX:x :_cardShowWidth];
        x += _cardShowWidth;
    }
    [((G4PokerCard*)[_cardArray lastObject]) setCardWidth:[G4CardSize cardWidth]];
    return x + _cardShowWidth;
}

-(void)addPokerCard:(NSMutableArray*)cardArray:(G4PokerCard *)card;
{
    int count = [cardArray count];
    int pos = 0;
    for(; pos < count; pos++)
    {
        G4PokerCard* another = [cardArray objectAtIndex:pos];
        if([G4DDZRuler comparePokerCard:card:another] >= 0)
            break;
    }
    if(pos == count)
        [cardArray addObject:card];
    else
        [cardArray insertObject:card atIndex:pos];
}

-(void)resortCards
{
//    UIGraphicsBeginImageContext(_groupLayer.frame.size);
//    [_groupLayer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    CALayer* imageLayer = [CALayer layer];
//    imageLayer.contents = (id)viewImage.CGImage;
//    imageLayer.frame = CGRectMake(0, 0, _groupLayer.frame.size.width, _groupLayer.frame.size.height);
//    [_groupLayer addSublayer:imageLayer];
    
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    for(G4PokerCard* card in _cardArray)
    {
        [card showCard:NO:nil];
        [self addPokerCard:tmpArray:card];
    }
    [_cardArray release];
    _cardArray = tmpArray;
    [self layoutCards];
    //[imageLayer removeFromSuperlayer];
    for(G4PokerCard* card in _cardArray)
        [card showCard:YES:nil];

    //[self animationFrom:1.0f :0.7f :0.5f];
    _animationState = 0;
}

-(BOOL)isReachMaxCardCount
{
    return ([_cardArray count] >= maxCardCount);
}

-(CGRect)calcRect:(CGRect)origRect:(float)width
{
    float x = origRect.origin.x + (origRect.size.width - width) / 2;
    return CGRectMake(x, origRect.origin.y, width, origRect.size.height);
}

-(void)animationFrom:(float)from:(float)to:(float)duration
{
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    _animation.fromValue = [NSNumber numberWithFloat:from];
    _animation.toValue = [NSNumber numberWithFloat:to];
    _animation.duration = duration;
    _animation.fillMode=kCAFillModeForwards;
    _animation.removedOnCompletion=NO;
    _animation.delegate = self;
    [_groupLayer addAnimation:_animation forKey:@"moved group scale"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [_groupLayer removeAllAnimations];
    _animationState ++;
    if(_animationState >= 3)
        return;
    if(_animationState == 1)
        [self animationFrom:0.8f :1.1f :0.5f];
    else
        [self animationFrom:1.1f :1.0f :0.6f];
}

-(void)cardSwitchSelect:(CGPoint)point
{
    CGPoint myPoint = [_groupLayer convertPoint:point fromLayer:_superLayer];
    int countOfCards = [_cardArray count];
    for(int i = countOfCards - 1; i >= 0; i--)
    {
        G4PokerCard* card = (G4PokerCard*)[_cardArray objectAtIndex:i];
        if([card containtsPoint:myPoint])
        {
            [card switchSelect];
            break;
        }
    }
}

-(char)getSelectedCard:(char *)cardNumbers
{
    char count = 0;
    for(G4PokerCard* card in _cardArray)
    {
        if(card.selected)
        {
            cardNumbers[count++] = card.cardNumber;
        }
    }
    return count;
}

-(void)unSelectAllCard
{
    for(G4PokerCard* card in _cardArray)
    {
        if(card.selected)
            [card switchSelect];
    }
}

-(float)getGroupCenterX
{
    return _groupLayer.frame.origin.x + (_cardShowWidth * ([_cardArray count] - 1) + [G4CardSize cardWidth]) / 2;
}

-(float)getFirstSelectX
{
    for(G4PokerCard* card in _cardArray)
    {
        if(card.selected)
            return _groupLayer.frame.origin.x + card.getX + [G4CardSize cardWidth] / 2;
    }
    return [self getGroupCenterX];
}
@end
