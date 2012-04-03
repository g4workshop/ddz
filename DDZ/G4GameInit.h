//
//  G4GameInit.h
//  DDZ
//
//  Created by gyf on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4ViewController.h"

@interface G4ViewController(G4GameInit)


-(void)playerNameGetted:(NSString*)playerName;
-(void)getPlayerName;
-(void)readPlayerName;
-(void)writePlayerName;


-(void)initNetworker;

-(void)initWatcher;
-(void)initCmdPannel;

-(void)initWaitView;


@end
