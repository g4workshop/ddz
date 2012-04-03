//
//  G4PlayerInfoLayer.h
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface G4PlayerInfoLayer : NSObject
{
@private
    CALayer* _layer;
    CALayer* _superLayer;
    NSString* _playerName;
    char _playerId;
    char _cardCount;
}

-(id)init:(CALayer*)superLayer:(CGPoint)point;
-(void)show:(BOOL)show;
-(void)setCardCount:(char)cardCount;
-(void)setPlayerName:(NSString*)playerName:(char)playerId;
-(void)dealloc;
-(void)draw;
-(void)drawCardCount;
-(void)drawPlayerImage;
-(void)drawPlayerName;
@end
