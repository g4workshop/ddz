//
//  G4GameInit.m
//  DDZ
//
//  Created by gyf on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GameInit.h"
#import "G4CardSize.h"
#import "G4CardGroup.h"
#import "G4CardSize.h"
#import "G4GameFSM.h"
#import "G4InputView.h"

@implementation G4ViewController(G4GameInit)

-(void)playerNameGetted:(NSString *)playerName
{
#ifdef G4_LOGING_DEBUG
    NSLog(@"User input name:%@\n", playerName);
#endif
    if(![playerName isEqualToString:_displayName])
    {
        _displayName = [playerName retain];
        [self writePlayerName];
    }
    [self doAppStart];
}

-(void)getPlayerName
{
    [self readPlayerName];
    G4InputView* inputView = [[G4InputView alloc] init:_displayName];
    
    [inputView show];
    [inputView release];
}

-(void)readPlayerName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"G4_DDZ_CONFIG"];
    
    _displayName = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] retain];
}

-(void)writePlayerName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"G4_DDZ_CONFIG"];
    
    [_displayName writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

-(void)initWatcher
{
    _watcher = [[G4Watcher alloc] init:self.view.layer];
    _watcher.delegate = self;
}

-(void)initCmdPannel
{
    _cmdPannel = [[G4CmdPannel alloc] init:self.view];
    _cmdPannel.deleate = self;
}

-(void)initNetworker
{
    _comm = [[G4Comm alloc] init];
    _comm.delegate = self;
    [_comm start];
    [_comm startNetwork:@"G4_DDZ" displayName:_displayName linkType:LINK_TYPE_OF_WLAN autoConnect:YES];
}

-(void)initWaitView
{
    if(_waitingLayer)
        [_waitingLayer release];
    float x = ([G4CardSize deviceViewSize].width - [G4CardSize waitingViewWidth]) / 2;
    float y = ([G4CardSize deviceViewSize].width  - [G4CardSize waitingViewHeight]) / 3;
    
    CGRect frame = CGRectMake(x, y, [G4CardSize deviceViewSize].width, [G4CardSize deviceViewSize].height);

    _waitingLayer = [[G4WaitingLayer alloc] init:self.view.layer :frame:_gameManager];
}


@end
