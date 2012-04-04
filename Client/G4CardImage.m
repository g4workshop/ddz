//
//  G4CardImage.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4CardImage.h"
#import "G4CardSize.h"

static UIImage* type_image[4] = {nil, nil, nil, nil};
static UIImage* player_image[4] = {nil, nil, nil, nil};
static UIImage* game_bk_image[] = {nil, nil};
static UIImage* card_bk_image = nil;
static UIImage* watcher_image = nil;
static UIImage* computer_image = nil;
static UIImage* gamecenter_image = nil;
static UIImage* wifi_image = nil;
static UIImage* mode_select_bk_image = nil;

#define NUMBER_IMAGE_COUNT 16
static UIImage* number_image[NUMBER_IMAGE_COUNT * 2];

static char* card_number_str[] = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A","O", "E", "R"};

@implementation G4CardImage

+(void)drawImage:(UIImage*)image:(char)rotate:(CGRect)rect
{
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
    if(rotate != 0)
        CGContextRotateCTM(ref, rotate * M_PI_2);
    if(rotate == 1)
        CGContextTranslateCTM(ref, rect.origin.y, -rect.size.height - rect.origin.x);
    else if(rotate == 2)
        CGContextTranslateCTM(ref, -rect.size.width - rect.origin.x, -rect.size.height - rect.origin.y);
    else if(rotate == -1)
        CGContextTranslateCTM(ref, -rect.size.width - rect.origin.y, rect.origin.x);
    else if(rotate == 0)
        CGContextTranslateCTM(ref, rect.origin.x, rect.origin.y);
    [image drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    CGContextRestoreGState(ref);
}

+(void)initAllImages
{
    @autoreleasepool {    
        type_image[0] = [[UIImage imageNamed:@"type_1.png"] retain];
        type_image[1] = [[UIImage imageNamed:@"type_2.png"] retain];
        type_image[2] = [[UIImage imageNamed:@"type_3.png"] retain];
        type_image[3] = [[UIImage imageNamed:@"type_4.png"] retain];
        game_bk_image[0] = [[UIImage imageNamed:@"game_bk_0.png"] retain];
        game_bk_image[1] = [[UIImage imageNamed:@"game_bk_1.png"] retain];
        card_bk_image = [[UIImage imageNamed:@"card_bk.png"] retain];
        mode_select_bk_image = [[UIImage imageNamed:@"mode_select_back.png"] retain];

        UIColor* colors[2] = {[UIColor blackColor], [UIColor redColor]};
        
        for(char i = 0; i < NUMBER_IMAGE_COUNT * 2; i++)
            number_image[i] = [[G4CardImage createDigitImage:i % NUMBER_IMAGE_COUNT:colors[i / NUMBER_IMAGE_COUNT]] retain];
        
        for(int i = 0; i < 4; i++)
            player_image[i] = [[UIImage imageNamed:@"player.png"] retain];
        
        watcher_image = [[UIImage imageNamed:@"watcher.png"] retain];
        computer_image = [[UIImage imageNamed:@"computer.png"] retain];
        wifi_image = [[UIImage imageNamed:@"wifi.png"] retain];
        gamecenter_image = [[UIImage imageNamed:@"gamecenter.png"] retain];
    }
}

+(void)releaseAllImage
{
    for(int i = 0; i < NUMBER_IMAGE_COUNT; i++)
        [number_image[i] release];
    for(int i = 0; i < 4; i++)
        [type_image[i] release];
    [game_bk_image[0] release];
    [game_bk_image[1]  release];
    [card_bk_image release];
    for(int i = 0; i < 4; i++)
        [player_image[i] release];
    [watcher_image release];
    [computer_image  release];
}

+(UIImage*)typeImage:(char)cardType
{
    return type_image[cardType];
}

+(UIImage*)gameBKImage:(char)index
{
    return game_bk_image[index % 2];
}

+(UIImage*)cardBKImage
{
    return card_bk_image;
}

+(UIImage*)numberImage:(char)index
{
    return number_image[index];
}

+(UIImage*)playerImage:(char)index
{
    return player_image[index % 4];
}

+(UIImage*)computerImage
{
    return computer_image;
}

+(UIImage*)watcherImage
{
    return watcher_image;
}

+(UIImage*)wifiImage
{
    return wifi_image;
}

+(UIImage*)gamecenterImage
{
    return gamecenter_image;
}

+(UIImage*)modeSelectBkImage
{
    return mode_select_bk_image;
}

+(UIImage*)createDigitImage:(int)index:(UIColor*)color
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    UIFont* font = [UIFont fontWithName:@"Helvetica" size:[G4CardSize cardDigitFontSize]];
    
    NSString* numberStr = [NSString stringWithFormat:@"%s", card_number_str[index]];
    CGSize size = [numberStr sizeWithFont:font];

    CGContextRef ref = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, rgb, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Big);
    
    CGContextScaleCTM(ref, 1.0, -1.0);
    CGContextTranslateCTM(ref, 0, -size.height);
    
    UIGraphicsPushContext(ref);
    
    [color set];
    [numberStr drawAtPoint:CGPointMake(0, 0) withFont:font];
    
    UIGraphicsPopContext();
    
    CFRelease(rgb);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ref);
    CGContextRelease(ref);
    UIImage* image = [[UIImage alloc] initWithCGImage:imageRef];
    CFRelease(imageRef);
    return [image autorelease];
}

