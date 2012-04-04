//
//  G4MHandler.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Comm.h"

@implementation G4Timer

@synthesize _timerId;


-(void)start:(G4Packet*)packet interval:(float)interval :(id)target :(SEL)selector
{
    _packet = [packet retain];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:interval target:target  selector:selector userInfo:self repeats:NO] retain];
}

-(void)stop
{
    if([_timer isValid])
        [_timer invalidate];
}

-(void)dealloc
{
    [_timer release];
    [_packet release];
}

@end


@implementation G4Comm

@synthesize delegate;

-(id)init
{
    if(self = [super init])
    {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doWork) object:nil];
        _queue = [[G4Queue alloc] init];
        _stopCondition = [[NSCondition alloc] init];
        _stopped = YES;
        _timerArray = [[NSMutableArray alloc] init];
        _timerId = 10;
    }
    return self;
}

-(void)sendPacketToPeer:(NSString *)peerId packet:(G4Packet *)packet
{
    [_network sendPacketToPeer:peerId :packet];
}

-(void)sendPacketToAllPeers:(G4Packet*)packet
{
    [_network sendPacketToAllPeer:packet];
}

-(void)sendPacketToAllInclueSelf:(G4Packet *)packet
{
    [_network sendPacketToAllPeer:packet];
    [_queue put:packet];
}

-(void)sendPacketToSelf:(G4Packet*)packet
{
    [_queue put:packet];
}

-(void)dealloc
{
    [self stop];
    [self stopNetwork];
    [_thread release];
    [_queue release];
    [_stopCondition release];
    [_network release];
    [_timerArray release];
}

-(void)start
{
    _stopped = NO;
    [_thread start];
}

-(void)stop
{
    _stopped = YES;
    [self stopNetwork];
    [_stopCondition lock];
    [_stopCondition wait];
}

-(void)startNetwork:(NSString*)sessionId displayName:(NSString*)displayName linkType:(char)linkType autoConnect:(BOOL)autoConnect
{
    if(_stopped)
        [self start];
    _network = [[G4NetworkLocal alloc] init: sessionId:displayName :linkType :_queue];
    _network.autoConnect = autoConnect;
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

-(int)startTimer:(G4Packet*)packet:(float)timerInterval
{
    @synchronized(_timerArray)
    {
        _timerId++;
        G4Timer* timer = [[G4Timer alloc] init];
        timer._timerId = _timerId;
        [timer start:packet interval:timerInterval :self : @selector(timerReached:)];
        [_timerArray addObject:timer];
        [timer release];
        return _timerId;
    }
}
            
-(int)startTimer:(float)timerInterval
{
    G4Packet* packet = [[G4Packet alloc] initWith:G4_TIME_OUT];
    int ret = [self startTimer:packet :timerInterval];
    [packet release];
    return ret;
}

-(void)timerReached:(NSTimer*)theTimer
{
    G4Timer* timer = (G4Timer*)[theTimer userInfo];
    [_queue put:timer->_packet];
    @synchronized(_timerArray)
    {
        [_timerArray removeObject:timer];
    }
}


-(void)stopTimer:(int)timerId
{
    @synchronized(_timerArray)
    {
        for(G4Timer* timer in _timerArray)
        {
            if(timer._timerId == timerId)
            {
                [timer stop];
                [_timerArray removeObject:timer];
                return;
            }
        }
    }
}

-(void)connectTo:(NSString*)peerId
{
    [_network connectTo:peerId];
}
-(void)acceptConnect:(NSString*)peerId
{
    [_network acceptConnect:peerId];
}

@end
