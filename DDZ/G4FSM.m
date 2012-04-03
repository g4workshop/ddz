//
//  G4FSM.m
//  DDZ
//
//  Created by gyf on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4FSM.h"

@implementation G4FSMRule

@synthesize _state;
@synthesize _next_state;
@synthesize _func;
@synthesize _event;
@synthesize _value;

+(id)ruleWith:(char)state event:(short)event value:(short)value func:(SEL)func next_state:(char)next_state;
{
    G4FSMRule* rule = [[[G4FSMRule alloc] init] autorelease];
    rule._state = state;
    rule._event = event;
    rule._value = value;
    rule._func = func;
    rule._next_state = next_state;
    return rule;
}

@end

@implementation G4FSM

@synthesize deleate;
@synthesize _state;

-(id)init:(char)state
{
    if(self = [super init])
    {
        _ruleArray = [[NSMutableArray alloc] init];
        _state = state;
    }
    return self;
}

-(void)dealloc
{
    [_ruleArray release];
    [_ruleArray dealloc];
}

-(void)run:(G4Packet*)packet
{
    G4FSMRule* fsm_rule = [self findRule:packet];
    if(fsm_rule == nil)
    {
        NSLog(@"RECV %X,but no rule\n", packet.packetId);
        [deleate noRule:packet];
        return;
    }
    
    [deleate leaveState:fsm_rule._next_state packet:packet];
    NSLog(@"(%d)->(%d,%d)->(%d)\n", fsm_rule._state, packet.packetId, 0, fsm_rule._next_state);
    [deleate performSelector:fsm_rule._func withObject:packet];
    _state = fsm_rule._next_state;
    [deleate entryState:fsm_rule._state packet:packet];
}

-(void)addRule:(char)state event:(char)event func:(SEL)func next_state:(char)next_state
{
    [_ruleArray addObject:[G4FSMRule ruleWith:state event:event value:0 func:func next_state:next_state]];
}

-(G4FSMRule*)findRule:(G4Packet*)packet
{
    for(G4FSMRule* rule in _ruleArray)
    {
        if(rule._state == _state && rule._event == packet.packetId)
            return rule;
    }
    return nil;
}

@end