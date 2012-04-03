//
//  G4CmdPannel.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4CmdPannel.h"
#import "G4CardSize.h"

@implementation G4CmdPannel

@synthesize deleate;

-(id)init:(UIView*)superView
{
    if(self = [super init])
    {
        _pannelView = [[UIView alloc] initWithFrame:[G4CardSize cmdPannelRect]];
        _superView = [superView retain];
        [_pannelView setBackgroundColor:[UIColor clearColor]];
        float space = (_pannelView.frame.size.width - 5 * [G4CardSize cmdButtonWidth]) / 4;
        float x = 0;
        NSString* normal1[] = {@"btn_score_1_e.png",@"btn_score_2_e.png",@"btn_score_3_e.png",@"btn_score_4_e.png",@"btn_bq_e.png"};
        NSString* disable1[] = {@"btn_score_1_d.png",@"btn_score_2_d.png",@"btn_score_3_d.png",@"btn_score_4_d.png",@"btn_bq_d.png"};
        for(int i = 0; i <= CMD_ID_CANCEL; i++)
        {
            [self createButton:i :x : normal1[i] : disable1[i]];
            x += space + [G4CardSize cmdButtonWidth];
        }
        space = (_pannelView.frame.size.width - 4 * [G4CardSize cmdButtonWidth]) / 3;
        x = 0;
        NSString* normal2[] = {@"btn_pass_e.png",@"btn_hint.png",@"btn_reselect.png",@"btn_outcard_e.png"};
        NSString* disable2[] = {@"btn_pass_d.png",@"btn_hint.png",@"btn_reselect.png",@"btn_outcard_d.png"};
        for(int i = CMD_ID_NOT_OUT; i < MAX_CMD_BUTTON; i++)
        {
            [self createButton:i :x : normal2[i - 5] : disable2[i - 5]];
            x += space + [G4CardSize cmdButtonWidth];
        }
    }
    return self;
}

-(void)dealloc
{
    for(int i = 0; i < MAX_CMD_BUTTON; i++)
    {
        [_buttonCmd[i] removeFromSuperview];
        [_buttonCmd[i] release];
    }
    [_pannelView removeFromSuperview];
    [_pannelView release];
    [_superView release];

}

-(void)enableOutCardButton:(BOOL)enabled
{
    [_buttonCmd[CMD_ID_OUT_CARD] setEnabled:enabled];
}

-(void)showCmdQDZ:(char*)enabled
{
    for(int i = 0; i <= CMD_ID_CANCEL; i++)
    {
        NSLog(@"ShowCmdQDZ enabled[%d] = %d\n", i, enabled[i]);
        [_buttonCmd[i] setHidden:NO];
        if(enabled[i] == 0)
            [_buttonCmd[i] setEnabled:NO];
        else
            [_buttonCmd[i] setEnabled:YES];
    }
    for(int i = CMD_ID_NOT_OUT; i < MAX_CMD_BUTTON; i++)
        [_buttonCmd[i] setHidden:YES];
    [_superView addSubview:_pannelView];
}

-(void)showCmdOutCard
{
    for(int i = 0; i <= CMD_ID_CANCEL; i++)
        [_buttonCmd[i] setHidden:YES];
    for(int i = CMD_ID_NOT_OUT; i < MAX_CMD_BUTTON; i++)
        [_buttonCmd[i] setHidden:NO];
    //[_buttonCmd[CMD_ID_OUT_CARD] setEnabled:NO];
    [_superView addSubview:_pannelView];
}

-(void)hide
{
    [_pannelView removeFromSuperview];
}

-(void)createButton:(int)index:(float)x:(NSString*)normal:(NSString*)disable
{

    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, [G4CardSize cmdButtonWidth], _pannelView.frame.size.height)];

    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setShowsTouchWhenHighlighted:YES];
    button.tag = index;
    [button setHidden:YES];
    [button setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:disable] forState:UIControlStateDisabled];

//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
//        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//        [button setTitle:caption forState:UIControlStateNormal];
    [_pannelView addSubview:button];
    _buttonCmd[index] = button;
}

-(void)buttonClicked:(UIButton*)sender
{
    if(sender.tag != CMD_ID_HINT && sender.tag != CMD_ID_RESELECT)
        [self hide];
    [deleate onCmd:sender.tag];
}

@end
