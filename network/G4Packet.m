//
//  ZXPacket.m
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Packet.h"

@implementation G4Stream

@synthesize data = _data;
@synthesize offset = _offset;
@synthesize success = _success;

-(id)init
{
    if(self = [super init])
    {
        _size = MAX_PACKET_LENGTH;
        _data = [[NSMutableData alloc] initWithCapacity:_size];
        _offset = 0;
        _success = YES;
    }
    return self;
}

-(id)initWithData:(NSData*)data
{
    _data = [data retain];
    _offset = 0;
    _success = YES;
    _size = data.length;
    return self;
}

-(id)initWithBuffer:(char*)buffer:(int)length
{
    if(self = [super init])
    {
        _data = [[NSMutableData alloc] initWithBytes:buffer length:length];
        _offset = 0;
        _success = YES;
        _size = length;
    }
    return self;
}

-(void)dealloc
{
    [_data release];
}

-(void)toStream:(G4Stream*)stream
{
    [stream put16:_offset];
    [stream putBytes:(char*)_data.bytes :_offset];
}

-(void)fromStream:(G4Stream *)stream
{
    _offset = 0;
    _success = 0;
    const char* tmp = [stream bufferWithSizeInData:&_size];
    [((NSMutableData*)_data)appendBytes:tmp length:_size];
}

-(void)put32:(int)value
{
    char buffer[4];
    buffer[0] = value & 0xFF;
    buffer[1] = (value >> 8) & 0xFF;
    buffer[2] = (value >> 16) & 0xFF;
    buffer[3] = (value >> 24) & 0xFF;
    [self putBytes:buffer :4];
}

-(void)put16:(short)value
{
    char buffer[2];
    buffer[0] = value & 0xFF;
    buffer[1] = (value >> 8) & 0xFF;
    [self putBytes:buffer :2];
}

-(void)put8:(char)value
{
    [self putBytes:&value :1]; 
}

-(void)putBytes:(char*)value:(int)length
{
    if(![_data isKindOfClass:[NSMutableData class]])
        SET_ERROR_RETURN;
    if(_offset + length >= _size)
        SET_ERROR_RETURN;
    [((NSMutableData*)_data) appendBytes:value length:length];
    _offset += length;  
    NSLog(@"putbytes,data is %@\n", _data);
}

-(int)get32
{
    char buffer[4];
    [self getBytes:buffer :4];
    ERROR_RETURN;
    return (buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24);
}

-(short)get16
{
    char buffer[2];
    [self getBytes:buffer :2];
    ERROR_RETURN;
    return (buffer[0] | buffer[1] << 8);
}

-(char)get8
{
    char value;
    [self getBytes:&value :1];
    ERROR_RETURN;
    return value;
}

-(void)getBytes:(char*)value:(int)length
{
    if(_offset + length > _size)
        SET_ERROR_RETURN;
    NSRange range;
    range.location = _offset;
    range.length = length;
    [_data getBytes:value range:range];
    _offset += length;
}

-(void)putObject:(id)object
{
    if([object isKindOfClass:[NSString class]])
    {
        [self put8:1];
        [self putString:object];
    }
    else if([object isKindOfClass:[NSNumber class]])
    {
        [self put8:2];
        [self putNumber:object];
    }
    else if([object isKindOfClass:[NSArray class]])
    {
        [self put8:3];
        [self putArray:object];
    }
    else if([object isKindOfClass:[G4PacketPair class]])
    {
        [self put8:4];
        [((G4PacketPair*)object) toStream:self];
    }
    else if([object isKindOfClass:[G4Stream class]])
    {
        [self put8:5];
        [((G4Stream*)object) toStream:self];
    }
    else if([object isKindOfClass:[NSData class]])
    {
        [self put8:6];
        [self putData:object];
    }
    else
    {
        SEL sel = NSSelectorFromString(@"toStream:");
        if(![object respondsToSelector:sel])
            return;
        [self put8:7];
        NSString* classString = NSStringFromClass([object class]);
        [self putString:classString];
        [object performSelector:sel withObject:self];
    }

}

