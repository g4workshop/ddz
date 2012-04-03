//
//  G4FSM.h
//  DDZ
//
//  Created by gyf on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4Packet.h"

@interface G4FSMRule : NSObject 

@property(nonatomic)char _state;
@property(nonatomic)short _event;
@property(nonatomic)short _value;
@property(nonatomic,assign)SEL _func;
@property(nonatomic)char _next_state;

+(id)ruleWith:(char)state event:(short)event value:(short)value func:(SEL)func next_state:(char)next_state;
@end

@protocol G4FSMDelegate <NSObject>

-(void)entryState:(char)newState packet:(G4Packet*)packet;
-(void)leaveState:(char)oldState packet:(G4Packet*)packet;
-(void)noRule:(G4Packet*)packet;

@end
@interface G4FSM : NSObject {
@private
    NSMutableArray* _ruleArray;
}

@property(nonatomic,assign)NSObject<G4FSMDelegate>* deleate;
@property(nonatomic)char _state;

-(id)init:(char)state;
-(void)dealloc;

-(void)run:(G4Packet*)packet;
-(void)addRule:(char)state event:(char)event func:(SEL)func next_state:(char)next_state;
-(G4FSMRule*)findRule:(G4Packet*)packet;

@end