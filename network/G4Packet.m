//
//  ZXPacket.m
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4Packet.h"

void put_u32_to_buffer(int value, unsigned char* buffer)
{
    buffer[0] = value & 0xFF;
    buffer[1] = (value >> 8) & 0xFF;
    buffer[2] = (value >> 16) & 0xFF;
    buffer[3] = (value >> 24) & 0xFF;
}

int get_u32_from_buffer(unsigned char* buffer)
{
    int rst = buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24;
    return rst;
}

void put_u16_to_buffer(int value, unsigned char* buffer)
{
    buffer[0] = value & 0xFF;
    buffer[1] = (value >> 8) & 0xFF;
}

int get_u16_from_buffer(unsigned char* buffer)
{
    int rst = buffer[0] | buffer[1] << 8;
    return rst;
}

void print_buffer(unsigned char* buffer, int buffer_length)
{
    for(int i = 0; i < buffer_length; i++)
    {
        if(i % 10 == 0 && i != 0)
            printf("\n");
        printf("%02X ", buffer[i]);
    }
    printf("\n");
}

@implementation NSString(NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize
{
    const char* p = [self UTF8String];
    int length = strlen(p) + 1;
    if(bufferSize < length)
        return -1;
    memcpy(buffer, p, length);
    return length;
}

-(id)initWithBytes:(unsigned char*)buffer
{
    return (self = [self initWithUTF8String:(const char*)buffer]);
}

@end


@implementation NSNumber(NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize
{
    buffer[0] = self.objCType[0];
 //   printf("%s\n", self.objCType);
    switch (buffer[0]) {
        case 'i':
            put_u32_to_buffer(self.intValue, buffer + 1);
            return 5;
        case 'c':
            buffer[1] = self.charValue;
            return 2;
        default:
            return -1;
    }
}

-(id)initWithBytes:(unsigned char*)buffer
{
    switch (buffer[0]) {
        case 'i':
        {
            int value = get_u32_from_buffer(&buffer[1]);
            self = [self initWithInt:value];
            break;
        }
        case 'c':
            self = [self initWithChar:buffer[1]];
            break;
        default:
            self = [self initWithInt:0];
            break;
    }
    return self;
}

@end

@implementation NSArray(NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize
{
    if(bufferSize < 8)
        return -1;
    int offset = 0;
    int count = [self count];
    if(count > 0xFF)
        return -1;
    buffer[0] = count;
    offset += 1;
    for(int i = 0; i < count; i++)
    {
        int tmp = [G4NetPacketPair objectToBytes:[self objectAtIndex:i] :&buffer[offset + 1] :bufferSize - offset];
        if(tmp < 0)
            return -1;
        if(tmp > 0xFF)
            return -1;
        buffer[offset] = tmp;
        offset += tmp + 1;
    }
    return offset;
}

-(id)initWithBytes:(unsigned char*)buffer
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    int count = buffer[0];
    int offset = 1;
    for(int i = 0; i < count; i++)
    {
        int size = buffer[offset];
        offset += 1;
        id tmp = [G4NetPacketPair objectFromBytes:&buffer[offset]];
        offset += size;
        [array addObject:tmp];
    }
    NSArray* tmp = [NSArray arrayWithArray:array];
    [array release];
    return tmp;
}

@end

@implementation G4CharArray

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize
{
    if(bufferSize < _count)
        return -1;
    put_u16_to_buffer(_count, buffer);
    memcpy(&buffer[2], _charBuffer, _count);
    return _count + 2;
}

-(id)initWithBytes:(unsigned char*)buffer
{
    if(self = [super init])
    {
        _count = get_u16_from_buffer(buffer);
    
        _bufferSize = ((_count + DEFAULT_CHAR_COUNT - 1) / DEFAULT_CHAR_COUNT) * DEFAULT_CHAR_COUNT;
        _charBuffer = (char*)malloc(_bufferSize * sizeof(char));
        
        memcpy(_charBuffer, &buffer[2], _count);
    }
    return self;
}

-(id)initWithBuffer:(char*)buffer:(int)count
{
    if(self = [super init])
    {
        _count = count;
        _bufferSize = ((_count + DEFAULT_CHAR_COUNT - 1) / DEFAULT_CHAR_COUNT) * DEFAULT_CHAR_COUNT;
        _charBuffer = (char*)malloc(_bufferSize * sizeof(char));
        
        memcpy(_charBuffer, buffer, _count);
    }
    return self;
}

-(void)reset
{
    if(_bufferSize > DEFAULT_CHAR_COUNT)
    {
        free(_charBuffer);
        _charBuffer = (char*)malloc(DEFAULT_CHAR_COUNT * sizeof(char));
        _bufferSize = DEFAULT_CHAR_COUNT;
    }
    memset(_charBuffer, 0, _bufferSize);
    _count = 0;
}

-(id)init
{
    if(self = [super init])
    {
        _charBuffer = (char*)malloc(DEFAULT_CHAR_COUNT * sizeof(char));
        _bufferSize = DEFAULT_CHAR_COUNT;
        _count = 0;
    }
    return self;
}

-(void)dealloc
{
    free(_charBuffer);
    [super dealloc];
}

-(void)put:(char)ch
{
    if(_count >= _bufferSize)
    {
        _bufferSize += DEFAULT_CHAR_COUNT;
        char* tmp = (char*)malloc(_bufferSize * sizeof(char));
        memcpy(tmp, _charBuffer, _count);
        free(_charBuffer);
        _charBuffer = tmp;
    }
    _charBuffer[_count++] = ch;
}

-(int)count
{
    return _count;
}

-(char)get:(int)index
{
    if(index < _count)
        return _charBuffer[index];
    return 0;
}

-(char*)get
{
    return _charBuffer;
}

@end

@implementation G4NetPacketPair

-(id)init:(int)tag:(id)object
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

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize
{
    if(bufferSize < 4)
        return -1;
    put_u16_to_buffer(_tag, buffer);
    int offset = 2;
    return [G4NetPacketPair objectToBytes:_object :&buffer[offset] :bufferSize - offset] + 2;
}

-(id)initWithBytes:(unsigned char*)buffer
{
    if(self = [super init])
    {
        _tag = get_u16_from_buffer(buffer);
        _object = [[G4NetPacketPair objectFromBytes:&buffer[2]] retain];
    }
    return self;
}

+(int)objectToBytes:(id)object:(unsigned char*)buffer:(int)bufferSize
{
    if([object isKindOfClass:[NSString class]])
        buffer[0] = OBJECT_TYPE_STRING;
    else if([object isKindOfClass:[NSNumber class]])
        buffer[0] = OBJECT_TYPE_NUMBER;
    else if([object isKindOfClass:[NSArray class]])
        buffer[0] = OBJECT_TYPE_ARRAY;
    else if([object isKindOfClass:[G4CharArray class]])
        buffer[0] = OBJECT_TYPE_CHARARRAY;
    else
        buffer[0] = OBJECT_TYPE_ELSE;
    
    if(bufferSize < 5)
        return -1;

    if(buffer[0] != OBJECT_TYPE_ELSE)
    {
        int tmp = [object toBytes:&buffer[1] :bufferSize - 1];
        return tmp + 1;
    }
    
    int offset = 2;
    NSString* classString = NSStringFromClass([object class]);
    int tmp = [classString toBytes:&buffer[offset] :bufferSize - offset];
    if(tmp < 0)
        return tmp;
    if(tmp > 127)
        return -1;
    
    buffer[1] = (char)tmp;
    
    offset += tmp;
    
    tmp = [object toBytes:&buffer[offset] :bufferSize - offset];
    if(tmp < 0)
        return tmp;
    
    offset += tmp;
        
    return offset;
}

+(id)objectFromBytes:(unsigned char*)buffer
{
    if(buffer[0] == OBJECT_TYPE_STRING)
        return [[[NSString alloc] initWithBytes:&buffer[1]] autorelease];
    else if(buffer[0] == OBJECT_TYPE_NUMBER)
        return [[[NSNumber alloc] initWithBytes:&buffer[1]] autorelease];
    else if(buffer[0] == OBJECT_TYPE_ARRAY)
        return [[[NSArray alloc] initWithBytes:&buffer[1] ]autorelease] ;
    else if(buffer[0] == OBJECT_TYPE_CHARARRAY)
        return [[[G4CharArray alloc] initWithBytes:&buffer[1]] autorelease];
    
    int offset = 2;
    
    NSString* classString = [[NSString alloc] initWithBytes:&buffer[offset]];
    Class objectClass = NSClassFromString(classString);
    [classString release];
    if(objectClass == Nil)
        return nil;
    
    offset += buffer[1];
    
    id tmp = [[[objectClass alloc] initWithBytes:&buffer[offset]] autorelease];
    
    return tmp;
    
}

@end

@implementation G4Packet

@synthesize packetId = _packetId;

-(id)initWith:(int)packetId
{
    if(self = [super init])
    {
        _pairs = [[NSMutableArray alloc] init];
        _packetId = packetId;
        return self;
    }
    return nil;
}

+(id)packetWith:(int)packetId
{
    return [[[G4Packet alloc] initWith:packetId] autorelease];
}


-(id)initWithData:(NSData *)data
{
    if(self = [super init])
    {
        //_pairs = [[NSMutableArray alloc] initWithBytes:(unsigned char*)data.bytes];
    
        _pairs = [[NSMutableArray alloc] init];
        unsigned char* buffer = (unsigned char*)data.bytes;
        int length = data.length;
        
        //printf("RECV:");
        //print_buffer(buffer, length);
        
        _packetId = get_u16_from_buffer(buffer);
        int count = buffer[2];
 
        int offset = 3;
        for(int i = 0; i < count; i++)
        {
            if(offset > length)
                return nil;
            int size = buffer[offset];
            offset += 1;
            id tmp = [[G4NetPacketPair alloc] initWithBytes:&buffer[offset]];//[G4NetPacketPair objectFromBytes:&buffer[offset]];
            offset += size;
            [_pairs addObject:tmp];
            [tmp release];
        }

        return self;
    }
    return nil;
}

-(void)put:(int)tag:(id)object
{
    if(object == nil)
        return;
    G4NetPacketPair* pair = [[G4NetPacketPair alloc] init:tag :object];
    [_pairs addObject:pair];
    [pair release];
}

-(void)putCharArray:(int)tag:(char*)buffer:(int)count
{
    G4CharArray* charArray = [[G4CharArray alloc] initWithBuffer:buffer :count];
    [self put : tag : charArray];
    [charArray release];
}

-(id)get:(int)tag
{
    for (G4NetPacketPair* pair in _pairs)
    {
        if(pair->_tag == tag)
            return pair->_object; 
    }
    return nil;
}

-(NSData*)toData
{
    unsigned char buffer[MAX_PACKET_LENGTH];
    int offset = 0;
    put_u16_to_buffer(_packetId, buffer);
    offset += 2;
    int count = [_pairs count];
    buffer[2] = count;
    offset += 1;
    for(int i = 0; i < count; i++)
    {
        G4NetPacketPair* pair = (G4NetPacketPair*)[_pairs objectAtIndex:i];
        int tmp = [pair toBytes:&buffer[offset + 1] :MAX_PACKET_LENGTH - offset];
        if(tmp < 0)
            return nil;
        if(tmp > 0xFF)
            return nil;
        buffer[offset] = tmp;
        offset += tmp + 1;
    }
    return [NSData dataWithBytes:(const void*)buffer length:offset];;
}


-(void)dealloc
{
    [_pairs release];
}

-(void)removeAll
{
    [_pairs removeAllObjects];
}
@end
