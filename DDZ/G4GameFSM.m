//
//  G4GameFSM.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GameFSM.h"
#import "G4CardSize.h"
#import "G4Key.h"
#import "G4CardSize.h"
#import "G4OutedCardGroup.h"
#import "G4GameInit.h"
#import "G4DDZRuler.h"
#import "G4GameServer.h"

static NSString* qdz_info[] = {@"1分",@"2分",@"3分",@"4分",@"不抢"};
static NSString* out_card_info = @"不出"; 



@implementation G4ViewController(G4GameFSM)


-(void)didShowed
{
   [self doSendCardDealed];
}

///
///////////////////
-(void)handlePacket:(G4Packet *)packet
{
    [self run:packet];
}

-(void)run:(G4Packet*)packet
{
    switch (_gameState)
    {
        case G4_GAME_INITING:
            [self on_initing:packet];
            break;
        case G4_GAME_WAITING_PLAYERS:
            [self on_waiting_players:packet];
            break;
        case G4_GAME_WAITING_PLAYERS_READY:
            [self on_waiting_players_ready:packet];
            break;
        case G4_GAME_WAITING_CARDS:
            [self on_waiting_cards:packet];
            break;
        case G4_GAME_DEALING_CARDS:
            [self on_dealing_cards:packet];
            break;
        case G4_GAME_DOING_QDZ:
            [self on_doing_qdz:packet];
            break;
        case G4_GAME_DEALING_DZ_CARDS:
            [self on_dealing_dz_cards:packet];
            break;
        case G4_GAME_PLAYING:
            [self on_game_playing:packet];
            break;
        default:
            break;
    }
}

-(void)on_all_state_recv_my_net_failed:(G4Packet*)packet
{
    
}

-(void)on_initing:(G4Packet *)packet
{
    if(packet.packetId == G4_DDZ_APP_STARTED)
        [self on_initing_recv_app_started:packet];
}

-(void)on_initing_recv_app_started:(G4Packet *)packet
{
#ifdef G4_LOGING_INFO
    if(self._appState == G4_DDZ_APP_STATE_WIFI_MODE)
        NSLog(@"[APP Initing]->AppStarted->[WaitingPlayers]\n");
    else
        NSLog(@"[App Initing]->AppStarted->[WaitingMatch]\n");
#endif
    _gameState = G4_GAME_WAITING_PLAYERS;
    [self initWaitView];
    [_adLayer showAd:YES];
}

-(void)on_waiting_players:(G4Packet*)packet
{
    switch (packet.packetId) {
        case G4_DDZ_PLAYER_INFO:
            [self on_waiting_players_recv_player_info:packet];
            break;
        case G4_COMM_CONNECTED:
            [self on_waiting_players_recv_comm_connected:packet];
            break;
        case G4_COMM_DISCONNECTED:
            [self on_waiting_players_recv_comm_disconnected:packet];
            break;
        default:
            break;
    }
}

-(void)on_waiting_players_recv_player_info:(G4Packet*)packet
{
    NSString* name = [packet get:G4_DDZ_KEY_NAME];
    NSNumber* flag = [packet get:G4_DDZ_KEY_FLAG];
    NSNumber* randomId = [packet get:G4_DDZ_KEY_ID];
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
#ifdef G4_LOGING_INFO
    NSLog(@"RECV PlayerInfo,peerId=%@,name=%@,randomId=%d,computerflag=%d\n",
          peerId, name, randomId.intValue, flag.charValue);
#endif
    char count = [_gameManager addGamePlayer:peerId playerName:name randomId:randomId.intValue isSelf:NO computerPlayer:flag.charValue != 0];
    [_waitingLayer redraw];

    if(flag.charValue == 0)
        [self server_playerAdded:peerId];
    if(count >= 4)
    {
#ifdef G4_LOGING_INFO
        NSLog(@"[WaitingPlayers]->PlayerInfo->[WaitingPlayerReady]\n");
#endif
        [_waitingLayer release];
        _waitingLayer = nil;
        [_gameManager initCardGroup:self.view.layer :self];
        [_gameManager initPlayerParameter:self.view.layer];
        _gameState = G4_GAME_WAITING_PLAYERS_READY;
        
        [self doSendPlayerReady];
    }
}

