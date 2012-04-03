//
//  ZXNetwork.m
//  Upgrade
//
//  Created by gyf on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Network.h"
#import "G4Key.h"

@implementation G4NetworkLocal

@synthesize autoConnect;

-(id)init:(NSString*)sessionId:(NSString*)displayName:(char)linkType:(G4Queue*)queue;
{
    self = [super init];
    _sessionId = [sessionId retain];
    _displayName = [displayName retain];
    _gameSession = [[GKSession alloc] initWithSessionID:sessionId  displayName:displayName sessionMode:GKSessionModePeer];
    _gameSession.delegate = self;
    [_gameSession setDataReceiveHandler:self withContext:nil];
    _queue = [queue retain];
    _linkType = linkType;

     return self;
}

-(void)start
{
    if(_linkType == LINK_TYPE_OF_BT)
    {
        _picker = [[GKPeerPickerController alloc] init];
        _picker.delegate = self;
        [_picker show];
    }
    else
        _gameSession.available = YES;
}

-(void)stop
{
    if(_linkType == LINK_TYPE_OF_BT)
    {
        if([_picker isVisible])
            [_picker dismiss];
    }
    else
        _gameSession.available = NO;
}

-(void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState) state
{
    switch (state)
	{
		case GKPeerStateAvailable:           
            [self peerAvailable:peerID];
			break;
            
		case GKPeerStateUnavailable:
            [self peerUnAvailable:peerID];
			break;
            
		case GKPeerStateConnected:
            [self peerConnected:peerID];
			break;
            
		case GKPeerStateDisconnected:
            [self peerDisconnected:peerID];
			break;
            
		case GKPeerStateConnecting:
            [self peerConnecting:peerID];
			break;
	}
}

-(void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    G4Packet* packet = [[G4Packet alloc] initWithData:data];
    [packet put:G4_KEY_COMM_ID :peer];
    [packet put:G4_KEY_COMM_NAME :[session displayNameForPeer:peer]];
    [_queue put:packet];
    [packet release];
}

-(void)sendPacketToAllPeer:(G4Packet*)packet
{
    NSData* data = [packet toData];
    [_gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

-(void)sendPacketToPeer:(NSString *)peerId :(G4Packet *)packet
{
    NSData* data = [packet toData];
    [_gameSession sendData:data toPeers:[NSArray arrayWithObject:peerId] withDataMode:GKSendDataReliable error:nil];
}

-(void)connectTo:(NSString*)peerId
{
    if(autoConnect)
        return;
    [_gameSession connectToPeer:peerId withTimeout:15];
}

-(void)acceptConnect:(NSString*)peerId
{
    if(autoConnect)
        return;
    [_gameSession acceptConnectionFromPeer:peerId error:nil];
}

-(void)peerConnecting:(NSString*)peerId
{
    if(autoConnect)
        return;
    [self putPacket:G4_COMM_CONNECTING :peerId];
}

-(void)peerUnAvailable:(NSString*)peerId
{
    if(autoConnect)
        return;
    [self putPacket:G4_COMM_UNAVAILABLE :peerId];
}

-(void)putPacket:(int)packetId:(NSString*)peerId
{
    G4Packet* packet = [[G4Packet alloc] initWith:packetId];
    [packet put:G4_KEY_COMM_ID :peerId];
    if(peerId != nil)
        [packet put:G4_KEY_COMM_NAME :[_gameSession displayNameForPeer:peerId]];
    [_queue put:packet];
    [packet release];
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if(autoConnect)
    {
        [session acceptConnectionFromPeer:peerID error:nil];
        if(_linkType == LINK_TYPE_OF_BT && [_picker isVisible])
            [_picker dismiss];
    }
    else
    {
        [self putPacket:G4_COMM_CONNECT_REQUEST :peerID];
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    [self peerDisconnected:peerID];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"did fail\n");
  //todo: [self peerDisconnected:peerID]; to every peer
}

-(void)peerAvailable:(NSString*)peerId
{
    if(autoConnect)
    {
        [_gameSession connectToPeer:peerId withTimeout:15];
        if(_linkType == LINK_TYPE_OF_BT && [_picker isVisible])
            [_picker dismiss];
    }
    else
    {
        [self putPacket:G4_COMM_AVAILABLE :peerId];
    }
}

-(void)peerConnected:(NSString*)peerId
{
    [self putPacket:G4_COMM_CONNECTED :peerId];
}

-(void)peerDisconnected:(NSString*)peerId
{
    [self putPacket:G4_COMM_DISCONNECTED :peerId];
}


-(void)dealloc
{
    _gameSession.available = NO;
    _gameSession.delegate = nil;
    [_gameSession disconnectFromAllPeers];
    [_gameSession release];
    [_queue release];
    [_sessionId release];
    [_displayName release];
    if([_picker isVisible])
        [_picker dismiss];
    [_picker release];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type
{
    
}

-(GKSession*)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    return _gameSession;    
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    if([_picker isVisible])
        [_picker dismiss];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    if([_picker isVisible])
        [_picker dismiss];
    [self putPacket:G4_USER_CANCELLED :nil];
}

@end
