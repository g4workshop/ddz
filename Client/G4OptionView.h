//
//  G4OptionView.h
//  DDZ
//
//  Created by gyf on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define MAX_BACK_GROUND_IMAGE       2

@interface G4OptionView : UIView
{
@private
    UIView* _superView;
    CABasicAnimation* _animationShow;
    NSTimer* _timer;
    float _interval;
    UISlider* _volumnSlider;
    UIButton* _closeButton;
    UIButton* _bkgroundButton[MAX_BACK_GROUND_IMAGE];
    UIFont* _font;
    float _fontHeight;
    BOOL _showAnimationed;
    char _animationState;
}

-(id)init:(UIView*)superView;
-(void)dealloc;

-(void)show:(BOOL)animation:(float)interval;
-(void)hide:(BOOL)animation;
-(void)resetTimer;
-(void)timeReached:(NSTimer*)theTimer;
-(void)sliderValueChanged;

-(void)bkgroundButtonClicked:(id)sender;
-(void)closeButtonClicked:(id)sender;

-(void)createVolumnSlider;
-(void)createBackgroundImageButtons;
-(void)createCloseButton;

-(void)doHide;

@end