-(void)on_waiting_players_recv_comm_connected:(G4Packet*)packet
{
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
#ifdef G4_LOGING_INFO
    NSLog(@"RECV PeerConnected from %@\n", peerId);
#endif
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._selfId];
    [self doSendPlayerInfo:peerId name:[player getPlayerName] randomId:player._randomId computerFlag:0];
}

-(void)on_waiting_players_recv_comm_disconnected:(G4Packet*)packet
{
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
#ifdef G4_LOGING_ERROR
    NSLog(@"RECV PeerDisconnected from %@\n", peerId);
#endif
    [_gameManager rmvGamePlayer:peerId];
}

-(void)on_waiting_players_ready:(G4Packet*)packet
{
    switch (packet.packetId) {
        case G4_DDZ_PLAYER_READY:
            [self on_waiting_players_ready_recv_player_ready:packet];
            break;
        case G4_DDZ_TIME_OUT:
            [self on_waiting_players_ready_recv_time_out:packet];
            break;
        default:
            break;
    }
}

-(void)on_waiting_players_ready_recv_player_ready:(G4Packet*)packet
{
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
    G4GamePlayer* player = nil;
    if(peerId != nil)
    {
        player = [_gameManager findGamePlayer:peerId];
        if(player == nil)
        {
#ifdef G4_LOGING_INFO
            NSLog(@"RECV PlayerReady from peer:%@,but can't find this player\n", peerId);
#endif
            return;
        }
    }
    else
        player = [_gameManager getGamePlayer:_gameManager._selfId];
#ifdef G4_LOGING_INFO
    NSLog(@"RECV PlayerReady from peer:%@,PlayerName=%@,playerId=%d\n", peerId, [player getPlayerName], player._playerId);
#endif

    player._playerState = PLAYER_STATE_READY;
    if([_gameManager isAllPlayerStateOf:PLAYER_STATE_READY])
    {
#ifdef G4_LOGING_INFO
        NSLog(@"[WaitingPlayerReady]->PlayerAllReady->[WaitingCards]\n");
#endif        
        _gameState = G4_GAME_WAITING_CARDS;
        [self server_dealCard];
    }
}

-(void)on_waiting_players_ready_recv_time_out:(G4Packet*)packet
{
    
}

-(void)on_waiting_cards:(G4Packet *)packet
{
    switch (packet.packetId) {
        case G4_DDZ_CARD_INFO:
            [self on_waiting_cards_info_recv_card_info:packet];
            break;
                        
        case G4_DDZ_TIME_OUT:
            [self on_waiting_cards_info_recv_time_out:packet];
            break;
            
        default:
            break;
    }
}

-(void)on_waiting_cards_info_recv_card_info:(G4Packet*)packet
{
#ifdef G4_LOGING_INFO
    NSLog(@"[WaitingCards]->CardInfo->[WaitingDealingCard]\n");
#endif

    G4CharArray* cardArray = [packet get:G4_DDZ_KEY_CARD];
    _gameManager._realMasterId = -1;
    _gameManager._firstMasterId = -1;
    _gameManager._currentScore = -1;

    for(int j = 0; j < 25; j++)
    {
        for(int i = 0; i < 4; i++)
        {
            char ch = [cardArray get: j * 4 + i];
            [[_gameManager getGamePlayer:i] addCard:ch];
            if(ch == 40 && _gameManager._firstMasterId == -1)
                _gameManager._firstMasterId = i;
        }
    }
    NSLog(@"FirstMasterId=%d\n", _gameManager._firstMasterId);
    [_gameManager putDZCard:cardArray];
    _gameState = G4_GAME_DEALING_CARDS;
    [self doDealingCards];
}

-(void)on_waiting_cards_info_recv_time_out:(G4Packet*)packet
{
    
}

-(void)doDealingCards
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"Do Dealing Cards\n");
#endif
    for(char i = 0; i < [_gameManager countOfPlayer]; i++)
    {
        if(i == _gameManager._selfId)
            continue;
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        [player showPlayerInfo:YES];
    }
    [_adLayer showAd:NO];
    [_gameManager moveCardToGroup];
    [_gameManager dealCard:0];
}