-(id)getObject
{
    char type = [self get8];
    id object = nil;
    switch (type) 
    {
        case 1:
            return [self getString];
        case 2:
            return [self getNumber];
            break;
        case 3:
            return [self getArray];
            break;
        case 4:
        {
            G4PacketPair* packetPair = [[[G4PacketPair alloc] init] autorelease];
            [packetPair fromStream:self];
            return packetPair;
        }
        case 5:
        {
            G4Stream* stream = [[[G4Stream alloc] init] autorelease];
            [stream fromStream:self];
            return stream;
        }
        case 6:
            return [self getData];
        case 7:
        {
            NSString* classString = [self getString];
            Class c = NSClassFromString(classString);
            if(!c)
                return nil;
            SEL sel = NSSelectorFromString(@"fromStream:");
            if(![c instancesRespondToSelector:sel])
                return nil;
            object = [[[c alloc] init] autorelease];
            [object performSelector:sel withObject:self];
            return object;
        }
        default:
            return nil;
    }  
    return nil;
}

-(void)putNumber:(NSNumber*)number
{
    [self put8:number.objCType[0]];
    switch (number.objCType[0]) {
        case 'i':
            [self put32:number.intValue];
            break;
        case 'c':
            [self put8:number.charValue];
            break;
        default:
            break;
    }
}

-(NSNumber*)getNumber
{    
    char value = [self get8];
    switch (value) {
        case 'i':
            return [NSNumber numberWithInt:[self get32]];
        case 'c':
            return [NSNumber numberWithChar:[self get8]];
        default:
            return [NSNumber numberWithInt:0];
    }
}

-(void)putString:(NSString*)string
{
    const char* p = [string UTF8String];
    short length = (short)strlen(p) + 1;
    [self put16:length];
    [self putBytes:(char*)p :length];
}

-(NSString*)getString
{
    return [NSString stringWithUTF8String:[self bufferWithSizeInData:NULL]];
}

-(void)putData:(NSData*)data
{
    [self put16:data.length];
    [self putBytes:(char*)data.bytes :data.length];
}

-(NSData*)getData
{
    short size = [self get16];
    NSData* data = [NSData dataWithBytes:[self buffer] length:size];
    _offset += size;
    return data;
}

-(void)putArray:(NSArray*)array
{
    char count = (char)[array count];
    [self put8:count];
    
    for(char i = 0; i < count; i++)
    {
        id object = [array objectAtIndex:i];
        [self putObject:object];
    }
}

-(NSArray*)getArray
{
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    char count = [self get8];
    
    for(char i = 0; i < count; i++)
    {
        id object = [self getObject];
        if(object != nil)
            [array addObject:object];
    }
    return array;
}


-(const char*)bufferWithSizeInData:(short*)size
{
    short tmp_size = [self get16];
    const char* tmp = &_data.bytes[_offset];
    _offset += tmp_size;
    if(size)
        *size = tmp_size;
    return tmp;
}

-(const char*)buffer
{
    return &_data.bytes[_offset];
}

@end

@implementation G4PacketPair

-(id)init:(short)tag:(id)object
{
    if(self = [super init])
    {
        _tag = tag;
        _object = [object retain];
    }
    return self;
}

-(void)dealloc
{
    [_object release];
}

-(void)toStream:(G4Stream*)stream
{
    [stream put16:_tag];
    [stream putObject:_object];
}

-(void)fromStream:(G4Stream *)stream
{
    _tag = [stream get16];
    _object = [[stream getObject] retain];
}

@end

@implementation G4Packet

@synthesize packetId = _packetId;

-(id)initWith:(short)packetId
{
    if(self = [super init])
    {
        _pairs = [[NSMutableArray alloc] init];
        _packetId = packetId;
        return self;
    }
    return nil;
}

+(id)packetWith:(short)packetId
{
    return [[[G4Packet alloc] initWith:packetId] autorelease];
}


-(id)initWithData:(NSData *)data
{
    if(self = [super init])
    {    
        G4Stream* stream = [[G4Stream alloc] initWithData:data];
        _packetId = [stream get16];
        _pairs = [[stream getArray] retain];
        [stream release];
        return self;
    }
    return nil;
}

-(void)put:(short)tag:(id)object
{
    if(object == nil)
        return;
    G4PacketPair* pair = [[G4PacketPair alloc] init:tag :object];
    [(NSMutableArray*)_pairs addObject:pair];
    [pair release];
}

-(id)get:(short)tag
{
    for (G4PacketPair* pair in _pairs)
    {
        if(pair->_tag == tag)
            return pair->_object; 
    }
    return nil;
}

-(NSData*)toData
{
    G4Stream* stream = [[G4Stream alloc] init];
    
    [stream put16:_packetId];
    [stream putArray:_pairs];
    
    NSData* data = [[stream.data retain] autorelease];
    
    [stream release];
    return data;
}


-(void)dealloc
{
    [_pairs release];
}

-(void)removeAll
{
    [(NSMutableArray*)_pairs removeAllObjects];
}
@end
