//
//  G4GameServer.m
//  DDZ
//
//  Created by gyf on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GameServer.h"
#import "G4GameFSM.h"

@implementation G4ViewController(G4GameServer)

-(void)serverChanged:(char)oldServer newServer:(char)newServer
{
    if(_gameState == G4_GAME_WAITING_PLAYERS)
        [self doSendComputerPlayerToPlayer:[[_gameManager getGamePlayer:_gameManager._serverId] getPeerId]];
    else if(_gameState == G4_GAME_DOING_QDZ)
        [self server_QDZ];
    else if(_gameState == G4_GAME_PLAYING)
        [self server_outCard];
}

-(void)server_playerAdded:(NSString*)peerId
{
    if(_gameState == G4_GAME_WAITING_PLAYERS && [_gameManager isServer])
        [self doSendComputerPlayerToPlayer:peerId];
}

-(void)server_dealCard
{
    if(![_gameManager isServer])
        return;
    
    //发牌
    if(_deckCard == nil)
        _deckCard = [[G4DeckCard alloc] init:2];
    [_deckCard shuffle];
    
    G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_CARD_INFO];
    
    NSData* data = [NSData dataWithBytesNoCopy:[_deckCard getCardNumber] length:[_deckCard getCount]];
    [packet put:G4_DDZ_KEY_CARD :data];
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)server_QDZ
{
    if(![_gameManager isServer])
        return;
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    if(![player needServerPlay])
        return;
    [self autoQDZ];
}

-(void)server_outCard
{
    if(_gameState != G4_GAME_PLAYING || ![_gameManager isServer])
        return;
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];

    if([player needServerPlay])
        [self autoOutCard];
}

-(void)server_cardOuted
{
    if(_gameState != G4_GAME_PLAYING || ![_gameManager isServer])
        return;
    for(char i = 0; i < [_gameManager countOfPlayer]; i++)
    {
        G4GamePlayer* player = [_gameManager getGamePlayer:i];
        if([player countOfCard] == 0)
        {
#ifdef G4_LOGING_DEBUG
            NSLog(@"player %d card count is zero,game over,masterId=%d\n",
                  i, _gameManager._realMasterId);
#endif
            G4Packet* packet = [[G4Packet alloc] initWith:G4_DDZ_GAME_OVER];
            [packet put:G4_DDZ_KEY_WINNER :[NSNumber numberWithChar:i]];
            [packet put:G4_DDZ_KEY_ID :[NSNumber numberWithChar:_gameManager._realMasterId]];
            [_comm sendPacketToAllInclueSelf:packet];
            [packet release];
        }
    }
}

-(void)autoQDZ
{
    char enabled[5] = {1, 1, 1, 1, 1};
    char score = [self doCalcCurrentPlayerQDZScore];
    for(char i = 0; i < score || i < _gameManager._currentScore + 1; i++)
        enabled[i] = 0;
    if(score != _gameManager._currentScore)
    {
        enabled[0] = 0;
        enabled[4] = 0;
    }
    if(enabled[4] != 0)
        [self doSendQDZInfo:4];
    else for(char i = 0; i < 4; i++)
    {
        if(enabled[i] != 0)
        {
            [self doSendQDZInfo:i];
            return;
        }
    }
}

-(void)autoOutCard
{
    CARD_ANALYZE_DATA data;
    data._selectedCount = 0;
    [self doSendOutCardInfo:&data playerId:_gameManager._currentPlayerId];
}

@end