+(void)drawJoker:(char)type:(char)rotate:(CGRect)rect
{
    const int jokerCount = 5;
    int strIndex1[jokerCount] = {9,13,11,14,15};
    int strIndex2[] = {15,14,11,13,9};
    int* index = (int*)strIndex1;
    if(rotate == 2)
        index = (int*)strIndex2;
    float height = rect.size.height / jokerCount;
    for(int i = 0; i < jokerCount; i++)
    {
        CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y + i * height + 1, rect.size.width, height);
        [G4CardImage drawImage:[G4CardImage numberImage:index[i] + type * 16]:rotate:drawRect];
    }
}

+(float)drawCardDigit:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth
{
    char cardType = ((cardNumber % 4) % 2);
    char cardDigit = cardNumber / 4;
    if(cardDigit == 13)
    {
        [G4CardImage drawJoker:cardType :0 :[G4CardSize cardJokerLeftRect:offset]];
        [G4CardImage drawJoker:cardType :2 :[G4CardSize cardJokerRightRect:offset]];
        return 0;
    }
    
    UIImage* image = [G4CardImage numberImage:cardDigit + cardType * 16];
    CGRect rect = [G4CardSize cardLeftUpDigitRect:offset:image.size.height];
    
    [G4CardImage drawImage:image :0 :rect];
    float y = rect.origin.y + rect.size.height + 1;
    rect = [G4CardSize cardRightDownDigitRect:offset:image.size.height];
    if(cardShowWidth < [G4CardSize cardWidth])
        return y;
    [G4CardImage drawImage:image :2 :rect];
    return y;
}

+(void)drawTypeImage:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth:(float)y
{
    if(cardNumber / 4 == 13)
        return;
    char cardType = cardNumber % 4;
    UIImage* image = [G4CardImage typeImage:cardType];
    CGRect rect = [G4CardSize cardLeftupTypeRect:offset:image.size :y];
    [G4CardImage drawImage:image :0 :rect];
    rect = [G4CardSize cardRightDownTypeRect:offset:image.size :y];
    if(cardShowWidth + offset.x < rect.origin.x)
        return;
    [G4CardImage drawImage:image :2 :rect]; 
}

+(void)drawCenterImage:(CGPoint)offset:(char)cardNumber:(float)cardShowWidth:(char)direction
{
    if(cardNumber / 4 == 13)
        return;
    char cardType = cardNumber % 4;
    UIImage* image = [G4CardImage typeImage:cardType];
    CGRect rect = [G4CardSize cardCenterImageRect:offset:image.size];
    if(cardShowWidth + offset.x < rect.origin.x)
        return;
    [G4CardImage drawImage:image :direction :rect];    
}
@end
