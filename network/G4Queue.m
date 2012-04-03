//
//  ZXQueue.m
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Queue.h"

@implementation G4Queue

-(id)init
{
    self = [super init];
    _packetArray = [[NSMutableArray alloc] init];
    _condition = [[NSCondition alloc] init];
    _topPacket = nil;
    return self;
}

-(void)put:(G4Packet*)packet
{
    [_condition lock];   
    [_packetArray addObject:packet];
    [_condition signal];
    [_condition unlock];
}

-(G4Packet*)get
{
    [_condition lock];
    if([_packetArray count] == 0)
        [_condition wait];

    if([_packetArray count] == 0)
        return nil;
    [_topPacket release];  
    _topPacket = [_packetArray objectAtIndex:0];
    [_topPacket retain];

    [_packetArray removeObjectAtIndex:0];
    [_condition unlock];

    return _topPacket;
}

-(void)dealloc
{
    [super dealloc];
    [_packetArray release];
    [_condition release];
    [_topPacket release];
}

@end
