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
    packetArray = [[NSMutableArray alloc] init];
    condition = [[NSCondition alloc] init];
    topPacket = nil;
    return self;
}

-(void)put:(G4Packet*)packet
{
    //@synchronized(packetArray)
    {
        [condition lock];
        [packetArray addObject:packet];
        [condition signal];
        [condition unlock];
    }
}

-(G4Packet*)get
{
    //@synchronized(packetArray)
    {
        [topPacket release];
        [condition lock];
        if([packetArray count] == 0)
            [condition wait];
        if([packetArray count] == 0)
            return nil;

        topPacket = [packetArray objectAtIndex:0];
        [topPacket retain];
        [packetArray removeObjectAtIndex:0];
        [condition unlock];
        return topPacket;
    }
}

-(void)dealloc
{
    [super dealloc];
    [packetArray release];
    [condition release];
}

@end