-(void)on_dealing_cards:(G4Packet*)packet
{
    switch (packet.packetId) {
        case G4_DDZ_CARD_DEALED:
            [self on_dealing_cards_recv_card_dealed:packet];
            break;
        case G4_DDZ_TIME_OUT:
            [self on_dealing_cards_recv_time_out:packet];
            break;
        default:
            break;
    }
}

-(void)on_dealing_cards_recv_card_dealed:(G4Packet*)packet
{
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
    if(peerId == nil)
    {
#ifdef G4_LOGING_INFO
        NSLog(@"[dealingcards]->carddealed->[waiting qdz]\n");
#endif
        [_gameManager getGamePlayer:_gameManager._selfId]._playerState = PLAYER_STATE_CARD_DEALED;
    }
    else
    {
#ifdef G4_LOGING_DEBUG
        NSLog(@"RECV CardDealed from peer:%@\n", peerId);
#endif
        G4GamePlayer* player = [_gameManager findGamePlayer:peerId];
        player._playerState = PLAYER_STATE_CARD_DEALED;
    }
    if([_gameManager isAllPlayerStateOf:PLAYER_STATE_CARD_DEALED])
    {
        _gameState = G4_GAME_DOING_QDZ;
        [self doQDZ];
    }
}

-(void)on_dealing_cards_recv_time_out:(G4Packet*)packet
{
    
}

-(void)doQDZ
{
#ifdef G4_LOGING_INFO
    NSLog(@"DoQDZ,masterId=%d,currentPlayerId=%d,SelfId=%d\n", _gameManager._firstMasterId, _gameManager._currentPlayerId, _gameManager._selfId);
#endif
    _gameManager._currentPlayerId = _gameManager._firstMasterId;
    if(_gameManager._currentPlayerId == _gameManager._selfId)
        [self doShowQDZCmdPannel];
    else
        [self server_QDZ];
}

-(void)on_doing_qdz:(G4Packet *)packet
{
    switch (packet.packetId) {
        case G4_DDZ_QDZ_INFO:
            [self on_qdz_recv_qdz_info:packet];
            break;
        case G4_DDZ_TIME_OUT:
            [self on_qdz_recv_time_out:packet];
            break;
        default:
            break;
    }
}

-(void)on_qdz_recv_time_out:(G4Packet*)packet
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"RECV QDZTimeout when waiting qdz,currentPlayId=%d\n", _gameManager._currentPlayerId);
#endif
    
}

-(void)on_qdz_recv_qdz_info:(G4Packet*)packet
{
    NSNumber* playerId = [packet get:G4_DDZ_KEY_ID];
    NSNumber* score = [packet get:G4_DDZ_KEY_SCORE];
#ifdef G4_LOGING_INFO
    NSLog(@"RECV QDZ info when doing qdz,playerId=%d,score=%d,currentPlayerId=%d\n",
          playerId.charValue, score.charValue, _gameManager._currentPlayerId);
#endif
    if(playerId.charValue != _gameManager._currentPlayerId)
        _gameManager._currentPlayerId = playerId.charValue;
    
    [self doShowQDZInfo:score.charValue];
    
    char currentId = _gameManager._currentPlayerId;
    G4GamePlayer* player = [_gameManager getGamePlayer:currentId];
    player._score = score.charValue;
    
    if(player._score != 4 && _gameManager._currentScore < player._score)
    {
        _gameManager._currentScore = player._score;
        _gameManager._realMasterId = currentId;
#ifdef G4_LOGING_DEBUG
        NSLog(@"Set QDZ info,currentScore=%d,RealMasterId=%d\n", _gameManager._currentScore, _gameManager._realMasterId);
#endif
    }
    
    [_gameManager nextPlayer];
    
    if(_gameManager._currentPlayerId == _gameManager._firstMasterId || score.charValue == 3)
    {
        if(_gameManager._realMasterId < 0)
        {
#ifdef G4_LOGING_DEBUG
            NSLog(@"No player,so set to firstmasterId=%d\n", _gameManager._firstMasterId);
#endif
            _gameManager._realMasterId = _gameManager._firstMasterId;
            _gameManager._currentScore = 0;
        }
        [self doClearAllFloatInfo];
        [_gameManager moveDZCard];
        if(_gameManager._realMasterId == _gameManager._selfId)
            [_gameManager dealCard:25];
        else
            [self doShowDZInfo];
#ifdef G4_LOGING_INFO
        NSLog(@"[DoingQDZ]->EndQDZ->[DealingDZCard]\n");
#endif
        _gameState = G4_GAME_DEALING_DZ_CARDS;
        return;
    }
    if(_gameManager._currentPlayerId == _gameManager._selfId)
        [self doShowQDZCmdPannel];
    else
        [self server_QDZ];    
}

