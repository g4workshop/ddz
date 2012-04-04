//
//  G4GamePlayer.m
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GamePlayer.h"
#import "G4CardSize.h"
#import "G4GameFSM.h"

@implementation G4GamePlayer

@synthesize _autoPlay;
@synthesize _score;
@synthesize _computerPlayer;
@synthesize _randomId;
@synthesize _isSelf;
@synthesize _networkState;
@synthesize _playerId;
@synthesize _playerState;
@synthesize _roundScore;
@synthesize _totalScore;
@synthesize _timeOutCount;

-(id)initWithPeerId:(NSString*)peerId playerName:(NSString*)playerName randomId:(int)randomId isSelf:(BOOL)isSelf computerPlayer:(BOOL)computerPlayer
{
    if(self = [super init])
    {
        _cardArray = [[NSMutableArray alloc] init];
        _autoPlay = NO;
        _score = -1;
        _computerPlayer = computerPlayer;
        _randomId = randomId;
        _isSelf = isSelf;
        if(peerId)
            _peerId = [peerId retain];
        _networkState = NET_STATUS_ALIVE;
        _playerName = [playerName retain];
        _playerState = PLAYER_STATE_WAITING;
        _totalScore = 0;
        _roundScore = 0;
        self._timeOutCount = 0;
    }
    return self;
}


-(void)initOutedGroup:(CALayer*)superLayer:(char)direction:(CGRect)frame
{
    _outedCardGroup = [[G4OutedCardGroup alloc] initWith:superLayer :direction :frame];
}

-(void)initPlayerInfo:(CALayer*)superLayer:(CGPoint)point
{
    _playerInfoLayer = [[G4PlayerInfoLayer alloc] init:superLayer :point];
}

-(void)setCardCenterX:(float)x
{
    _outedCardGroup.cardCenterX = x;
}

-(void)initFloatInfo:(CALayer*)superLayer:(CGRect)frame
{
    _floatInfoLayer = [[G4FloatInfoLayer alloc] init:superLayer:frame];
}

-(void)dealloc
{
    [_peerId release];
    [_outedCardGroup release];
    [_playerInfoLayer release];
    [_cardArray release];
    [_playerName release];
    [super dealloc];
}

-(BOOL)isEqualToPeer:(NSString *)peerId
{
    return [_peerId isEqualToString:peerId];
}

-(BOOL)isEqualToName:(NSString*)name andRandomId:(int)randomId
{
    return ([name isEqualToString:_playerName] && randomId == _randomId);
}

-(void)resetCardCount;
{
    [_playerInfoLayer setCardCount:[_cardArray count]];
}

-(void)showPlayerInfo:(BOOL)show
{
    if(show)
        [_playerInfoLayer setPlayerName:_playerName:_playerId];
    [_playerInfoLayer show:show];
}

-(void)showOutedCard:(BOOL)show
{
    [_outedCardGroup showGroup:show];
}

-(void)addOutedCard:(char)cardNumber
{
    [_outedCardGroup addCard:cardNumber];
}

-(void)moveCardToOutedCard:(G4CharArray*) cardArray
{
    for(char i = 0; i < [cardArray count]; i++)
    {
        [self rmvCard:[cardArray get:i]];
        [self addOutedCard:[cardArray get:i]];
    }
}

-(void)clearAllCards
{
    [_cardArray removeAllObjects];
}

-(void)addCard:(char)cardNumber
{
    [_cardArray addObject:[NSNumber numberWithChar:cardNumber]]; 
}

-(void)rmvCard:(char)cardNumber
{
    for(NSNumber* number in _cardArray)
    {
        if(number.charValue == cardNumber)
        {
            [_cardArray removeObject:number];
            break;
        }
    }
}

-(void)showFloatInfo:(NSString*)showInfo:(float)maxTime
{
    [_floatInfoLayer showInfo:showInfo :maxTime];
}

-(void)hideFloatInfo
{
    [_floatInfoLayer hideInfo];
}

-(int)countOfCard
{
    return [_cardArray count];
}

-(char)getCard:(char)index
{
    return ((NSNumber*)[_cardArray objectAtIndex:index]).charValue;
}

-(char)getGroupDirection
{
    return _outedCardGroup.groupDirection;
}

