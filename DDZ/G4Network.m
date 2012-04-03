//
//  ZXNetwork.m
//  Upgrade
//
//  Created by gyf on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Network.h"

@implementation G4Network

-(void)createSession:(NSString*)displayName
{
    mySession = [[GKSession alloc] initWithSessionID:@"Upgrade"  displayName:@"Phone" sessionMode:GKSessionModePeer];
    mySession.delegate = self;
    [mySession setDataReceiveHandler:self withContext:nil];
    NSLog(@"create session");
    mySession.available = YES;
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState) state
{
    switch (state)
	{
		case GKPeerStateAvailable:
			NSLog(@"didChangeState: peer %@ available", [session displayNameForPeer:peerID]);
            
            [NSThread sleepForTimeInterval:0.5];
            
			[session connectToPeer:peerID withTimeout:5];
			break;
            
		case GKPeerStateUnavailable:
			NSLog(@"didChangeState: peer %@ unavailable", [session displayNameForPeer:peerID]);
			break;
            
		case GKPeerStateConnected:
			NSLog(@"didChangeState: peer %@ connected", [session displayNameForPeer:peerID]);
            char t[200];
            memset(t, 0, 200);
            strcpy(t, "my test 测试");
            NSData* data = [NSData dataWithBytes:t length:strlen(t) + 1];
            [session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
			break;
            
		case GKPeerStateDisconnected:
			NSLog(@"didChangeState: peer %@ disconnected", [session displayNameForPeer:peerID]);
			break;
            
		case GKPeerStateConnecting:
			NSLog(@"didChangeState: peer %@ connecting", [session displayNameForPeer:peerID]);
			break;
	}
}

-(void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSString* s = [[NSString alloc] initWithUTF8String:[data bytes]];
    NSLog(@"recved:%@", s);
    [s release];
}

-(void)sendData:(NSData*)data
{
    
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"receive connection request:%@", peerID);
    [session acceptConnectionFromPeer:peerID error:nil];
 
}

-(void)dealloc
{
    mySession.available = NO;
    mySession.delegate = nil;
    [mySession disconnectFromAllPeers];
    [mySession release];
}

@end
