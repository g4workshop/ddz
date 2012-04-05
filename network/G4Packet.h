//
//  ZXPacket.h
//  Upgrade
//
//  Created by gyf on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_PACKET_LENGTH               512

#define OBJECT_TYPE_OF_G4STREAM             0
#define OBJECT_TYPE_OF_NSSTRING             1
#define OBJECT_TYPE_OF_NSNUMBER             2
#define OBJECT_TYPE_OF_NSARRAY              3
#define OBJECT_TYPE_OF_G4PAIR               4

                   
#define SET_ERROR_RETURN                    {_success = NO;return;}
#define ERROR_RETURN                        if(!_success) return 0

//我没弄明白NSEncoder,不然以下代码可以使用NSEncoder^_^

@interface G4Stream : NSObject {
@private
    NSData* _data;
    short _offset;
    BOOL _success;
    short _size;
}

@property(nonatomic,readonly)NSData* data;
@property(nonatomic)short offset;
@property(nonatomic,readonly)BOOL success;

-(id)init;
-(id)initWithData:(NSData*)data;
-(id)initWithBuffer:(char*)buffer:(int)length;
-(void)toStream:(G4Stream*)stream;
-(void)fromStream:(G4Stream*)stream;

-(void)dealloc;

-(void)put32:(int)value;
-(void)put16:(short)value;
-(void)put8:(char)value;
-(void)putBytes:(char*)value:(int)length;

-(int)get32;
-(short)get16;
-(char)get8;
-(void)getBytes:(char*)value:(int)length;

-(void)putObject:(id)object;
-(id)getObject;

-(const char*)bufferWithSizeInData:(short*)size;
-(const char*)buffer;

-(void)putNumber:(NSNumber*)number;
-(NSNumber*)getNumber;

-(void)putString:(NSString*)string;
-(NSString*)getString;

-(void)putData:(NSData*)data;
-(NSData*)getData;

-(void)putArray:(NSArray*)array;
-(NSArray*)getArray;

@end

@interface G4PacketPair : NSObject 
{
@public
    short _tag;
    id _object;
}

-(id)init:(short)tag:(id)object;

-(void)dealloc;

-(void)toStream:(G4Stream*)stream;
-(void)fromStream:(G4Stream*)stream;

@end


@interface G4Packet : NSObject
{
@private
    NSArray* _pairs;
    short _packetId;
}

@property(nonatomic)short packetId;

-(id)initWith:(short)packetId;
-(id)initWithData:(NSData*)data;
+(id)packetWith:(short)packetId;
-(void)put:(short)tag:(id)object;
-(id)get:(short)tag;

-(void)dealloc;

-(void)removeAll;

-(NSData*)toData;

@end