-(void)on_dealing_dz_cards:(G4Packet*)packet
{
    switch (packet.packetId) {
        case G4_DDZ_CARD_DEALED:
        case G4_DDZ_READY_FOR_PLAY:
            [self on_dealing_dz_cards_recv_ready_for_play:packet];
            break;
        case G4_DDZ_TIME_OUT:
            [self on_dealing_dz_cards_recv_time_out:packet];
            break;
        default:
            break;
    }
}

-(void)on_dealing_dz_cards_recv_time_out:(G4Packet*)packet
{
    
}

-(void)on_dealing_dz_cards_recv_ready_for_play:(G4Packet*)packet
{
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
    if(peerId == nil)
    {
#ifdef G4_LOGING_INFO
        NSLog(@"when waiting dzinfo displayed recv card dealed from self,realmasterId=%d,selfId=%d\n",
              _gameManager._realMasterId, _gameManager._selfId);
#endif
        if(_gameManager._realMasterId != _gameManager._selfId && packet.packetId == G4_DDZ_CARD_DEALED)
            return;
        [_gameManager getGamePlayer:_gameManager._selfId]._playerState = PLAYER_STATE_READY_FOR_PLAY;
    }
    else
    {
#ifdef G4_LOGING_DEBUG
        NSLog(@"when waiting dzinfo displayed recv card dealed from peer:%@\n", peerId);
#endif
        G4GamePlayer* player = [_gameManager findGamePlayer:peerId];
        if(player._playerId != _gameManager._realMasterId && packet.packetId == G4_DDZ_CARD_DEALED)
        {
#ifdef G4_LOGING_DEBUG
            NSLog(@"recv card dealed,but player:%d is not master player:%d,ignore this packet\n", player._playerId, _gameManager._realMasterId);
#endif
            return;
        }
        player._playerState = PLAYER_STATE_READY_FOR_PLAY;
    }
    if([_gameManager isAllPlayerStateOf:PLAYER_STATE_READY_FOR_PLAY])
    {
#ifdef G4_LOGING_DEBUG
        NSLog(@"[DoingQDZ]->AllReadyForPlay->[GamePlaying]\n");
#endif
        for(char i = 0; i < [_gameManager countOfPlayer]; i++)
            [[_gameManager getGamePlayer:i] resetCardCount];
        _gameState = G4_GAME_PLAYING;
        _gameManager._currentPlayerId = _gameManager._realMasterId;
        _gameManager._firstOutPlayerId = -1;
        [self doShowWatcher:25.0f];
        if(_gameManager._currentPlayerId == _gameManager._selfId)
            [self doShowOutCardCmdPannel];
        else
            [self server_outCard];        
    }   
}

-(void)on_game_playing:(G4Packet *)packet
{
    switch (packet.packetId) {
        case G4_DDZ_OUT_CARD_INFO:
            [self on_game_playing_recv_card_out_info:packet];
            break;
        case G4_DDZ_GAME_OVER:
            [self on_game_playing_recv_game_over:packet];
            break;
        case G4_DDZ_TIME_OUT:
            [self on_game_playing_recv_time_out:packet];
            break;
        default:
            break;
    }
}

