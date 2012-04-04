//
//  G4CmdPannel.h
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CMD_ID_SCORE_1          0x00
#define CMD_ID_SCORE_2          0x01
#define CMD_ID_SCORE_3          0x02
#define CMD_ID_SCORE_4          0x03
#define CMD_ID_CANCEL           0x04

#define CMD_ID_NOT_OUT          0x05
#define CMD_ID_HINT             0x06
#define CMD_ID_RESELECT         0x07
#define CMD_ID_OUT_CARD         0x08

#define MAX_CMD_BUTTON          0x09

@protocol G4CmdDelegate <NSObject>

-(void)onCmd:(char)cmdId;

@end

@interface G4CmdPannel : NSObject
{
@private
    UIView* _pannelView;
    UIView* _superView;
    UIButton* _buttonCmd[MAX_CMD_BUTTON];
}

@property(nonatomic,assign)NSObject<G4CmdDelegate>* deleate;

-(id)init:(UIView*)superView;
-(void)dealloc;
-(void)showCmdQDZ:(char*)enabled;
-(void)showCmdOutCard;
-(void)hide;
-(void)createButton:(int)index:(float)x:(NSString*)normal:(NSString*)disable;
-(void)buttonClicked:(UIButton*)sender;
-(void)enableOutCardButton:(BOOL)enabled;
-(void)enableNotoutCardButton:(BOOL)enabled;
@end
