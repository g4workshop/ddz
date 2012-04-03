//
//  G4GameConfigration.m
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4GameConfigration.h"
#import "G4InputView.h"
#import "G4GameFSM.h"

@implementation G4ViewController(G4GameConfigration)

-(void)nickNameGetted:(NSString*)nickName
{
    if(![nickName isEqualToString:_selfInfo._nickName])
    {
        _selfInfo._nickName = [nickName retain];
        [self writeNickName];
    }
    [self initNetworker];
    [self setGameState:GAME_WAITING_PLAYERS];
}

-(void)getNickName
{
    _selfInfo._randomId = random_player_random_id();
    [self readNickName];
    G4InputView* inputView = [[G4InputView alloc] init:_selfInfo._nickName];
    
    [inputView show];
    [inputView release];
}

-(void)readNickName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"G4_DDZ_CONFIG"];
    
    _selfInfo._nickName = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] retain];
}

-(void)writeNickName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"G4_DDZ_CONFIG"];
    
    [_selfInfo._nickName writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

@end
