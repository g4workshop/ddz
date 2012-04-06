//
//  G4Watcher.h
//  DDZ
//
//  Created by gyf on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol G4WatcherDelegate <NSObject>

-(void)timeReached;

@end

@interface G4Watcher : NSObject
{
@private
    CALayer* _layer;
    CALayer* _superLayer;
    NSTimer* _timer;
    float _interval;
    int _times;
    int _currentTimes;
    float _intervalPerTime;
    float _angle;
    float _audioInterval;
}

@property(nonatomic,assign)NSObject<G4WatcherDelegate>* delegate;

-(id)init:(CALayer*)superLayer;
-(void)show:(float)interval :(float)audioInterval atPoint:(CGPoint)point;
-(void)hide;
-(void)dealloc;
-(void)timeOut;
-(void)draw;

-(void)calcParameters;

@end
