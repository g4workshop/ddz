//
//  G4PokerPlayer.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G4PokerPlayer : NSObject
{
@private
    NSMutableArray* _cardArray;
    BOOL _isAutoPlay;
    char _playerId;
}

-(id)init:(char)playerId;
-(void)addCard:(char)number;
-(void)rmvCard:(char)number;
-(int)countOf;
-(void)dealloc;
-(void)autoPlay:(BOOL)isAutoPlay;
-(BOOL)isAutoPlay;

@end