//
//  G4PokerServer.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4DeckCard.h"
#import "G4PokerPlayer.h"

@interface G4PokerServer : NSObject
{
@private
    G4DeckCard* _deckCard;
    G4PokerPlayer* _pockerPlayer[4];
    char _master;  //地主
    NSThread* thread;
    BOOL stopped;
    SEL selfPacketSelector;
    G4Queue* queue;
    NSCondition* condition;
    id owner;
}

-(id)init:(id)o:(SEL)selector;
-(void)start;
-(void)stop;
-(void)deal;
-(void)dealCardToPlayer:(char)player_id;
-(void)dealloc;
-(void)doWork;
-(void)handlePacket:(G4Packet*)packet;
-(void)putPacket:(G4Packet*)packet;

@end