-(int)compareWith:(G4GamePlayer*)player
{
    if(_randomId > player._randomId)
        return 1;
    else if(_randomId < player._randomId)
        return -1;
    else return [_playerName compare:player->_playerName];
}

-(NSString*)getPlayerName
{
    return _playerName;
}

-(NSString*)getPeerId
{
    return _peerId;
}

-(BOOL)needServerPlay
{
    return (self._computerPlayer || self._networkState != NET_STATUS_ALIVE);
}

@end

@implementation G4GameManager

@synthesize _selfId;
@synthesize _realMasterId;
@synthesize _firstMasterId;
@synthesize _currentPlayerId;
@synthesize _serverId;
@synthesize _delegate;
@synthesize _currentScore;
@synthesize _firstOutPlayerId;
@synthesize _lastOutPlayerId;
@synthesize _roundCount;


-(id)init
{
    if(self =  [super init])
    {
        _playerArray = [[NSMutableArray alloc] init];
        _dzCardArray = [[G4CharArray alloc] init];
        self._roundCount = 0;
    }
    return self;
}

-(void)dealloc
{
    [_playerArray release];
    [_dzCardArray release];
    [_cardGroup release];
    [_lastOutedCard release];
}
-(BOOL)isPlayerExists:(NSString*)name andRandomId:(int)randomId;
{
    char pos = 0;
    for(; pos < [self countOfPlayer]; pos++)
    {
        G4GamePlayer* tmp = [_playerArray objectAtIndex:pos];
        if([tmp isEqualToName:name andRandomId:randomId] && tmp._computerPlayer)
            return YES;
    }
    return NO;
}

-(char)addGamePlayer:(NSString*)peerId playerName:(NSString*)playerName randomId:(int)randomId isSelf:(BOOL)isSelf computerPlayer:(BOOL)computerPlayer
{
    if(computerPlayer && [self isPlayerExists:playerName andRandomId:randomId])
        return [self countOfPlayer];
    G4GamePlayer* player = [[G4GamePlayer alloc] initWithPeerId:peerId playerName:playerName randomId:randomId isSelf:isSelf computerPlayer:computerPlayer];
    char pos = 0;
    for(; pos < [self countOfPlayer]; pos++)
    {
        G4GamePlayer* tmp = [_playerArray objectAtIndex:pos];
        if([tmp compareWith:player] > 0)
            break;
    }
    if(pos == [self countOfPlayer])
        [_playerArray addObject:player];
    else
        [_playerArray insertObject:player atIndex:pos];
    [player release];
    [self resetServerId];
    [self resetSelfId];
    [self resetPlayerId];
    return [self countOfPlayer];
}

-(void)rmvGamePlayer:(NSString*)peerId
{
    for(G4GamePlayer* player in _playerArray)
    {
        if([player isEqualToPeer:peerId])
        {
            [_playerArray removeObject:player];
            break;
        }
    }
    [self resetServerId];
    [self resetSelfId];
    [self resetPlayerId];
}

-(void)resetPlayerId
{
    for(char i = 0; i < [self countOfPlayer]; i++)
        [self getGamePlayer:i]._playerId = i;
}

-(G4GamePlayer*)getGamePlayer:(char)index
{
    return (G4GamePlayer*)[_playerArray objectAtIndex:index];
}

-(G4GamePlayer*)findGamePlayer:(NSString*)peerId
{
    for(G4GamePlayer* player in _playerArray)
    {
        if(!player._computerPlayer && [player isEqualToPeer:peerId])
            return player;
    }
    return nil;
}

-(char)countOfPlayer
{
    return (char)[_playerArray count];
}

-(void)nextPlayer
{
    _currentPlayerId ++;
    if(_currentPlayerId >= 4)
        _currentPlayerId = 0;
}

-(void)resetServerId
{
    char _oldServerId = _serverId;
    for(char i = 0; i < [self countOfPlayer]; i++)
    {
        G4GamePlayer* player = (G4GamePlayer*)[_playerArray objectAtIndex:i];
        if(!player._computerPlayer && player._networkState == NET_STATUS_ALIVE)
        {
            _serverId = i;
            break;
        }
    }
    if(_oldServerId == _selfId && _oldServerId != _serverId)
        [_delegate serverChanged:_oldServerId newServer:_serverId];
}

