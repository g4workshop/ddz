//
//  G4GameFSM.h
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4ViewController.h"
#import "G4Comm.h"
#import "G4DDZRuler.h"
#import "G4ResultLayer.h"


#define G4_GAME_INITING                0x00
#define G4_GAME_WAITING_PLAYERS        0x01
#define G4_GAME_WAITING_PLAYERS_READY  0x02
#define G4_GAME_WAITING_CARDS          0x03
#define G4_GAME_DISPLAY_AD             0x04
#define G4_GAME_DEALING_CARDS          0x05
#define G4_GAME_DOING_QDZ               0x06
#define G4_GAME_DEALING_DZ_CARDS    0x07
#define G4_GAME_PLAYING                     0x08

#define G4_DDZ_APP_STARTED          0x1000
#define G4_DDZ_PLAYER_INFO          0x1002
#define G4_DDZ_PLAYER_READY         0x1003
#define G4_DDZ_CARD_INFO            0x1004
#define G4_DDZ_TIME_OUT             0x1005
#define G4_DDZ_CARD_DEALED          0x1006
#define G4_DDZ_QDZ_INFO             0x1008
#define G4_DDZ_READY_FOR_PLAY       0x1009
#define G4_DDZ_OUT_CARD_INFO        0x100b
#define G4_DDZ_GAME_OVER            0x100c

#define G4_DDZ_KEY_ID               0x1000
#define G4_DDZ_KEY_NAME             0x1001
#define G4_DDZ_KEY_FLAG             0x1002
#define G4_DDZ_KEY_CARD             0x1003
#define G4_DDZ_KEY_SCORE            0x1004
#define G4_DDZ_KEY_WINNER           0x1005

#define G4_LOGING_INFO
#define G4_LOGING_DEBUG
#define G4_LOGING_ERROR

@interface G4ViewController(G4GameFSM)<G4WatcherDelegate,G4CmdDelegate,G4CardGroupDelegate,G4MHandlerDelegate,G4ResultDelegate>

-(void)run:(G4Packet*)packet;

-(void)on_initing:(G4Packet*)packet;
-(void)on_initing_recv_app_started:(G4Packet*)packet;  //goto waiting players

-(void)on_waiting_players:(G4Packet*)packet;
-(void)on_waiting_players_recv_player_info:(G4Packet*)packet;
-(void)on_waiting_players_recv_comm_connected:(G4Packet*)packet;
-(void)on_waiting_players_recv_comm_disconnected:(G4Packet*)packet;

-(void)on_waiting_players_ready:(G4Packet*)packet;
-(void)on_waiting_players_ready_recv_player_ready:(G4Packet*)packet;
-(void)on_waiting_players_ready_recv_time_out:(G4Packet*)packet;

-(void)on_waiting_cards:(G4Packet*)packet;
-(void)on_waiting_cards_info_recv_card_info:(G4Packet*)packet;     //goto waiting dealing card
-(void)on_waiting_cards_info_recv_time_out:(G4Packet*)packet;   

-(void)on_dealing_cards:(G4Packet*)packet;
-(void)on_dealing_cards_recv_card_dealed:(G4Packet*)packet;
-(void)on_dealing_cards_recv_time_out:(G4Packet*)packet;

-(void)on_doing_qdz:(G4Packet*)packet;
-(void)on_qdz_recv_time_out:(G4Packet*)packet;
-(void)on_qdz_recv_qdz_info:(G4Packet*)packet;

-(void)on_dealing_dz_cards:(G4Packet*)packet;
-(void)on_dealing_dz_cards_recv_ready_for_play:(G4Packet*)packet;
-(void)on_dealing_dz_cards_recv_time_out:(G4Packet*)packet;

-(void)on_game_playing:(G4Packet*)packet;
-(void)on_game_playing_recv_card_out_info:(G4Packet*)packet;
-(void)on_game_playing_recv_game_over:(G4Packet*)packet;
-(void)on_game_playing_recv_time_out:(G4Packet*)packet;


-(void)on_all_state_recv_my_net_failed:(G4Packet*)packet;

//actions

-(void)doSendPlayerInfo:(NSString*)peerId name:(NSString*)name randomId:(int)randomId computerFlag:(char)computerFlag;
-(void)doAppStart;
-(void)doAddAComputerPlayer;
-(void)doShowWatcherOnCenter:(float)interval;
-(void)doSendComputerPlayerToPlayer:(NSString*)peerId;
-(void)doSendPlayerReady;
-(void)doSendCardDealed;
-(void)doShowQDZCmdPannel;
-(void)doShowOutCardCmdPannel;
-(void)doShowWatcher:(float)interval;
-(void)doSendQDZInfo:(char)score;
-(void)doShowQDZInfo:(char)score;
-(void)doClearAllFloatInfo;
-(void)doShowDZInfo;
-(void)doEnableOutCardCmdButton;
-(void)doShowWaitingPlayerWatcher:(float)timeInterval;
-(char)doCalcCurrentPlayerQDZScore;
-(void)doSendOutCardInfo:(CARD_ANALYZE_DATA*)data playerId:(char)playerId;
-(void)doShowPlayResult;
-(void)doDealingCards;
-(void)doQDZ;
@end