-(void)on_game_playing_recv_card_out_info:(G4Packet*)packet
{
    [_watcher hide];
    NSString* peerId = [packet get:G4_KEY_COMM_ID];
    NSNumber* playerId = [packet get:G4_DDZ_KEY_ID];
    G4CharArray* cardArray = [packet get:G4_DDZ_KEY_CARD];
    G4GamePlayer* sendPlayer = nil;
    if(peerId != nil)
        sendPlayer = [_gameManager findGamePlayer:peerId];
    else
        sendPlayer = [_gameManager getGamePlayer:_gameManager._selfId];
#ifdef G4_LOGING_INFO
    NSLog(@"when playing game recv card out info from peer:%@,send playerId=%d,cardCount=%d,outplayerId=%d", peerId, sendPlayer._playerId, cardArray == nil?0:[cardArray count], playerId.charValue);
#endif
    if(playerId.charValue != _gameManager._currentPlayerId)
        _gameManager._currentPlayerId = playerId.charValue;
    
    G4GamePlayer* outPlayer = [_gameManager getGamePlayer:playerId.charValue];
    if(cardArray == nil)
        [outPlayer showFloatInfo:out_card_info :0];
    else
    {
        [outPlayer showOutedCard:NO];
        [outPlayer moveCardToOutedCard:cardArray];
        [outPlayer showOutedCard:YES];
        if(playerId.charValue == _gameManager._selfId)
            [_gameManager rmvCards:cardArray];
        [_gameManager setOutedCard:packet];
        _gameManager._lastOutPlayerId = _gameManager._currentPlayerId;
        if(_gameManager._firstOutPlayerId < 0)
            _gameManager._firstOutPlayerId = _gameManager._currentPlayerId;
        [outPlayer resetCardCount];
    }
    if([outPlayer countOfCard] == 0)
    {
#ifdef G4_LOGING_DEBUG
        NSLog(@"out player card count is zero\n");
#endif
        [self server_cardOuted];
        return;
    }
    [_gameManager nextPlayer];
    [[_gameManager getGamePlayer:_gameManager._currentPlayerId] showOutedCard:NO];
#ifdef G4_LOGING_DEBUG
    NSLog(@"when waiting next player out card,next player=%d,lastoutplayer=%d\n", _gameManager._currentPlayerId, _gameManager._lastOutPlayerId);
#endif
    if(_gameManager._currentPlayerId == _gameManager._lastOutPlayerId)
    {
        [_gameManager resetOutedCard];
        _gameManager._firstOutPlayerId = -1;
        _gameManager._lastOutPlayerId = -1;
        for(int i = 0; i < [_gameManager countOfPlayer]; i++)
        {
            G4GamePlayer* player = [_gameManager getGamePlayer:i];
            [player hideFloatInfo];
            [player showOutedCard:NO];
        }
    }
    [self doShowWatcher:15.0f];
    if(_gameManager._currentPlayerId == _gameManager._selfId)
    {
        [self doShowOutCardCmdPannel];
        return;
    }
    [self server_outCard];
}

-(void)on_game_playing_recv_game_over:(G4Packet*)packet
{
    NSNumber* winner = [packet get:G4_DDZ_KEY_WINNER];
    NSNumber* masterId = [packet get:G4_DDZ_KEY_ID];
#ifdef G4_LOGING_INFO
    NSLog(@"when playing game recve gameover,currentPlayerId=%d,winner=%d,servermasterId=%d,myMasterId=%d,state changed to G4_GAME_WAITING_CARD\n",
          _gameManager._currentPlayerId, winner.charValue, masterId.charValue, _gameManager._realMasterId);
#endif
    [_watcher hide];
    _gameManager._realMasterId = masterId.charValue;
    [_gameManager roundResult:winner.charValue];
    [_gameManager reset];
    _gameManager._roundCount ++;
    _gameState = G4_GAME_WAITING_PLAYERS_READY;
    [_resultLayer show:YES :15.0f];
    [_adLayer showAd:YES];
}

-(void)on_game_playing_recv_time_out:(G4Packet*)packet
{
    
}

-(void)doAppStart
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"Do App Start,init app\n");
#endif
    if(_deckCard == nil)
        _deckCard = [[G4DeckCard alloc] init:2];
    [_deckCard shuffle];
    
    [self initWatcher];
    [self initCmdPannel];
    _gameManager = [[G4GameManager alloc] init];
    
    _resultLayer = [[G4ResultLayer alloc] initWithSuperLayer:self.view.layer :_gameManager];
    _resultLayer.deleate = self;
     
    [_gameManager addGamePlayer:nil playerName:_displayName randomId:random_player_random_id() isSelf:YES computerPlayer:NO];
    
    _adLayer = [[G4AdLayer alloc] init:self.view.layer];
    
    [self initNetworker];
#ifdef G4_LOGING_DEBUG
    NSLog(@"SEND AppStart to self\n");
#endif    
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_APP_STARTED];
    [_comm sendPacketToSelf:packet];
    [packet release];
}

