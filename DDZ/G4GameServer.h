//
//  G4GameServer.h
//  DDZ
//
//  Created by gyf on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4ViewController.h"
#import "G4GamePlayer.h"

@interface G4ViewController(G4GameServer)<G4GameManagerDelegate>


-(void)server_playerAdded:(NSString*)peerId;
-(void)server_dealCard;
-(void)server_QDZ;
-(void)server_outCard;
-(void)server_cardOuted;

-(void)autoQDZ;
-(void)autoOutCard;

@end
