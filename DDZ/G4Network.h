//
//  ZXNetwork.h
//  Upgrade
//
//  Created by gyf on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/Gamekit.h>

@interface G4Network : NSObject<GKSessionDelegate>
{
    GKSession* mySession;
}

-(void)createSession:(NSString*)displayName;
-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState) state;
-(void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;
-(void)sendData:(NSData*)data;
-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID;
-(void)dealloc;
@end
