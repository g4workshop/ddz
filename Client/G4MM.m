//
//  G4MHandler.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4MM.h"

@implementation G4MM

@synthesize delegate;

-(id)init:(NSString*)gameName:(NSString*)playerName
{
    if(self = [super init])
    {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doWork) object:nil];
        _queue = [[G4Queue alloc] init];
        _stopCondition = [[NSCondition alloc] init];
        _network = [[G4Network alloc] init:gameName:playerName:_queue];
    }
    return self;
}

-(void)sendPacket:(NSString*)peerId:(G4Packet*)packet
{
    [_network sendPacket:peerId :packet];
}

-(void)sendPacketToAllPeers:(G4Packet*)packet
{
    [_network sendPacketToAll:packet];
}

-(void)sendPacketToAll:(G4Packet*)packet
{
    [_network sendPacketToAll:packet];
    [self sendPacketToSelf:packet];
}

-(void)sendPacketToSelf:(G4Packet*)packet
{
    [_queue put:packet];
}

-(void)dealloc
{
    [_thread release];
    [_queue release];
    [_stopCondition release];
    [_network release];
    [_timer invalidate];
}

-(void)start
{
    _stopped = NO;
    [_thread start];
}

-(void)stop
{
    _stopped = YES;
    [_stopCondition lock];
    [_stopCondition wait];
}

-(void)startNetwork
{
    [_network start];
}

-(void)stopNetwork
{
    [_network stop];
}

-(void)doWork
{
    G4Packet* packet;
    while(!_stopped)
    {
        packet = [[_queue get] retain];
        if(_stopped)
        {
            [_stopCondition lock];
            [_stopCondition signal];
            break;
        }
        [delegate performSelectorOnMainThread:@selector(handlePacket:) withObject:packet waitUntilDone:YES];
        [packet release];
    }
}

-(void)startTimer:(G4Packet*)packet:(float)timerInterval
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(timerReached) userInfo:packet repeats:NO];
}
              
-(void)timerReached
{
    [_queue put:[_timer userInfo]];
    _timer = nil;
}

-(void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}
@end
