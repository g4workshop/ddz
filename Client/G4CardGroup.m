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

@synthesize playerId;
@synthesize maxCardCount;
@synthesize delegate;

-(id)initWithSuperLayer:(CALayer*)superLayer andFrame:(CGRect)frame
{
    if(self = [super init])
    {
        _frame = frame;
        _superLayer = [superLayer retain];
        _cardArray = [[NSMutableArray alloc] init];
        
        float x = [G4CardSize deviceViewSize].width / 2 - _frame.origin.x - [G4CardSize cardWidth] / 2;
        float y = _frame.origin.y - [G4CardSize deviceViewSize].height / 2 + [G4CardSize cardHeight] / 2;
        [G4CardSize setMaxDistance:x :y];
        
        _groupLayer = [[CALayer layer] retain];
        [_groupLayer setBackgroundColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderColor:[UIColor clearColor].CGColor];
        [_groupLayer setBorderWidth:0];
        
        [_groupLayer setFrame:frame];
        
        _animationSort = [[CABasicAnimation animationWithKeyPath:@"transform.scale.x"] retain];
        _animationSort.delegate = self;
        [_animationSort setValue:[NSNumber numberWithChar:1] forKey:@"animation_type"];
        
        _animationSort.fillMode=kCAFillModeForwards;
        _animationSort.removedOnCompletion=NO;

        _animationShow = [[CABasicAnimation animationWithKeyPath:@"transform.translation"] retain];       
        _animationShow.delegate = self;
        
        [_animationShow setValue:[NSNumber numberWithChar:2] forKey:@"animation_type"];

        return self;
    }
    return nil;
}

-(void)dealloc
{
    NSLog(@"Card Group dealloced\n");
    [_animationShow release];
    [_animationSort release];
    [_groupLayer removeFromSuperlayer];
    [_groupLayer removeAllAnimations];
    [_groupLayer release];
    [_superLayer release];
    [_cardArray release];
    [super dealloc];
}

-(void)show:(char)fromIndex:(BOOL)animation
{
    [self layoutCardsNeedCalcNewCardShowWidth];
    if(animation)
        [self animationShow:fromIndex];
    else
    {
        for(G4PokerCard* card in _cardArray)
            [card addToSuperLayer:_superLayer];
        [self sort:animation];
        //[delegate didShowed];
    }
}

-(void)hide
{
    [_cardArray removeAllObjects];
}

-(void)sort:(BOOL)animation
{
    if(!animation)
    {
        [self sortCards];
        [delegate didShowed];
    }
    else
    {
        [self copyCardImage];
        [_superLayer addSublayer:_groupLayer];
        for(G4PokerCard* card in _cardArray)
            [card showCard:NO];
        [self sortCards];
        [self animationSort:0];
    }
}

-(void)animationShow:(char)index
{
    NSLog(@"AnimationShow:%d\n", index);
    G4PokerCard* card = (G4PokerCard*)[_cardArray objectAtIndex:index];

    [card setCardWidth:[G4CardSize cardWidth]];
    [card addToSuperLayer:_superLayer];
    [_animationShow setValue:[NSNumber numberWithChar:index] forKey:@"card_anim_value"];
    float translation_x = [G4CardSize deviceViewSize].width / 2 - ([card getX] + [G4CardSize cardWidth] / 2);
    float translation_y = _frame.origin.y + [G4CardSize cardHeight] / 2 - [G4CardSize deviceViewSize].height / 2;
    _animationShow.fromValue = [NSValue valueWithCGPoint:CGPointMake(translation_x, -translation_y)];
    _animationShow.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    _animationShow.duration = [G4CardSize calcDealPokerAnimationDuration:translation_x :translation_y];
    NSLog(@"duration=%.2f\n", _animationShow.duration);
    [card startAnimation:_animationShow];
}

-(void)animationSort:(char)state
{
    [_animationSort setValue:[NSNumber numberWithChar:state] forKey:@"card_anim_value"];
    if(state == 0)
        [self animationFrom:1.0f :0.7f :0.5f];
    else if(state == 1)
        [self animationFrom:0.8f :1.1f :0.5f];
    else
        [self animationFrom:1.1f :1.0f :0.6f];
}

-(void)showAnimationStopped:(char)index
{
    G4PokerCard* card = (G4PokerCard*)[_cardArray objectAtIndex:index];
    [card stopAnimation];
    index++;
    if(index >= [_cardArray count])
        [self sort:YES];
        //[delegate didShowed];
    else
        [self animationShow:index];
}

-(void)sortAnimationStopped:(char)state
{
    [_groupLayer removeAllAnimations];
    state++;
    if(state >= 3)
    {
        for(G4PokerCard* card in _cardArray)
            [card showCard:YES];
        [_groupLayer removeFromSuperlayer];
        [delegate didShowed];
    }
    else
        [self animationSort:state];
}