-(void)resetSelfId
{
    for(char i = 0; i < [self countOfPlayer]; i++)
    {
        G4GamePlayer* player = (G4GamePlayer*)[_playerArray objectAtIndex:i];
        if(player._isSelf)
        {
            _selfId = i;
            break;
        }
    }
}

-(BOOL)isServer
{
    return (_selfId == _serverId);
}

-(char)getNotComputerPlayersCount
{
    char count = 0;
    for(G4GamePlayer* player in _playerArray)
    {
        if(!player._computerPlayer && !player._isSelf)
            count++;
    }
    return count;
}

-(void)initCardGroup:(CALayer*)superLayer:(id)delegate
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"InitCardGroup....\n");
#endif
    float x = [G4CardSize edgeSpace];
    float y = [G4CardSize deviceViewSize].height - [G4CardSize edgeSpace] - [G4CardSize cardHeight];
    CGRect groupFrame = CGRectMake(x, y, [G4CardSize deviceViewSize].width - 2 * [G4CardSize edgeSpace], [G4CardSize cardHeight]);
    _cardGroup = [[G4CardGroup alloc] initWithSuperLayer:superLayer andFrame:groupFrame];
    _cardGroup.delegate = delegate;
}

-(void)initPlayerParameter:(CALayer*)superLayer
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"Init Player Parameter selfId=%d,serverId=%d....\n", _selfId, _serverId);
#endif
    CGRect outedCardRect[] = {[G4CardSize selfOutGroupRect], [G4CardSize rightOutGroupRect], [G4CardSize upOutGroupRect], [G4CardSize leftOutGroupRect]};
    CGPoint infoPosition[] = {[G4CardSize selfBoardPosition], [G4CardSize rightBoardPosition], [G4CardSize upBoardPosition], [G4CardSize leftBoardPosition]};
    char direction[] = {GROUP_DIRECTION_ME,GROUP_DIRECTION_RIGHT,GROUP_DIRECTION_UP,GROUP_DIRECTION_LEFT};
    
    CGRect floatInfoRect[] = {[G4CardSize selfFloatRect],[G4CardSize rightFloatRect], [G4CardSize upFloatRect], [G4CardSize leftFloatRect]};
       
    for(char i = 0; i < [self countOfPlayer]; i++)
    {
        char d;
        for(char j = 0; j < 4; j++)
        {
            if((_selfId + j) % 4 == i)
            {
                d = j;
                break;
            }
        }
        G4GamePlayer* player = [self getGamePlayer:i];
        [player initOutedGroup:superLayer :direction[d] :outedCardRect[d]];
        [player initPlayerInfo:superLayer :infoPosition[d]];
        [player initFloatInfo:superLayer :floatInfoRect[d]];
    }
}

-(void)hideCardGroup
{
    [_cardGroup hide];
}

-(void)putDZCard:(G4CharArray*)cardArray
{
    [_dzCardArray reset];
    for(char i = 100; i < [cardArray count]; i++)
        [_dzCardArray put:[cardArray get:i]];
}

-(void)moveDZCard
{
    G4GamePlayer* player = [self getGamePlayer:self._realMasterId];
    for(char i = 0; i < [_dzCardArray count]; i++)
    {
        if(self._realMasterId == self._selfId)
            [_cardGroup addPokerCard:[_dzCardArray get:i]];
        [player addCard:[_dzCardArray get:i]];
    }
}

-(void)moveCardToGroup
{
    [_cardGroup hide];
    G4GamePlayer* player = [self getGamePlayer:_selfId];
    for(char i = 0; i < [player countOfCard]; i++)
        [_cardGroup addPokerCard:[player getCard:i]];
}

-(void)dealCard:(char)fromIndex
{
    [_cardGroup show:fromIndex :YES];
}

-(char)getSelectedCard:(char*)cardNumbers
{
    return [_cardGroup getSelectedCard:cardNumbers];
}

-(void)unSelectAllCard
{
    [_cardGroup unSelectAllCard];
}

-(void)cardSwitchSelect:(CGPoint)pt
{
    return [_cardGroup cardSwitchSelect:pt];
}

