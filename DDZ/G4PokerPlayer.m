//
//  G4PokerPlayer.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4PokerPlayer.h"

@implementation G4PokerPlayer

-(id)init:(char)playerId
{
    self = [super init];
    _cardArray = [[NSMutableArray alloc] init];
    _playerId = playerId;
    _isAutoPlay = NO;
    return self;
}

-(void)addCard:(char)number
{
    [_cardArray addObject:[NSNumber numberWithChar:number]];
}

-(void)rmvCard:(char)number
{
    for(int i = 0; i < [_cardArray count]; i++)
    {
        NSNumber* tmp = [_cardArray objectAtIndex:i];
        if([tmp charValue] == number)
        {
            [_cardArray removeObjectAtIndex:i];
            return;
        }
    }
}

-(int)countOf
{
    return [_cardArray count];
}

-(void)dealloc
{
    [_cardArray release];
}

-(void)autoPlay:(BOOL)isAutoPlay
{
    _isAutoPlay = isAutoPlay;
}

-(BOOL)isAutoPlay
{
    return _isAutoPlay;
}


@end
