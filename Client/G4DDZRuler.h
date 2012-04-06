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
    CARD_ANALYZE_RESULT _result;
    CARD_COUNT_INFO _count_info;
}CARD_ANALYZE_DATA;

@interface G4DDZRuler : NSObject
    

+(int)comparePokerCard:(G4PokerCard*)card1:(G4PokerCard*)card2;

+(void)cardOutType:(char*)cardNumbers:(char)count:(CARD_ANALYZE_RESULT*)result;

//根据上家出的牌和自己选择的牌来做出提示  
+(void)analyzeCard:(CARD_ANALYZE_DATA*)data;

+(void)hintCard:(CARD_ANALYZE_DATA*)data;
+(void)hintCardWithNoOutedCard:(CARD_ANALYZE_DATA*)data;
+(void)hintPerhapsStraight:(CARD_ANALYZE_DATA*)data from:(char)index;
+(void)hintPerhapsDouble3:(CARD_ANALYZE_DATA*)data from:(char)index;
+(void)hintPerhapsThree3:(CARD_ANALYZE_DATA*)data from:(char)index;
+(char)findThree3:(CARD_ANALYZE_DATA*)data from:(char)index;
+(char)findThree:(CARD_ANALYZE_DATA*)data from:(char)index;
+(char)findDouble:(CARD_ANALYZE_DATA*)data from:(char)index;
+(char)findDouble2:(CARD_ANALYZE_DATA*)data from:(char)index:(char*)count;

+(void)calcContinue:(CARD_ANALYZE_DATA*)data:(char*)continueIndex:(char)count;

+(void)calcCardCount:(CARD_ANALYZE_DATA*)data;

+(char)calcQDZScore:(CARD_ANALYZE_DATA*)data:(char)currentScore;


@end

#define MAX_CARD_COUNT_BY_NUMBER        33
#define MAX_CARD_COUNT_BY_TYPE          15
#define GENERAL_CARD_COUNT_BY_TYPE      13


@class G4GamePlayer;
@interface G4CardNumbers : NSObject 
{
@protected
    char _cardNumbers[MAX_CARD_COUNT_BY_NUMBER];
    char _cardCount[MAX_CARD_COUNT_BY_TYPE];
    char _currIndex;
}

-(void)reset;
-(void)setCardNumber:(G4GamePlayer*)player;
-(void)calcCardCount;
-(void)resetIndex;

@end

@interface G4CardOut : G4CardNumbers
{
@private
    char _oneDoubleIndex;
    char _multiDoubleIndex;
    char _multiDoubleCount;
    char _threeIndex;
    char _threeCount;
}

@property(nonatomic)char _result;
@property(nonatomic)char _outCount;
@property(nonatomic)char _minDigit1;
@property(nonatomic)char _minDigit2;

-(void)analyze;
-(BOOL)isBomb;
-(BOOL)isSingle;
-(BOOL)isJokerBomb;
-(void)setDoubleInfo;
-(void)setThreeInfo;
-(void)setResult;
-(void)setThree1;
-(void)setThreeMulti;
-(void)setDouble;


-(char)getCountOfCount:(char)count;

@end
@interface G4CardTotal : G4CardNumbers
{
@private
    char _doubleContinueIndex[MAX_CARD_COUNT_BY_TYPE];
    char _ThreeContinueIndex[MAX_CARD_COUNT_BY_TYPE];
    char _bombCount;
    char _hintCard[MAX_CARD_COUNT_BY_NUMBER];
    char _hintNumber[MAX_CARD_COUNT_BY_NUMBER];
    char _hintCount;
}

@property(nonatomic)BOOL _sentry;
@property(nonatomic)char _dzCardCount;
@property(nonatomic)BOOL _tryOut;

-(char)getHintCount;
-(char*)getHintCard;
-(char*)getHintNumbers;
-(void)reset;
-(void)setCardNumber:(G4GamePlayer *)player;
-(void)calcDoubleContinue;
-(void)calcThreeContinue;
-(void)calcContinue:(char*)continueIndex:(char)count;
-(void)calcBombCount;
-(char)calcQDZScore:(char)currentScore;
-(void)hint;
-(void)hintCard;
-(void)setHintNumbers;
-(void)hintSingle;
-(void)hintDouble;
-(void)hintDoubleContinue1:(char)index;
-(void)hintDoubleContinue2:(char)index;
-(void)hintDoubleContinue3:(char)count:(char)index;

-(void)hintThree;
-(BOOL)hint2;
-(BOOL)hintJoker;
-(void)hintBomb;
-(void)resetIndex;
-(BOOL)hasJokerBomb;
-(char)calcContinueCount:(char)count;

-(char)findSingleDouble:(char)exclueseIdx;

-(void)putHintCard:(char)count:(char)cardCount:(char)index;

@end