-(void)doShowPlayResult
{
    
}

-(void)doSendPlayerInfo:(NSString*)peerId name:(NSString*)name randomId:(int)randomId computerFlag:(char)computerFlag
{
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_PLAYER_INFO];
    [packet put:G4_DDZ_KEY_NAME :name];
    [packet put:G4_DDZ_KEY_ID : [NSNumber numberWithInt:randomId]];
    [packet put:G4_DDZ_KEY_FLAG :[NSNumber numberWithChar:computerFlag]];
    if(peerId == nil)
        [_comm sendPacketToAllPeers:packet];
    else
        [_comm sendPacketToPeer:peerId packet:packet];
    [packet release];
#ifdef G4_LOGING_INFO
    NSLog(@"SEND PlayerInfo to %@,Name=%@,id=%d,computerFlag=%d\n",
          peerId == nil?@"all peers":peerId, name, randomId, computerFlag);
#endif
}

-(void)doAddAComputerPlayer
{
    if(!_waitingLayer || ![_gameManager isServer])
        return;
    char buffer[10];
    memset(buffer, 0, 10);
    char xx[2] = {'A','a'};
    for(int i = 0; i < 6; i++)
        buffer[i] = xx[rand() % 2] + rand() % 26;
    NSString* name = [NSString stringWithFormat:@"%s", buffer];
    int randomId = random_player_random_id();
#ifdef G4_LOGING_DEBUG
    NSLog(@"Do add a computerPlayer,name=%@,randomId=%d\n",
          name, randomId);
#endif
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_PLAYER_INFO];
    [packet put:G4_DDZ_KEY_NAME :name];
    [packet put:G4_DDZ_KEY_ID : [NSNumber numberWithInt:randomId]];
    [packet put:G4_DDZ_KEY_FLAG :[NSNumber numberWithChar:1]];
    [_comm sendPacketToAllInclueSelf:packet];    
}

-(void)doShowWatcherOnCenter:(float)interval
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"Do ShowWatcherOnCenter %.2f\n", interval);
#endif
    [_watcher show:interval atPoint:CGPointMake(([G4CardSize deviceViewSize].width - [G4CardSize watcherSize] ) / 2, ([G4CardSize deviceViewSize].height - [G4CardSize watcherSize]) / 2)];
}

-(void)doSendComputerPlayerToPlayer:(NSString*)peerId
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"Do SendComputerPlayer to Player peer %@\n", peerId);
#endif
    for(char i = 0; i < [_gameManager countOfPlayer]; i++)
    {
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        if(player._computerPlayer)
        {
            [self doSendPlayerInfo:peerId name:[player getPlayerName] randomId:player._randomId computerFlag:1];
        }
    }
}

-(void)doSendPlayerReady
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"SEND PlayerReady to all other players and self\n");
#endif
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_PLAYER_READY];
    [packet put:G4_DDZ_KEY_ID:[NSNumber numberWithChar:_gameManager._selfId]];
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)doSendCardDealed
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"SEND CardDealed to all peers and self\n");
#endif
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_CARD_DEALED];
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)doShowQDZCmdPannel
{
    [self doShowWatcher:15.0f];
    
    char enabled[5] = {1, 1, 1, 1, 1};
    char score = [self doCalcCurrentPlayerQDZScore];
    for(char i = 0; i < score || i < _gameManager._currentScore + 1; i++)
        enabled[i] = 0;
    if(score != _gameManager._currentScore)
    {
        enabled[0] = 0;
        enabled[4] = 0;
    }
    
    [_cmdPannel showCmdQDZ:enabled];
}

-(void)doEnableOutCardCmdButton
{
    CARD_ANALYZE_DATA data;
    data._selectedCount = [_gameManager getSelectedCard:data._cardSelected];
    [_gameManager copyOutedCard:&data];
    [G4DDZRuler analyzeCard:&data];
    if(data.result._analyzeResult == CARD_INVALID)
        [_cmdPannel enableOutCardButton:NO];
    else
        [_cmdPannel enableOutCardButton:YES];
}

-(void)doShowOutCardCmdPannel
{
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    [player showOutedCard:NO];

    [_cmdPannel showCmdOutCard];
    [self doEnableOutCardCmdButton];
}

