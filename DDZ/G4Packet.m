//
//  ZXPacket.m
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Packet.h"

@implementation G4CardNumber

@synthesize card_number;

@end
@implementation G4Packet

@synthesize packet_type;
@synthesize player_id;
@synthesize card_count;

-(id)init
{
    self = [super init];
    card_numbers = [[NSMutableArray alloc] init];
    return self;
}

-(void)dealloc
{
   // printf("packet:%d-%d dealloced\n", self.packet_type, self.player_id);
    [super dealloc];
    [card_numbers release];
}

-(int)count_of_card
{
    return [card_numbers count];
}

-(char)card_at_index:(int)index
{
    G4CardNumber* number = [card_numbers objectAtIndex:index];
    return number.card_number;
}

-(void)add_card:(char)number
{
    G4CardNumber* x = [[G4CardNumber alloc] init];
    x.card_number = number;
    [card_numbers addObject:x];
    [x release];
}

-(BOOL)is_card_in:(char)card_number
{
    for(G4CardNumber* cardNumber in card_numbers)
    {
        if(cardNumber.card_number == card_number)
            return YES;
    }
    return NO;
}

@end
