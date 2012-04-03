//
//  G4GamePlayer.h
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4OutedCardGroup.h"
#import "G4PlayerInfoLayer.h"
#import "G4FloatInfoLayer.h"
#import "G4Packet.h"
#import "G4CardGroup.h"
#import "G4Packet.h"
#import "G4DDZRuler.h"

#define NET_STATUS_UNKNOWN          0x00
#define NET_STATUS_ALIVE            0x01
#define NET_STATUS_DETECTING        0x02
#define NET_STATUS_DISCONNECTED     0x03

#define PLAYER_STATE_WAITING        0x01
#define PLAYER_STATE_READY          0x02
#define PLAYER_STATE_CARD_DEALED    0x03
#define PLAYER_STATE_READY_FOR_PLAY 0x04


@interface G4GamePlayer : NSObject
{
@private
    G4OutedCardGroup* _outedCardGroup;
    G4PlayerInfoLayer* _playerInfoLayer;
    G4FloatInfoLayer* _floatInfoLayer;
    NSMutableArray* _cardArray;
    NSString* _peerId;
    NSString* _playerName;
}

@property(nonatomic)BOOL _autoPlay;
@property(nonatomic)char _score;
@property(nonatomic)BOOL _computerPlayer;
@property(nonatomic)char _networkState;
@property(nonatomic)int _randomId;
@property(nonatomic)BOOL _isSelf;
@property(nonatomic)char _playerId;
@property(nonatomic)char _playerState;
@property(nonatomic)short _totalScore;
@property(nonatomic)short _roundScore;


-(id)initWithPeerId:(NSString*)peerId playerName:(NSString*)playerName randomId:(int)randomId isSelf:(BOOL)isSelf computerPlayer:(BOOL)computerPlayer;

-(void)initOutedGroup:(CALayer*)superLayer:(char)direction:(CGRect)frame;
-(void)initPlayerInfo:(CALayer*)superLayer:(CGPoint)point;
-(void)initFloatInfo:(CALayer*)superLayer:(CGRect)frame;
-(void)dealloc;
-(BOOL)isEqualToPeer:(NSString*)peerId;
-(BOOL)isEqualToName:(NSString*)name andRandomId:(int)randomId;

-(void)showFloatInfo:(NSString*)showInfo:(float)maxTime;
-(void)hideFloatInfo;

-(void)resetCardCount;
-(void)showPlayerInfo:(BOOL)show;

-(void)showOutedCard:(BOOL)show;
-(void)addOutedCard:(char)cardNumber;
-(void)moveCardToOutedCard:(G4CharArray*) cardArray;

-(void)clearAllCards;
-(void)setCardCenterX:(float)x;

-(void)addCard:(char)cardNumber;
-(void)rmvCard:(char)cardNumber;

-(int)countOfCard;
-(char)getCard:(char)index;

-(char)getGroupDirection;

-(int)compareWith:(G4GamePlayer*)player;

-(NSString*)getPlayerName;
-(NSString*)getPeerId;
@end

@protocol G4GameManagerDelegate <NSObject>

-(void)serverChanged:(char)oldServer newServer:(char)newServer;

@end

@interface G4GameManager : NSObject
{
@private
    NSMutableArray* _playerArray;
    G4CharArray* _dzCardArray;
    G4CardGroup* _cardGroup;
    G4CharArray* _lastOutedCard;
}

@property(nonatomic)char _selfId;
@property(nonatomic)char _realMasterId;
@property(nonatomic)char _firstMasterId;
@property(nonatomic)char _currentPlayerId;
@property(nonatomic)char _serverId;
@property(nonatomic)char _currentScore;
@property(nonatomic)char _firstOutPlayerId;
@property(nonatomic)char _lastOutPlayerId;
@property(nonatomic)char _roundCount;

@property(nonatomic,assign)NSObject<G4GameManagerDelegate>* _delegate;

-(id)init;
-(void)dealloc;

-(char)addGamePlayer:(NSString*)peerId playerName:(NSString*)playerName randomId:(int)randomId isSelf:(BOOL)isSelf computerPlayer:(BOOL)computerPlayer;
-(void)rmvGamePlayer:(NSString*)peerId;

-(G4GamePlayer*)getGamePlayer:(char)index;
-(G4GamePlayer*)findGamePlayer:(NSString*)peerId;

-(char)countOfPlayer;

-(void)nextPlayer;

-(void)resetServerId;
-(void)resetSelfId;

-(BOOL)isServer;

-(BOOL)isPlayerExists:(NSString*)name andRandomId:(int)randomId;

-(char)getNotComputerPlayersCount;

-(void)initCardGroup:(CALayer*)superLayer:(id)delegate;
-(void)initPlayerParameter:(CALayer*)superLayer;
-(void)hideCardGroup;

-(void)putDZCard:(G4CharArray*)cardArray;

-(void)moveDZCard;
-(void)moveCardToGroup;

-(void)dealCard:(char)fromIndex;

-(void)resetPlayerId;

-(char)getSelectedCard:(char*)cardNumbers;
-(void)unSelectAllCard;
-(void)cardSwitchSelect:(CGPoint)pt;
-(void)rmvCards:(G4CharArray*) cardArray;
-(void)setSelfOutFromX;

-(BOOL)cardGroupYInvalid:(float)y;
-(char)indexOfCardByX:(float)x;
-(void)selectCard:(BOOL)select fromIndex:(char)fromIndex toIndex:(char)toIndex;


-(void)reset;
-(void)roundResult:(char)winner;

-(void)setOutedCard:(G4Packet*)packet;
-(void)copyOutedCard:(CARD_ANALYZE_DATA*)data;
-(void)resetOutedCard;

-(BOOL)isAllPlayerStateOf:(char)state;

@end