//
//  G4ViewController.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G4PokerCard.h"
#import "G4CardGroup.h"
#import "G4OutedCardGroup.h"
#import "G4Comm.h"
#import "G4WaitingLayer.h"
#import "G4AdLayer.h"
#import "G4GamePlayer.h"
#import "G4DeckCard.h"
#import "G4Watcher.h"
#import "G4FloatInfoLayer.h"
#import "G4CmdPannel.h"
#import "G4FSM.h"
#import "G4ResultLayer.h"
#import "G4OptionView.h"

#define G4_DDZ_APP_STATE_SELECT_MODE           0x00
#define G4_DDZ_APP_STATE_WIFI_MODE             0x01
#define G4_DDZ_APP_STATE_GAMECENTER_MODE       0x02

int random_player_random_id(void);


@interface G4ViewController : UIViewController
{
@private
    G4Comm* _comm;
    
    G4GameManager* _gameManager;
    
    G4WaitingLayer* _waitingLayer;
    G4AdLayer* _adLayer;
    G4ResultLayer* _resultLayer;
    G4OptionView* _optionView;
    
    
    NSString* _displayName;
    
    char _gameState;
    
    G4DeckCard* _deckCard;
    
    G4Watcher* _watcher;
    
    G4CmdPannel* _cmdPannel;
    
    UIButton* _wifiButton;
    UIButton* _gamecenterButton;
    
    
    char _touchBeganOfCardIndex;
    char _touchLastMovedOfCardIndex;
    BOOL _moveSelect;
    
    UIButton* _cmdOptionButton;
}

@property(nonatomic)char _appState;
@property(nonatomic,retain)UIImage* _image;

-(void)drawImageForTest:(UIImage*)image;

-(void)releaseAll;

-(void)createModeWifiButton;
-(void)createModeGamecenterButton;

-(void)createCmdButtons;

-(UIButton*)createCmdButton:(float)rightX:(UIImage*)image;

-(void)onCmdButtonClicked:(id)sender;

-(void)onButtonTouched:(id)sender;

-(char)touchMoveDirction:(char)index1:(char)index2;

-(void)changeBkgroundImage:(char)index;
@end


