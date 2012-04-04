//
//  G4CardSize.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DEVICE_TYPE_480_320                 0
#define DEVICE_TYPE_1024_768                1

#define GROUP_DIRECTION_LEFT        1
#define GROUP_DIRECTION_ME          0
#define GROUP_DIRECTION_RIGHT       -1
#define GROUP_DIRECTION_UP          2

#import <Foundation/Foundation.h>

  
@interface G4CardSize : NSObject

+(void)setDeviceType:(char)type;
+(float)cardWidth;
+(float)cardHeight;
+(float)cardNumberWidth;
+(float)cardTypeImageWidth;
+(int)cardDigitFontSize;
+(float)cardCorner;
+(float)cardBorderWidth;
+(float)edgeSpace;
+(float)cardMaxShowWidth;
+(float)cardMinShowWidth;

+(void)setMaxDistance:(float)x:(float)y;
+(void)setMaxAnimationDuration:(float)duration;

+(CGRect)cardLeftUpDigitRect:(CGPoint)offset:(float)digitImageHeight;
+(CGRect)cardRightDownDigitRect:(CGPoint)offset:(float)digitImageHeight;
+(CGRect)cardLeftupTypeRect:(CGPoint)offset:(CGSize)typeImageSize:(float)y;
+(CGRect)cardRightDownTypeRect:(CGPoint)offset:(CGSize)typeImageSize:(float)y;
+(CGRect)cardCenterImageRect:(CGPoint)offset:(CGSize)typeImageSize;
+(CGSize)calcScaledSize:(CGSize)origSize:(float)scaledWidth;
+(CGRect)cardJokerLeftRect:(CGPoint)offset;
+(CGRect)cardJokerRightRect:(CGPoint)offset;
+(CGSize)deviceViewSize;
+(CGPoint)calcCardCenter:(CGPoint)leftupPoint;
+(float)calcDealPokerAnimationDuration:(float)x:(float)y;
+(CGPoint)calcCenter:(CGRect)rect;
+(float)cardSelectedUp;

+(CGRect)selfCardGroupRect;
+(CGRect)selfOutGroupRect;
+(CGRect)leftOutGroupRect;
+(CGRect)upOutGroupRect;
+(CGRect)rightOutGroupRect;

+(float)outGroupWidth;

+(CGSize)swapSizeWidthHeight:(CGSize)size;
+(float)waitingViewFontSize;
+(float)lineWidth;
+(float)waitingViewHeight;
+(float)waitingViewWidth;
+(float)waitingViewInfoX;
+(float)waitingViewPlayerNameY;
+(float)waitingViewPlayerNameHeight;
+(float)waitingViewInfoEdge;
+(float)waitingViewImageHeight;
+(float)adViewHeight;

+(float)playerImageSize;
+(float)playerInfoBoardSize;
+(float)playerBoardFontSize;

+(CGPoint)leftBoardPosition;
+(CGPoint)selfBoardPosition;
+(CGPoint)rightBoardPosition;
+(CGPoint)upBoardPosition;

+(float)watcherSize;

+(float)floatInfoFontSize;

+(CGRect)leftFloatRect;
+(CGRect)selfFloatRect;
+(CGRect)rightFloatRect;
+(CGRect)upFloatRect;

+(CGRect)cmdPannelRect;
+(float)cmdButtonWidth;

+(CGPoint)playerWatcherPoint:(char)direction;

+(CGPoint)lanImagePosition;
+(CGPoint)gamecenterImagePostion;
+(float)sizeOfModeImage;

+(float)resultNameWidth;
+(float)resultTotalScoreWidth;
+(float)resultRoundScoreWidth;
+(float)resultCellHeight;
+(float)resultFontSize;

+(float)optionViewWidth;
+(float)optionViewSpace;
+(float)optionViewFontSize;
+(float)optionViewCloseButtonSize;
+(float)optionViewSliderHeight;
+(float)optionViewBkGroundButtonSize;

+(float)mainViewCmdButtonHeight;


@end
