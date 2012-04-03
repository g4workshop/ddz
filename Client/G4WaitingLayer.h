//
//  G4WaitingLayer.h
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "G4GamePlayer.h"

@interface G4WaitingLayer : NSObject
{
@private
    CALayer* _layer;
    float _fontHeight;
    G4GameManager* _gameManager;
}

-(id)init:(CALayer*)superLayer:(CGRect)frame:(G4GameManager*)gameManager;
-(void)dealloc;
-(void)draw;
-(void)drawName;
-(void)setFrame:(CGRect)viewFrame;
-(void)drawPlayerImage:(int)index:(G4GamePlayer*)player;
-(BOOL)hitTest:(CGPoint)pt;
-(void)redraw;

@end
