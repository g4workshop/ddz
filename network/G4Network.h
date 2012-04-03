//
//  ZXNetwork.h
//  Upgrade
//
//  Created by gyf on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/Gamekit.h>
#import "G4Queue.h"

#define LINK_TYPE_OF_BT         0x00
#define LINK_TYPE_OF_WLAN        0x01
#define LINK_TYPE_GAME_CENTER   0x02

@interface G4NetworkLocal : NSObject<GKSessionDelegate,GKPeerPickerControllerDelegate>
{ 
@private
    GKSession* _gameSession;
    G4Queue* _queue;
    char _linkType;
    NSString* _sessionId;
    NSString* _displayName;
    GKPeerPickerController* _picker;
}

@property(nonatomic)BOOL autoConnect;

-(id)init:(NSString*)sessionId:(NSString*)displayName:(char)linkType:(G4Queue*)queue;
-(void)dealloc;

-(void)peerAvailable:(NSString*)peerId;
-(void)peerUnAvailable:(NSString*)peerId;

-(void)peerConnected:(NSString*)peerId;
-(void)peerDisconnected:(NSString*)peerId;

-(void)peerConnecting:(NSString*)peerId;

-(void)connectTo:(NSString*)peerId;
-(void)acceptConnect:(NSString*)peerId;

-(void)sendPacketToAllPeer:(G4Packet*)packet;
-(void)sendPacketToPeer:(NSString*)peerId:(G4Packet*)packet;
-(void)start;
-(void)stop;

-(void)putPacket:(int)packetId:(NSString*)peerId;

@end
