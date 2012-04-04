//
//  G4OptionView.m
//  DDZ
//
//  Created by gyf on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4OptionView.h"
#import "G4CardSize.h"
#import "G4ViewController.h"
#import "G4DDZAudioManager.h"
#import "G4CardImage.h"

@implementation G4OptionView

-(id)init:(UIView*)superView
{
    if(!(self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]))
       return nil;

    _font = [[UIFont fontWithName:@"Helvetica" size:[G4CardSize optionViewFontSize]] retain];
    _fontHeight = [@"我" sizeWithFont:_font].height;
    float x = ([G4CardSize deviceViewSize].width - [G4CardSize optionViewWidth]) / 2;
    float height = [G4CardSize optionViewCloseButtonSize] + [G4CardSize optionViewSpace] * 3 + [G4CardSize optionViewSliderHeight] + [G4CardSize optionViewBkGroundButtonSize] + 2 * _fontHeight;
    float y = ([G4CardSize deviceViewSize].height - height) / 2;

    CGRect frame = CGRectMake(x, y, [G4CardSize optionViewWidth], height);
    _superView = [superView retain];
    
    [super setFrame:frame];
    
    [super setBackgroundColor:[UIColor clearColor]]; 
    

#ifdef ANIMATION_SCALE
    _animationShow = [[CABasicAnimation animationWithKeyPath:@"transform.scale"] retain];
#else    
    _animationShow = [[CABasicAnimation animationWithKeyPath:@"transform.translation.y"] retain];       
#endif
    _animationShow.fillMode=kCAFillModeForwards;
    _animationShow.removedOnCompletion=NO;
    _animationShow.duration = 0.4f;
    _animationShow.delegate = self;
    _animationState = 0;
    [self createCloseButton];
    [self createVolumnSlider];
    [self createBackgroundImageButtons];
    [self setNeedsDisplay];
    return self;
}

-(void)dealloc
{
    NSLog(@"OptionView dealloced\n");
    [self removeFromSuperview];
    [self.layer removeAllAnimations];
    [_superView release];
    [_animationShow release];
    if([_timer isValid])
        [_timer invalidate];
    [_timer release];
    [_volumnSlider release];
    [_closeButton release];
    for(char i = 0; i < MAX_BACK_GROUND_IMAGE; i++)
        [_bkgroundButton[i] release];
    [_font release];
}

-(void)show:(BOOL)animation:(float)interval
{
    _showAnimationed = animation;
    if(self.superview != nil)
        return;
    [_superView addSubview:self];
    if(animation && _animationState == 0)
    {
#ifndef ANIMATION_SCALE
        float from = -self.frame.size.height - self.frame.origin.y;
        _animationShow.fromValue = [NSNumber numberWithFloat:from];
        _animationShow.toValue = [NSNumber numberWithFloat:0];
#else
        _animationShow.fromValue = [NSNumber numberWithFloat:0.1];
        _animationShow.toValue = [NSNumber numberWithFloat:1.0];
#endif
        [self.layer addAnimation:_animationShow forKey:nil];
        _animationState = 1;
    }
    _interval = interval;
    [self resetTimer];
}

-(void)hide:(BOOL)animation
{
    if(animation && _animationState == 0)
    {
#ifndef ANIMATION_SCALE
        float to = -self.frame.size.height - self.frame.origin.y;
        _animationShow.fromValue = [NSNumber numberWithFloat:0];
        _animationShow.toValue = [NSNumber numberWithFloat:to];
#else
        _animationShow.fromValue = [NSNumber numberWithFloat:1.0];
        _animationShow.toValue = [NSNumber numberWithFloat:0.1];
#endif
        [self.layer addAnimation:_animationShow forKey:nil];
        _animationState = 2;
    }
    else
        [self doHide];
}

-(void)resetTimer
{
    if(_timer && [_timer isValid])
        [_timer invalidate];
    [_timer release];
    if(_interval > 0.01)
        _timer = [[NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(timeReached:) userInfo:nil repeats:YES] retain];
}

-(void)timeReached:(NSTimer*)theTimer
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [self hide:_showAnimationed];
}

