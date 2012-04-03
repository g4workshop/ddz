//
//  G4GameAnimation.h
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4ViewController.h"

@interface G4ViewController(G4GameAnimation)

-(void)beginDealCard;
-(void)beginDealDZCard;
-(void)dealACard:(float)x;
-(void)initCardGroup;
-(void)initAnimation;

@end