-(void)doShowWatcher:(float)interval
{
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    char direction = [player getGroupDirection];
    CGPoint point = [G4CardSize playerWatcherPoint:direction];
#ifndef G4_LOGING_DEBUG
    NSLog(@"Show WaitingPlayer,CurrentPlayerId=%d,GroupDirect=%d,Point=(%.2f,%.2f)\n",
          _gameManager._currentPlayerId, direction, point.x, point.y);
#endif
    [_watcher show:interval atPoint:point];
}

-(void)doSendQDZInfo:(char)score
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"SEND QDZInfo,PlayerId=%d,Score=%d\n", _gameManager._currentPlayerId, score);
#endif
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_QDZ_INFO];
    [packet put:G4_DDZ_KEY_ID :[NSNumber numberWithChar:_gameManager._currentPlayerId]];
    [packet put:G4_DDZ_KEY_SCORE :[NSNumber numberWithChar:score]];
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)doShowQDZInfo:(char)score
{
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
#ifdef G4_LOGING_DEBUG
    NSLog(@"Show Player QDZ info %d-%@-%@\n", _gameManager._currentPlayerId, [player getPlayerName], [player getPeerId]);
#endif
    [player showFloatInfo:qdz_info[score] :0];
}

-(void)doClearAllFloatInfo
{
    for(char i = 0; i < 4; i++)
    {
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        [player hideFloatInfo];
    }
}

-(void)doShowDZInfo
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"SEND ReadyForPlay to all include self\n");
#endif
    if(_gameManager._realMasterId != _gameManager._selfId)
    {
        G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_READY_FOR_PLAY];
        [packet put:G4_DDZ_KEY_ID :[NSNumber numberWithChar:_gameManager._selfId]];
        [_comm sendPacketToAllInclueSelf:packet];
        [packet release];
    }
}

-(void)doShowWaitingPlayerWatcher:(float)timeInterval
{
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    char direction = [player getGroupDirection];
    CGPoint point = [G4CardSize playerWatcherPoint:direction];
    [_watcher show:timeInterval atPoint:point];
}

-(char)doCalcCurrentPlayerQDZScore
{
    CARD_ANALYZE_DATA data;
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    for(char i = 0; i < 25; i++)
        data._cardTotal[i] = [player getCard:i];
    data._totalCount = 25;
    char score = [G4DDZRuler calcQDZScore:&data :_gameManager._currentScore];
    return score;
}

-(void)timeReached
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"watcher time reached,send timeout to self\n");
#endif
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_TIME_OUT];
    [_comm sendPacketToSelf:packet];
    [packet release];
}

-(void)onCmd:(char)cmdId
{
    if(_gameState == G4_GAME_DOING_QDZ)
    {
        [_watcher hide];
        [self doSendQDZInfo:cmdId];
    }
    else if(_gameState == G4_GAME_PLAYING)
    {
        if(cmdId == CMD_ID_RESELECT)
            [_gameManager unSelectAllCard];
        else if(cmdId == CMD_ID_OUT_CARD)
        {
            CARD_ANALYZE_DATA data;
            data._selectedCount = [_gameManager getSelectedCard:data._cardSelected];
            [_gameManager setSelfOutFromX];
            [self doSendOutCardInfo:&data playerId:_gameManager._selfId];
        }
        else if(cmdId == CMD_ID_NOT_OUT)
        {
            CARD_ANALYZE_DATA data;
            data._selectedCount = 0;
            [self doSendOutCardInfo:&data playerId:_gameManager._selfId];
        }
    }
}

-(void)doSendOutCardInfo:(CARD_ANALYZE_DATA*) data playerId:(char)playerId
{
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_OUT_CARD_INFO];
    if(data->_selectedCount != 0)
        [packet putCharArray:G4_DDZ_KEY_CARD :data->_cardSelected :data->_selectedCount];
    [packet put:G4_DDZ_KEY_ID : [NSNumber numberWithChar:playerId]];
    
#ifdef G4_LOGING_INFO
    NSLog(@"SEND outcardInfo to all peers include self,playerId=%d,cardCount=%d\n",
          playerId, data->_selectedCount);
#endif
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)resultHided
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"result hided,so send player ready to other players and self\n");
#endif
    [self doSendPlayerReady];
}
@end