//
//  G4DDZRuler.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4PokerCard.h"

#define CARD_INVALID            0x00
#define CARD_SINGLE             0x01   //单张牌
#define CARD_DOUBLE             0x02   //一对牌
#define CARD_DOUBLE_3           0x03   //3连对
#define CARD_STRAIGHT           0x04   //顺子
#define CARD_THREE              0x05   //三张
#define CARD_THREE_DOUBLE       0x06   //三拖二
#define CARD_BOMB               0x07   //炸弹
#define CARD_JOKER_BOMB         0x08   //王炸
#define CARD_PLANE              0x09
#define CARD_PLANE_DOUBLE       0x0a   //飞机
#define CARD_NONE               0xff

char _get_card_number_continues_step_max_count(char* card_number, char count);

typedef struct
{
    char _cardCount[15];
}CARD_COUNT_INFO;

typedef struct 
{
    char _analyzeResult;
    char _perhapsResult;
    char _minDigit;
    char _cardCount;
    char _otherDigit;
    char _shortOfCard[15];
}CARD_ANALYZE_RESULT;

typedef struct
{
    char _cardSelected[33];  //我选择的牌
    char _selectedCount;
    char _cardTotal[33];  //我所有的牌
    char _totalCount;
    char _cardOuted[33];  //上家出的牌
    char _outedCount;
    char _cardHint[33];  //提示的牌
    char _hintCount;
    BOOL _smartHint;  //是否智能提示
    CARD_ANALYZE_RESULT result;
}CARD_ANALYZE_DATA;

@interface G4DDZRuler : NSObject
    

+(int)comparePokerCard:(G4PokerCard*)card1:(G4PokerCard*)card2;

+(void)cardOutType:(char*)cardNumbers:(char)count:(CARD_ANALYZE_RESULT*)result;

//根据上家出的牌和自己选择的牌来做出提示  
+(void)analyzeCard:(CARD_ANALYZE_DATA*)data;

//+(void)hintCard:(CARD_ANALYZE_DATA*)data;

+(int)calcCardScore:(CARD_ANALYZE_DATA*)data;

+(void)calcCardCount:(CARD_ANALYZE_DATA*)data:(CARD_COUNT_INFO*)countInfo;

+(char)calcQDZScore:(CARD_ANALYZE_DATA*)data:(char)currentScore;

@end
