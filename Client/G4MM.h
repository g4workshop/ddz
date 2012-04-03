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

@protocol G4MHandlerDelegate <NSObject>

-(void)handlePacket:(G4Packet*)packet;

@end

@interface G4MM : NSObject
{
@private
    NSThread* _thread;
    BOOL _stopped;
    G4Queue* _queue;
    NSCondition* _stopCondition;
    G4Network* _network;
    NSTimer* _timer;  //暂时用NSTimer代替，以后修改，只能设置一个timer
}

@property(nonatomic,assign)NSObject<G4MHandlerDelegate>* delegate;

-(id)init:(NSString*)gameName:(NSString*)playerName;
-(void)sendPacket:(NSString*)peerId:(G4Packet*)packet;
-(void)sendPacketToSelf:(G4Packet*)packet;
-(void)sendPacketToAllPeers:(G4Packet*)packet;
-(void)sendPacketToAll:(G4Packet*)packet;
-(void)dealloc;
-(void)start;
-(void)startNetwork;
-(void)stop;
-(void)stopNetwork;
-(void)doWork;
-(void)startTimer:(G4Packet*)packet:(float)timerInterval;
-(void)stopTimer;
-(void)timerReached;

@end