-(void)copyCardImage
{
    UIGraphicsBeginImageContext([G4CardSize deviceViewSize]);
    [_superLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGImageRef refOfGroupImage = CGImageCreateWithImageInRect(viewImage.CGImage, _frame);

    _groupLayer.contents = (id)refOfGroupImage;
    
    CGImageRelease(refOfGroupImage);
}


-(void)setMaxCardCount:(char)max
{
    maxCardCount = max;
    [self calcCardShowWidth:maxCardCount];
}

-(void)calcCardShowWidth:(char)count;
{
    float width = _frame.size.width;
    if(count <= 1)
        _cardShowWidth = [G4CardSize cardWidth];
    else
    {
        _cardShowWidth = (width - [G4CardSize cardWidth]) / (float)(count - 1);
        if(_cardShowWidth >= [G4CardSize cardMaxShowWidth])
            _cardShowWidth = [G4CardSize cardMaxShowWidth];
    }
}

-(float)addPokerCard:(char)cardNumber
{
    if([_cardArray count] != 0)
        [((G4PokerCard*)[_cardArray lastObject]) setCardWidth:_cardShowWidth];
    float x = [_cardArray count] * _cardShowWidth;

    G4PokerCard* card = [[G4PokerCard alloc] init];
    [card layout:x + _frame.origin.x:_frame.origin.y:[G4CardSize cardWidth]];
    card.cardNumber = cardNumber;
    [_cardArray addObject:card];
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

-(void)layoutCardsNeedCalcNewCardShowWidth
{
    [self calcCardShowWidth:(char)[_cardArray count]];
    [self layoutCards];
}

-(float)layoutCards
{
    float x = 0;
    for(G4PokerCard* card in _cardArray)
    {
        [card layoutX:x + _frame.origin.x :_cardShowWidth];
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

-(void)sortCards
{    
    NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    for(G4PokerCard* card in _cardArray)
    {
        [card showCard:NO];
        [self addPokerCard:tmpArray:card];
    }
    [_cardArray release];
    _cardArray = tmpArray;
    [self layoutCardsNeedCalcNewCardShowWidth];
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
    _animationSort.fromValue = [NSNumber numberWithFloat:from];
    _animationSort.toValue = [NSNumber numberWithFloat:to];
    _animationSort.duration = duration;
    [_groupLayer addAnimation:_animationSort forKey:@"moved group scale"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //[_groupLayer removeAllAnimations];
    NSNumber* typeNumber = [anim valueForKey:@"animation_type"];
    NSNumber* valueNumber = [anim valueForKey:@"card_anim_value"];
    NSLog(@"Animation Stopped:%d-%d\n", typeNumber.charValue, valueNumber.charValue);
    if(typeNumber.charValue == 1)
        [self sortAnimationStopped:valueNumber.charValue];
    else if(typeNumber.charValue == 2)
        [self showAnimationStopped:valueNumber.charValue];
}

-(void)cardSwitchSelect:(CGPoint)point
{
//    CGPoint myPoint = [_groupLayer convertPoint:point fromLayer:_superLayer];
    int countOfCards = [_cardArray count];
    for(int i = countOfCards - 1; i >= 0; i--)
    {
        G4PokerCard* card = (G4PokerCard*)[_cardArray objectAtIndex:i];
        if([card containtsPoint:point])
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
    return _frame.origin.x + (_cardShowWidth * ([_cardArray count] - 1) + [G4CardSize cardWidth]) / 2;
}

-(float)getFirstSelectX
{
    for(G4PokerCard* card in _cardArray)
    {
        if(card.selected)
            return card.getX + [G4CardSize cardWidth] / 2;
    }
    return [self getGroupCenterX];
}

-(BOOL)yInvalid:(float)y
{
    return (y > _frame.origin.y) && (y < _frame.origin.y + [G4CardSize cardHeight]);
}

-(void)selectCard:(BOOL)select fromIndex:(char)fromIndex toIndex:(char)toIndex
{
    for(char i = fromIndex; i >= 0 && i <= toIndex && i < [_cardArray count]; i++)
    {
        G4PokerCard* card = [_cardArray objectAtIndex:i];
        [card selectCard:select];
    }
}

-(char)indexOfCardByX:(float)x
{
    for(char i = 0; i < [_cardArray count]; i++)
    {
        G4PokerCard* card = [_cardArray objectAtIndex:i];
        if(i == 0 && [card getX] > x)
            return 0;
        if(i == [_cardArray count] - 1 && [card getX] < x)
            return [_cardArray count] - 1;
        if([card containtsX:x])
            return i;
    }
    return -1;
}
@end