-(void)sliderValueChanged
{
    char volumn = (char)(_volumnSlider.value * 10);
    [[G4DDZAudioManager sharedManager] changeBackgroundMusicVolumnTo:volumn];
    [self resetTimer];
}

-(void)bkgroundButtonClicked:(id)sender
{
    G4ViewController* controller = (G4ViewController*) [UIApplication sharedApplication].delegate.window.rootViewController;
    [controller changeBkgroundImage:((UIButton*)sender).tag];
    [self resetTimer];
}

-(void)closeButtonClicked:(id)sender
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [self hide:_showAnimationed];
}

-(void)createVolumnSlider
{    
    float x = 2 * [G4CardSize optionViewSpace];
    float y = [G4CardSize optionViewCloseButtonSize] + [G4CardSize optionViewSpace] + _fontHeight;
    _volumnSlider = [[UISlider alloc] initWithFrame:CGRectMake(x, y, self.frame.size.width - 2 * x, [G4CardSize optionViewSliderHeight])];
    _volumnSlider.minimumValue = 0.1;
    _volumnSlider.maximumValue = 1.0;
    _volumnSlider.value = ((float)[G4DDZAudioManager sharedManager].backgroundMusicVolumn) / 10.0f;
    [_volumnSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_volumnSlider];
}

-(void)createBackgroundImageButtons
{
    float x = 2 * [G4CardSize optionViewSpace];
    float y = [G4CardSize optionViewCloseButtonSize] + 2 * [G4CardSize optionViewSpace] + 2 * _fontHeight + [G4CardSize optionViewSliderHeight];
    for(int i = 0; i < MAX_BACK_GROUND_IMAGE; i++)
    {
        _bkgroundButton[i] = [[UIButton alloc] initWithFrame:CGRectMake(x, y, [G4CardSize optionViewBkGroundButtonSize], [G4CardSize optionViewBkGroundButtonSize])];
        _bkgroundButton[i].tag = i;
        [_bkgroundButton[i] setBackgroundImage:[G4CardImage gameBKImage:i] forState:UIControlStateNormal];
        [_bkgroundButton[i] addTarget:self action:@selector(bkgroundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_bkgroundButton[i]];
        x += [G4CardSize optionViewSpace] + [G4CardSize optionViewBkGroundButtonSize];
    }
}

-(void)createCloseButton
{
    float x = self.frame.size.width - [G4CardSize optionViewCloseButtonSize];
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, [G4CardSize optionViewCloseButtonSize], [G4CardSize optionViewCloseButtonSize])];
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
}

-(void)drawRect:(CGRect)rect
{
    float t = sqrt(0.0858);
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, [G4CardSize optionViewCloseButtonSize] - [G4CardSize optionViewCloseButtonSize] / 2 * t - [G4CardSize cardCorner] * t, self.frame.size.width - [G4CardSize optionViewCloseButtonSize] + [G4CardSize optionViewCloseButtonSize] / 2 * t + [G4CardSize cardCorner] * t, self.frame.size.height - [G4CardSize optionViewCloseButtonSize]) cornerRadius:[G4CardSize cardCorner]];
    [[[UIColor blackColor] colorWithAlphaComponent:0.3] set];
    [path fill];
    [[UIColor whiteColor] set];
    float y = [G4CardSize optionViewCloseButtonSize] + [G4CardSize optionViewSpace];
    [@"背景音量" drawAtPoint:CGPointMake([G4CardSize optionViewSpace] * 2, y) withFont:_font];
    y += _fontHeight + [G4CardSize optionViewSpace] + [G4CardSize optionViewSliderHeight];
    [@"背景图像" drawAtPoint:CGPointMake([G4CardSize optionViewSpace] * 2, y) withFont:_font];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.layer removeAllAnimations];
    NSLog(@"AnimationStop,RetainCount:%d\n", [self retainCount]);
    if(_animationState == 2)
        [self doHide];
    _animationState = 0;
}

-(void)doHide
{
    [self release];
    _animationShow.delegate = nil;
    [super removeFromSuperview];
}
@end
