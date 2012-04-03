//
//  G4AdLayer.h
//  DDZ
//
//  Created by gyf on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface G4AdLayer : NSObject
{
@private
    CALayer* _layer;
    CALayer* _superLayer;
    CABasicAnimation* _animation;
}

-(id)init:(CALayer*)superLayer;
-(void)dealloc;
-(void)showAd:(BOOL)show;
@end
