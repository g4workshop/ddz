//
//  ZXQueue.h
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4Packet.h"

@interface G4Queue : NSObject
{
    NSMutableArray* packetArray; 
    NSCondition* condition;
    G4Packet* topPacket;
}

-(id)init;
-(void)put:(G4Packet*)packet;
-(G4Packet*)get;
-(void)dealloc;

@end
