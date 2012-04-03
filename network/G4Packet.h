//
//  ZXPacket.h
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PACKET_TYPE_DEAL_A_CARD         0
#define PACKET_TYPE_ALLOC_PLAYER_ID     1
#define PACKET_TYPE_CARD_DISPLAYED      2
#define PACKET_TYPE_START_DEAL          3

#define MAX_PACKET_LENGTH               512

void put_u32_to_buffer(int value, unsigned char* buffer);
void put_u16_to_buffer(int value, unsigned char* buffer);
int get_u32_from_buffer(unsigned char* buffer);
int get_u16_from_buffer(unsigned char* buffer);

void print_buffer(unsigned char* buffer, int buffer_length);

@protocol G4NetPacketObject <NSObject>

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;

@end

@interface NSString(G4NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;
@end

@interface NSNumber(G4NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;

@end

@interface NSArray(G4NetPacketObject)

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;

@end

#define DEFAULT_CHAR_COUNT          32

@interface G4CharArray : NSObject<G4NetPacketObject> {
@private
    char* _charBuffer;
    int _bufferSize;
    int _count;
}

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;
-(id)initWithBuffer:(char*)buffer:(int)count;
-(void)reset;
-(id)init;
-(void)dealloc;
-(void)put:(char)ch;
-(int)count;
-(char)get:(int)index;
-(char*)get;

@end

#define OBJECT_TYPE_STRING      0
#define OBJECT_TYPE_NUMBER      1
#define OBJECT_TYPE_ARRAY       2
#define OBJECT_TYPE_CHARARRAY   3
#define OBJECT_TYPE_ELSE        4

@interface G4NetPacketPair : NSObject<G4NetPacketObject> 
{
@public
    int _tag;
    id _object;
}

-(id)init:(int)tag:(id)object;
-(void)dealloc;

-(int)toBytes:(unsigned char*)buffer:(int)bufferSize;
-(id)initWithBytes:(unsigned char*)buffer;

+(int)objectToBytes:(id)object:(unsigned char*)buffer:(int)bufferSize;
+(id)objectFromBytes:(unsigned char*)buffer;
@end


@interface G4Packet : NSObject
{
@private
    NSMutableArray* _pairs;
    int _packetId;
}

@property(nonatomic)int packetId;

-(id)initWith:(int)packetId;
-(id)initWithData:(NSData*)data;
+(id)packetWith:(int)packetId;
-(void)put:(int)tag:(id)object;
-(id)get:(int)tag;
-(void)putCharArray:(int)tag:(char*)buffer:(int)count;



-(void)dealloc;

-(void)removeAll;

-(NSData*)toData;

@end
