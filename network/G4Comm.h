//
//  G4MHandler.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4Queue.h"
#import "G4Network.h"
#import "G4Key.h"

@protocol G4MHandlerDelegate <NSObject>

-(void)handlePacket:(G4Packet*)packet;

@end

@interface G4Timer : NSObject {
@private
    NSTimer* _timer;
@public
    G4Packet* _packet;
}

@property(nonatomic)int _timerId;


-(void)start:(G4Packet*)packet interval:(float)interval :(id)target :(SEL)selector;
-(void)stop;
-(void)dealloc;

@end

@interface G4Comm : NSObject
{
@private
    NSThread* _thread;
    BOOL _stopped;
    G4Queue* _queue;
    NSCondition* _stopCondition;
    G4NetworkLocal* _network;
    NSMutableArray* _timerArray;
    int _timerId;
}

@property(nonatomic,assign)NSObject<G4MHandlerDelegate>* delegate;

-(id)init;
-(void)sendPacketToPeer:(NSString*)peerId packet:(G4Packet*)packet;
-(void)sendPacketToSelf:(G4Packet*)packet;
-(void)sendPacketToAllPeers:(G4Packet*)packet;
-(void)sendPacketToAllInclueSelf:(G4Packet*)packet;
-(void)dealloc;
-(void)start;
-(void)stop;
-(void)startNetwork:(NSString*)sessionId displayName:(NSString*)displayName linkType:(char)linkType autoConnect:(BOOL)autoConnect;
-(void)stopNetwork;
-(void)doWork;
-(int)startTimer:(G4Packet*)packet:(float)timerInterval;
-(int)startTimer:(float)timerInterval;
-(void)stopTimer:(int)timerId;
-(void)timerReached:(NSTimer*)theTimer;
-(void)connectTo:(NSString*)peerId;
-(void)acceptConnect:(NSString*)peerId;
@end
