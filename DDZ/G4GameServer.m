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
    
    [packet putCharArray:G4_DDZ_KEY_CARD :[_deckCard getCardNumber] : [_deckCard getCount]];
    [_comm sendPacketToAllInclueSelf:packet];
    [packet release];
}

-(void)server_QDZ
{
    if(![_gameManager isServer])
        return;
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    if(!player._computerPlayer)
        return;
    [self doSendQDZInfo:4];
}

-(void)server_outCard
{
    if(_gameState != G4_GAME_PLAYING || ![_gameManager isServer])
        return;
    G4GamePlayer* player = [_gameManager getGamePlayer:_gameManager._currentPlayerId];
    CARD_ANALYZE_DATA data;
    data._selectedCount = 0;
    if(player._computerPlayer)
    {
#ifdef G4_LOGING_DEBUG
        NSLog(@"next player %d is computer player,so send out card info\n",
              _gameManager._currentPlayerId);
#endif
        [self doSendOutCardInfo:&data playerId:_gameManager._currentPlayerId];
    }
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
@end
