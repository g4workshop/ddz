//
//  G4FloatInfoLayer.h
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface G4FloatInfoLayer : NSObject
{
@private
    CALayer* _infoLayer;
    CALayer* _superLayer;
    NSString* _showInfo;
    NSTimer* _showTimer;
}

-(id)init:(CALayer*)superLayer:(CGRect)frame;
-(void)dealloc;
-(void)showInfo:(NSString*)info:(float)maxTime;
-(void)hideInfo;
-(void)timed;
-(void)draw;

@end