-(void)rmvCards:(G4CharArray*) cardArray
{
    for(char i = 0; i < [cardArray count]; i++)
        [_cardGroup rmvPokerCard:[cardArray get:i]];
    [_cardGroup layoutCardsNeedCalcNewCardShowWidth];
}

-(void)reset
{
    [_cardGroup hide];
    [_dzCardArray reset];
    for(char i = 0; i < [_playerArray count]; i++)
    {
        G4GamePlayer* player = [_playerArray objectAtIndex:i];
        [player clearAllCards];
        [player resetCardCount];
        [player hideFloatInfo];
        [player showOutedCard:NO];
        player._playerState = PLAYER_STATE_READY;
        player._autoPlay = NO;
        player._timeOutCount = 0;
    }
    self._realMasterId = -1;
    self._firstMasterId = -1;
    self._currentScore = 0;
    self._currentPlayerId = -1;
    self._firstOutPlayerId = -1;
    self._lastOutPlayerId = -1;
    [_lastOutedCard release];
    _lastOutedCard = nil;
}

-(void)resetPlayRecord
{
    self._roundCount = 0;
    for(char i = 0; i < [_playerArray count]; i++)
    {
        G4GamePlayer* player = [_playerArray objectAtIndex:i];
        player._roundScore = 0;
        player._totalScore = 0;
    }    
}

-(void)roundResult:(char)winner
{
    short dzScore;
    if(winner == self._realMasterId)
        dzScore = self._currentScore + 1;
    else
        dzScore = -self._currentScore - 1;
    for(char i = 0; i < [_playerArray count]; i++)
    {
        G4GamePlayer* player = [_playerArray objectAtIndex:i];
        if(i == self._realMasterId)
            player._roundScore = dzScore * 3;
        else
            player._roundScore = -dzScore;
        player._totalScore += player._roundScore;
    }
}

-(void)setSelfOutFromX
{
    G4GamePlayer* player = [_playerArray objectAtIndex:self._selfId];
    [player setCardCenterX:[_cardGroup getFirstSelectX]];
}

-(BOOL)cardGroupYInvalid:(float)y
{
    return [_cardGroup yInvalid:y];
}

-(void)selectCard:(BOOL)select fromIndex:(char)fromIndex toIndex:(char)toIndex
{
    return [_cardGroup selectCard:select fromIndex:fromIndex toIndex:toIndex];
}

-(char)indexOfCardByX:(float)x
{
    return [_cardGroup indexOfCardByX:x];
}

-(void)setOutedCard:(G4Packet*)packet
{
    if(_lastOutedCard != nil)
        [_lastOutedCard release];
    _lastOutedCard = [[packet get:G4_DDZ_KEY_CARD] retain];
}

-(void)resetOutedCard
{
    [_lastOutedCard release];
    _lastOutedCard = nil;
}

-(void)copyOutedCard:(CARD_ANALYZE_DATA*)data
{
    if(_lastOutedCard == nil)
        data->_outedCount = 0;
    else
    {
        data->_outedCount = [_lastOutedCard count];
        for(int i = 0; i < data->_outedCount; i++)
            data->_cardOuted[i] = [_lastOutedCard get:i];
    }
}

-(BOOL)isAllPlayerStateOf:(char)state
{
    for(G4GamePlayer* player in _playerArray)
    {
        NSLog(@"player:%@ computerFlag:%d,playerState:%d,state:%d\n",
              [player getPlayerName], player._computerPlayer, player._playerState, state);
        if(!player._computerPlayer && player._playerState != state)
            return NO;
    }
    return YES;
}

-(void)gamePlayerDisconnected:(char)playerId
{
    G4GamePlayer* player = [self getGamePlayer:playerId];
    player._playerState = NET_STATUS_DISCONNECTED;
    [self resetServerId];
}

-(void)rmvDisconnectedPlayer
{
    NSMutableArray* rmvedArray = [[NSMutableArray alloc] init];
    for(G4GamePlayer* player in _playerArray)
    {
        if(!player._computerPlayer && player._networkState != NET_STATUS_ALIVE)
            [rmvedArray addObject:player];
    }
    [_playerArray removeObjectsInArray:rmvedArray];
    [rmvedArray release];
}
@end
