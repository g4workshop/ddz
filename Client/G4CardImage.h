//
//  G4CardImage.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G4CardImage : NSObject

+(void)drawImage:(UIImage*)image:(char)rotate:(CGRect)rect;
+(void)initAllImages;
+(void)releaseAllImage;
+(UIImage*)typeImage:(char)cardType;
+(UIImage*)gameBKImage;
+(UIImage*)cardBKImage;
+(UIImage*)numberImage:(char)index;
+(UIImage*)createDigitImage:(int)index:(UIColor*)color;
+(UIImage*)playerImage:(char)index;
+(UIImage*)watcherImage;
+(UIImage*)computerImage;
+(UIImage*)wifiImage;
+(UIImage*)gamecenterImage;
+(UIImage*)modeSelectBkImage;
//+(UIImage*)passImage;
+(void)drawJoker:(char)type:(char)rotate:(CGRect)rect;
+(float)drawCardDigit:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth;
+(void)drawTypeImage:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth:(float)y;
+(void)drawCenterImage:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth:(char)direction;
@end
