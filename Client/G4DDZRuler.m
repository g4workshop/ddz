//
//  G4DDZRuler.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4DDZRuler.h"
#import "G4GamePlayer.h"

char _get_card_number_continues_step_max_count(char* card_number, char count)
{
    char max_count = 0;
    char current_count = 0;
    for(char i = 1; i < count; i++)
    {
        if(card_number[i] == card_number[i - 1] + 1)
            current_count++;
        else
        {
            if(current_count > max_count)
                max_count = current_count;
            current_count = 0;
        }
    }
    if(max_count < current_count)
        max_count = current_count;
    return max_count + 1;
}

@implementation G4DDZRuler

+(int)comparePokerCard:(G4PokerCard*)card1:(G4PokerCard*)card2
{
    if(card1.cardNumber < card2.cardNumber)
    {
        if([card1 cardDigit] == 0 && [card2 cardDigit] != 13)
            return 1;
        return -1;
    }
    else if(card1.cardNumber == card2.cardNumber)
        return 0;
    else
    {
        if([card2 cardDigit] == 0 && [card1 cardDigit] != 13)
            return -1;
        return 1;
    }
}

+(void)cardOutType:(char*)cardNumbers:(char)count:(CARD_ANALYZE_RESULT*)result
{
    char outcard[15];
    
    for(int i = 0; i < 15; i++)
        outcard[i] = 0;
    for(int i = 0; i < count; i++)
    {
        char cardDigit = cardNumbers[i] / 4;
        if(cardDigit < 13)
            outcard[cardDigit]++;
        else if(cardDigit == 13)
        {
            if(cardNumbers[i] == 52)
                outcard[13]++;
            else
                outcard[14]++;
        }
    }
    
    char single_count = 0;
    char double_count = 0;
    char three_count = 0;
    char four_count = 0;
    char single_card[13];
    char double_card[13];
    char three_card[13];
    char four_digit;
    for(char i = 0; i < 13; i++)  //先不考虑王
    {
        if(outcard[i] == 1)  //单张
            single_card[single_count++] = i;
        else if(outcard[i] == 2)
            double_card[double_count++] = i;
        else if(outcard[i] == 3)
            three_card[three_count++] = i;
        else if(outcard[i] >= 4)
        {
            if(single_count + double_count + three_count + four_count > 0)
            {
                result->_analyzeResult = CARD_INVALID;
                return;  //炸弹不能带其他的
            }
            else
            {
                four_digit = i;
                four_count = 1;
            }
        }
    }
    char general_count = single_count + double_count + three_count + four_count;
    if(general_count != 0 && (outcard[13] != 0 || outcard[14] != 0))
    {
        result->_analyzeResult = CARD_INVALID;
        return;  //王不能跟其他牌一起出
    }
    if(general_count == 0)  //没有除王以外的牌
    {
        if(outcard[13] == 2 && outcard[14] == 2)  //王炸
        {
            result->_minDigit = 20;
            result->_analyzeResult = CARD_JOKER_BOMB;
            return;
        }
        if(outcard[13] != 0 && outcard[14] != 0)  //大小王都有，不能出
        {
            result->_analyzeResult = CARD_INVALID;
            return;
        }
        if(outcard[13] == 1 || outcard[14] == 1)
        {
            if(outcard[13] == 1)
                result->_minDigit = 18;
            else
                result->_minDigit = 19;
            result->_analyzeResult = CARD_SINGLE;
            return;  //单张王
        }
        if(outcard[13] == 2 || outcard[14] == 2) 
        {
            if(outcard[13] == 2)
                result->_minDigit = 18;
            else
                result->_minDigit = 19;
            result->_analyzeResult = CARD_DOUBLE;
            return;  //双张王
        }
        result->_analyzeResult = CARD_INVALID;
        return;  //没有牌
    }
    if(four_count > 0)
    {
        if(single_count + double_count + three_count > 0)
        {
            result->_analyzeResult = CARD_INVALID;
            return;  //炸弹不能带其他牌
        }
        result->_minDigit = four_digit;
        result->_cardCount = outcard[four_digit];
        result->_analyzeResult = CARD_BOMB;
        return;
    }
    if(three_count > 0)
    {
        if(single_count > 0)
        {
            result->_analyzeResult = CARD_INVALID;
            return ; //三不能拖一
        }
        if(double_count == 0)  //没有对子
        {
            if(three_count == 1)
            {
                result->_minDigit = three_card[0];
                result->_analyzeResult = CARD_THREE;
                return ;  //三张
            }
            else
            {
                if(_get_card_number_continues_step_max_count(three_card, three_count) == three_count)
                {
                    result->_minDigit = three_card[0];
                    result->_analyzeResult = CARD_PLANE;
                    return ;
                }
                else
                {
                    result->_analyzeResult = CARD_INVALID;
                    return ;
                }
            }
        }
        else
        {
            if(double_count != three_count)  //三带对必须相等
            {
                result->_analyzeResult = CARD_INVALID;
                return ;  
            }
            if(three_count == 1)
            {
                result->_minDigit = three_card[0];
                result->_otherDigit = double_card[0];
                result->_analyzeResult = CARD_THREE_DOUBLE;
                return ;  //三带俩
            }
            else if(three_count == 2)
            {
                result->_analyzeResult = CARD_INVALID;
                return ;   //两个三不行
            }
            else
            {
                if(_get_card_number_continues_step_max_count(three_card, three_count) != three_count)  //三张必须是连着的
                {
                    result->_analyzeResult = CARD_INVALID;
                    return ;
                }
                if(_get_card_number_continues_step_max_count(double_card, double_count) < double_count - 1)
                {
                    result->_analyzeResult = CARD_INVALID;
                    return ;  //必须只能有一个对子不是连对
                }
                result->_minDigit = three_card[0];
                if(double_card[0] == 0)
                    result->_otherDigit = double_card[1];
                else
                    result->_otherDigit = double_card[0];
                result->_analyzeResult = CARD_PLANE_DOUBLE;
                return ;  //飞机
            }
        }
    }
    if(double_count > 0)
    {
        if(single_count > 0)
        {
            result->_analyzeResult = CARD_INVALID;
            return ;  //对子不能带一张
        }
        if(double_count == 1)
        {
            result->_minDigit = double_card[0];
            result->_analyzeResult = CARD_DOUBLE;
            return ;  //对子
        }
        else if(double_count == 2)  //两对不能出
        {
            result->_analyzeResult = CARD_INVALID;
            return ;
        }
        else if(outcard[0] != 0)
        {
            result->_analyzeResult = CARD_INVALID;
            return ;   //2不能连对
        }
        else
        {
            if(_get_card_number_continues_step_max_count(double_card, double_count) != double_count)
            {
                result->_analyzeResult = CARD_INVALID;
                return ;  //不是连对
            }
            else
            {
                result->_minDigit = double_card[0];
                result->_analyzeResult = CARD_DOUBLE_3;
                return ;  //连对
            }
        }
    }
    if(single_count > 0)
    {
        if(single_count == 1)
        {
            result->_minDigit = single_card[0];
            result->_analyzeResult = CARD_SINGLE;
            return ; //单张牌
        }
        if(outcard[0] != 0)
        {
            result->_analyzeResult = CARD_INVALID;
            return;  //2不能连对
        }
        if(single_count < 5)
        {
            result->_analyzeResult = CARD_INVALID;
            return ;  //顺子不能少于5个
        }
        if(_get_card_number_continues_step_max_count(single_card, single_count) != single_count)
        {
            result->_analyzeResult = CARD_INVALID;
            return ;  //顺子不连续
        }
        else
        {
            result->_minDigit = single_card[0];
            result->_cardCount = single_count;
            result->_analyzeResult = CARD_STRAIGHT;
            return ;  //顺子
        }
    }
    result->_analyzeResult = CARD_INVALID;
    return ;
}

+(void)analyzeCard:(CARD_ANALYZE_DATA*)data
{
    CARD_ANALYZE_RESULT outedResult;
    outedResult._analyzeResult = CARD_INVALID;
    if(data->_outedCount != 0)
        [G4DDZRuler cardOutType:data->_cardOuted :data->_outedCount :&outedResult];
    [G4DDZRuler cardOutType:data->_cardSelected :data->_selectedCount :&data->_result];
    if(data->_outedCount == 0)
        return;
    if(data->_result._analyzeResult == CARD_INVALID)
        return;
    if(outedResult._analyzeResult != data->_result._analyzeResult)
    {
        if(outedResult._analyzeResult == CARD_JOKER_BOMB)
        {
            data->_result._analyzeResult = CARD_INVALID;
            return;
        }
        if(outedResult._analyzeResult != CARD_BOMB && (data->_result._analyzeResult == CARD_BOMB || data->_result._analyzeResult == CARD_JOKER_BOMB))
            return;
        data->_result._analyzeResult = CARD_INVALID;
        return;
    }
    if(outedResult._minDigit == 0)
        outedResult._minDigit = 17;
    if(outedResult._otherDigit == 0)
        outedResult._otherDigit = 17;
    if(data->_result._minDigit == 0)
        data->_result._minDigit = 17;
    if(data->_result._otherDigit == 0)
        data->_result._otherDigit = 17;
    
    if(outedResult._analyzeResult == CARD_BOMB)
    {
        if(outedResult._cardCount == data->_result._cardCount)
        {
            if(outedResult._minDigit >= data->_result._minDigit)
            {
                data->_result._analyzeResult = CARD_INVALID;
                return;
            }
            else
                return;
        }
        else if(outedResult._cardCount < data->_result._cardCount)
            return;
        else
        {
            data->_result._analyzeResult = CARD_INVALID;
            return;
        }
    }
    if(outedResult._minDigit >= data->_result._minDigit)
    {
        data->_result._analyzeResult = CARD_INVALID;
        return;
    }
    if(outedResult._analyzeResult == CARD_PLANE_DOUBLE || outedResult._analyzeResult == CARD_THREE_DOUBLE)
    {
        if(outedResult._otherDigit >= data->_result._otherDigit)
        {
            data->_result._analyzeResult = CARD_INVALID;
            return;
        }
    }
    if(outedResult._analyzeResult == CARD_STRAIGHT)
    {
        if(outedResult._cardCount != data->_result._cardCount)
        {
            data->_result._analyzeResult = CARD_INVALID;
            return;
        }
    }
}

+(void)calcCardCount:(CARD_ANALYZE_DATA*)data
{
    for(int i = 0; i < 15; i++)
        data->_count_info._cardCount[i] = 0;
    for(int i = 0; i < data->_totalCount; i++)
    {
        char cardDigit = data->_cardTotal[i] / 4;
        if(cardDigit < 13)
            data->_count_info._cardCount[cardDigit]++;
        else if(cardDigit == 13)
        {
            if(data->_cardTotal[i] == 52)
                data->_count_info._cardCount[13]++;
            else
                data->_count_info._cardCount[14]++;
        }
    }
}

+(char)calcQDZScore:(CARD_ANALYZE_DATA*)data:(char)currentScore
{
    [G4DDZRuler calcCardCount:data];
    char bomb_count = 0;
    for(char i = 0; i < 13; i++)
    {
        if(data->_count_info._cardCount[i] >= 4)
            bomb_count ++;
    }
    if(data->_count_info._cardCount[13] + data->_count_info._cardCount[14] == 4)
        bomb_count ++;
    if(bomb_count >= 3)
        return 3;
    else if(bomb_count >= 2)
        return currentScore + 1;
    return currentScore;
}

+(void)hintCard:(CARD_ANALYZE_DATA*)data
{
    [G4DDZRuler calcCardCount:data];
    if(data->_outedCount == 0)
        [G4DDZRuler hintCardWithNoOutedCard:data];
    
}

+(void)hintCardWithNoOutedCard:(CARD_ANALYZE_DATA*)data
{
    data->_selectedCount = 0;
    char index = 1;
    char count;
    for(; index < 13; index++)
    {
        count = data->_count_info._cardCount[index];
        if(count != 0 && count < 4)
            break;
    }
    if(count == 1)
    {
        [G4DDZRuler hintPerhapsStraight:data from:index];
        if(data->_selectedCount == 0)
        {
            data->_selectedCount = 1;
            data->_cardSelected[0] = index;
        }
        return;
    }
    if(count == 2)
    {
        [G4DDZRuler hintPerhapsDouble3:data from:index];
        if(data->_selectedCount == 4)
        {
            char three3 = [G4DDZRuler findThree3:data from:index + 2];
            char otherDouble = [G4DDZRuler findDouble:data from:index + 2];
            if(otherDouble < 0 && three3 > 1 && (three3 < 7 || index < 5))
            {
                if(data->_count_info._cardCount[0] >= 2 && data->_count_info._cardCount[0] <= 3)
                    otherDouble = 0;
                else if(data ->_count_info._cardCount[13] == 2)
                    otherDouble = 13;
            }
            if(three3 >=0 && otherDouble >= 0)
            {
                if(otherDouble < three3 && otherDouble != 0)
                {
                    data->_cardSelected[data->_selectedCount++] = otherDouble;
                    data->_cardSelected[data->_selectedCount++] = otherDouble;
                    for(char tmp = 0; tmp < 9; tmp++)
                        data->_cardSelected[data->_selectedCount++] = three3 + tmp / 3;
                }
                else
                {
                    for(char tmp = 0; tmp < 9; tmp++)
                        data->_cardSelected[data->_selectedCount++] = three3 + tmp / 3;
                    data->_cardSelected[data->_selectedCount++] = otherDouble;
                    data->_cardSelected[data->_selectedCount++] = otherDouble;
                }
                return;
            }
            data->_selectedCount = 2;
        }
        //do not use else if
        if(data->_selectedCount == 2)
        {
            char three = [G4DDZRuler findThree:data from:index + 1];
            if(three < 0 && index < 7)
            {
                if(data->_count_info._cardCount[0] == 3)
                    three = 0;
            }
            if(three > 0)
            {
                for(char tmp = 0; tmp < 3; tmp++)
                    data->_cardSelected[data->_selectedCount++] = three;
            }
        }
        return;            
    }
    if(count == 3)
    {
        [G4DDZRuler hintPerhapsThree3:data from:index];
        if(data->_selectedCount != 0)
        {
            char threeCount = data->_selectedCount / 3;
            char minCount = threeCount - 1;
            char double2 = [G4DDZRuler findDouble2:data from:index + 3:&minCount]; 
            if(double2 < 0)
                return;
            if(minCount < threeCount)
            {
                for(char i = 0; i < threeCount - 1; i++)
                    data->_count_info._cardCount[i + double2] = 0;
                char otherDobule = [G4DDZRuler findDouble:data from:index + 3];
                if(otherDobule < 0)
                {
                    if(index < 8)
                    {
                        if(data->_count_info._cardCount[0] == 2)
                            otherDobule = 0;
                        else if(data->_count_info._cardCount[13] == 2)
                            otherDobule = 13;
                        else
                            return;
                    }
                    else
                        return;
                }
                if(otherDobule < double2 && otherDobule != 0)
                {
                    data->_cardSelected[data->_selectedCount++] = otherDobule;
                    data->_cardSelected[data->_selectedCount++] = otherDobule;
                    for(char i = 0; i < (threeCount - 1) * 2; i++)
                        data->_cardSelected[data->_selectedCount++] = double2 + i / 2;
                }
                else
                {
                    for(char i = 0; i < (threeCount - 1) * 2; i++)
                        data->_cardSelected[data->_selectedCount++] = double2 + i / 2;  
                    data->_cardSelected[data->_selectedCount++] = otherDobule;
                    data->_cardSelected[data->_selectedCount++] = otherDobule;
                }
            }
            else
            {
                for(char i = 0; i < threeCount * 2; i++)
                    data->_cardSelected[data->_selectedCount++] = double2 + i / 2;
            }
        }
        else
        {
            char tmp;
            for(tmp = 0; tmp < 3; tmp++)
                data->_cardSelected[data->_selectedCount++] = index;
            tmp = [G4DDZRuler findDouble:data from:index + 1];
            if(tmp < 0 && index < 8)
            {
                if(data->_count_info._cardCount[0] == 2)
                    tmp = 0;
                else if(data->_count_info._cardCount[13] == 2)
                    tmp = 13;
            }
            if(tmp < 0)
                return;
            data->_cardSelected[data->_selectedCount++] = tmp;
            data->_cardSelected[data->_selectedCount++] = tmp;
        }
        return;
    }

}

+(char)findDouble:(CARD_ANALYZE_DATA*)data from:(char)index
{
    char continueDoubleIndex[8];
    
    for(char i = 0; i < 8; i++)
        continueDoubleIndex[i] = -1;
    
    char thisFromIndex = -1;
    char thisContinueCount = 0;
    for(char i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count == 2)
        {
            if(thisFromIndex < 0)
                thisFromIndex = i;
            thisContinueCount++;
        }
        else
        {
            if(thisContinueCount >= 8)
                continue;
            if(continueDoubleIndex[thisContinueCount] < 0)
            {
                if(thisFromIndex >= 0)
                    continueDoubleIndex[thisContinueCount] = thisFromIndex;
                thisFromIndex = -1;
                thisContinueCount = 0;
            }
        }
    }
    for(char i = 1; i < 8; i++)
    {
        if(i == 3)
            continue;
        if(continueDoubleIndex[i] >= 0)
            return continueDoubleIndex[i];
    }
    return -1;
}

+(char)findDouble2:(CARD_ANALYZE_DATA*)data from:(char)index:(char*)count
{
    char i;
    char fromIndex = -1;
    for(i = index; i < 13; i++)
    {
        char cardCount = data->_count_info._cardCount[i];
        if(cardCount != 2)
        {
            if(fromIndex < 0)
                continue;
            char thisCount = i - fromIndex;
            char min = *count;
            
            if(thisCount >= min && thisCount <= min + 1)
            {
                *count = thisCount;
                return fromIndex;
            }
            if(thisCount - min - 1 >= 3)
            {
                *count = min + 1;
                return fromIndex;
            }
            if(thisCount - min >= 3)
            {
                *count = min;
                return fromIndex;
            }
            fromIndex = -1;
        }
        else
        {
            if(fromIndex < 0)
                fromIndex = i;
        }
    }
    return -1;
}

+(char)findThree:(CARD_ANALYZE_DATA*)data from:(char)index
{
    for(char i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count == 3)
            return i;
    }
    return -1;
}

+(char)findThree3:(CARD_ANALYZE_DATA*)data from:(char)index
{
    char i;
    char fromIndex = -1;
    for(i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count != 3)
        {
            fromIndex = -1;
            break;
        }
        if(fromIndex < 0)
            fromIndex = i;
    }
    if(i - fromIndex < 3)
        return -1;
    return fromIndex;
}

+(void)hintPerhapsThree3:(CARD_ANALYZE_DATA*)data from:(char)index
{
    char i;
    BOOL hasSeven = NO;
    for(i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count != 3 && count != 7)
           break;
        if(count == 7)
        {
            if(hasSeven)
                break;
            else
                hasSeven = YES;
        }
    }
    if(i - index < 3)
        return;
    for(char j = index; j < i; j++)
    {
        data->_cardSelected[data->_selectedCount++] = j;
        data->_cardSelected[data->_selectedCount++] = j;
        data->_cardSelected[data->_selectedCount++] = j;
    }
}

+(void)hintPerhapsDouble3:(CARD_ANALYZE_DATA*)data from:(char)index
{
    char i;
    char threeIndex = -1;
    for(i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count != 2)
        {
            if(count == 3 && threeIndex < 0)
                threeIndex = i;
            else
                break;
        }
    }
    if(threeIndex > 0 && i - threeIndex < 3)
        i = threeIndex;
    for(char j = index; j < i; j++)
    {
        data->_cardSelected[data->_selectedCount++] = j;
        data->_cardSelected[data->_selectedCount++] = j;
    }
}

+(void)hintPerhapsStraight:(CARD_ANALYZE_DATA*)data from:(char)index
{
    float score = 0;
    char i;
    float stepScore[15];
    char step = 0;
    float scaled[] = {1.0f,-1.3f,-1.2f,-3.0f,-0.8f,-0.3f,-0.1f,-1.4f};
    for(i = index; i < 13; i++)
    {
        char count = data->_count_info._cardCount[i];
        if(count == 0)
            break;
        score += (15 - i) * scaled[count - 1];
        stepScore[step++] = score;
    }
    data->_selectedCount = 0;
    if(step < 5)
        return;
    char maxStep = 0;
    float maxScore = 0;
    for(i = 4; i < step; i++)
    {
        if(stepScore[i] > maxScore)
        {
            maxScore = stepScore[i];
            maxStep = i;
        }
    }
    if(maxScore < 10)
        return;
    data->_selectedCount = maxStep + 1;
    for(i = 0; i <= maxStep; i++)
        data->_cardSelected[i] = index + i;
}
@end

@implementation G4CardNumbers

-(void)reset
{
    for(char i = 0; i < MAX_CARD_COUNT_BY_NUMBER; i++)
        _cardNumbers[i] = -1;
    for(char i = 0; i < MAX_CARD_COUNT_BY_TYPE; i++)
        _cardCount[i] = 0;
}

-(void)setCardNumber:(G4GamePlayer*)player
{
    [self reset];
    for(char i = 0; i < [player countOfCard]; i++)
    {
        _cardNumbers[i] = [player getCard:i];
        printf("%d ", _cardNumbers[i]);
    }
    printf("\n");
    [self calcCardCount];
}

-(void)resetIndex
{
    for(; _currIndex < MAX_CARD_COUNT_BY_TYPE; _currIndex++)
    {
        if(_cardCount[_currIndex] != 0)
            break;
    }
}

-(void)calcCardCount
{
    for(int i = 0; i < MAX_CARD_COUNT_BY_NUMBER; i++)
    {
        if(_cardNumbers[i] < 0)
            break;
        char cardDigit = _cardNumbers[i] / 4;
        if(cardDigit < 13)
            _cardCount[cardDigit]++;
        else if(cardDigit == 13)
        {
            if(_cardNumbers[i] == 52)
                _cardCount[13]++;
            else
                _cardCount[14]++;
        }
    }
    
}

@end

@implementation G4CardOut

@synthesize _result;
@synthesize _outCount;
@synthesize _minDigit1;
@synthesize _minDigit2;

-(BOOL)isSingle
{
    char count = [self getCountOfCount:1];
    if(count == 0)
        return NO;
    _minDigit1 = _currIndex;
    _outCount = count;
    if(count == 1)
        _result = CARD_SINGLE;
    else
        _result = CARD_STRAIGHT;
    return YES;
}
       
-(char)getCountOfCount:(char)count
{
    char tmpCount = 0;
    for(char i = _currIndex; i < MAX_CARD_COUNT_BY_TYPE - 2; i++)
    {
        if(_cardCount[i] != count)
            return tmpCount;
        else
            tmpCount++;
    }
    return tmpCount;
}

-(BOOL)isBomb
{
    if(_cardCount[_currIndex] < 4)
        return NO;
    _minDigit1 = _currIndex;
    _outCount = _cardCount[_currIndex];
    _result = CARD_BOMB;
    return YES;
}

-(void)setDoubleInfo
{
    char count = [self getCountOfCount:2];
    switch (count) {
        case 1:
            _oneDoubleIndex = _currIndex;
        case 0:
            _currIndex++;
            break;
        default:
            _multiDoubleIndex = _currIndex;
            _multiDoubleCount = count;
            _currIndex += count;
            break;
    }
}

-(void)setThreeInfo
{
    char count = [self getCountOfCount:3];
    switch (count) {
        case 1:
            _threeIndex = _currIndex;
        case 0:
            _currIndex++;
            break;
        default:
            _threeIndex = _currIndex;
            break;
    }
    _threeCount = count;
}

-(BOOL)isJokerBomb
{
    if(_cardCount[13] + _cardCount[14] == 4)
    {
        _result = CARD_BOMB;
        _minDigit1 = 13;
        _outCount = 8;
        return  YES;
    }
    return NO;
}

-(void)analyze
{
    [super resetIndex];
    _result = CARD_INVALID;

    if([self isJokerBomb])
        return;
    
    while(_currIndex < MAX_CARD_COUNT_BY_TYPE)
    {
        if(_cardCount[_currIndex] == 0)
        {
            _currIndex++;
            continue;
        }
        if([self isSingle])
            break;
        if([self isBomb])
            break;
        [self setDoubleInfo];
        [self setThreeInfo];
    }
    [self setResult];
}

-(void)setThree1
{
    _minDigit1 = _threeIndex;
    if(_oneDoubleIndex >= 0)
    {
        _result = CARD_THREE_DOUBLE;
        _outCount = 5;
        _minDigit2 = _oneDoubleIndex;
    }
    else
    {
        _result = CARD_THREE;
        _outCount = 3;
    }
}

-(void)setThreeMulti
{
    _minDigit1 = _threeIndex;
    if(_oneDoubleIndex >= 0 || _multiDoubleIndex >= 0)
    {
        _result = CARD_PLANE_DOUBLE;
        _outCount = _threeCount * 5;
        _minDigit2 = (_oneDoubleIndex < _multiDoubleIndex && _oneDoubleIndex > 0)?_oneDoubleIndex : _multiDoubleIndex;
    }
    else
    {
        _result = CARD_PLANE;
        _outCount = _threeCount * 3;
    }
}

-(void)setResult
{
    if(_threeCount == 1)
    {
        [self setThree1];
        return;
    }
    else if(_threeCount > 1)
    {
        [self setThreeMulti];
        return;
    }
    else
        [self setDouble];
}

-(void)setDouble
{
    if(_oneDoubleIndex >= 0)
    {
        _result = CARD_DOUBLE;
        _outCount = 2;
        _minDigit1 = _oneDoubleIndex;
    }
    else
    {
        _result = CARD_DOUBLE_3;
        _outCount = _multiDoubleCount * 2;
        _minDigit1 = _multiDoubleIndex;
    }
}

@end

@implementation G4CardTotal

@synthesize _sentry;
@synthesize _dzCardCount;
@synthesize _tryOut;

-(void)reset
{
    [super reset];
    for(char i = 0; i < MAX_CARD_COUNT_BY_TYPE; i++)
    {
        _doubleContinueIndex[i] = -1;
        _ThreeContinueIndex[i] = -1;
    }
    _bombCount = 0;
}

-(void)setCardNumber:(G4GamePlayer *)player
{
    [super setCardNumber:player];
}

-(void)calcDoubleContinue
{
    for(char i = 0; i < MAX_CARD_COUNT_BY_TYPE; i++)
        _doubleContinueIndex[i] = -1;
    [self calcContinue:_doubleContinueIndex :2];
}

-(void)calcThreeContinue
{
    for(char i = 0; i < MAX_CARD_COUNT_BY_TYPE; i++)
        _ThreeContinueIndex[i] = -1;
    [self calcContinue:_ThreeContinueIndex :3];
}

-(void)calcContinue:(char*)continueIndex:(char)count
{
    char thisFromIndex = -1;
    char thisContinueCount = 0;
    for(char i = _currIndex; i < MAX_CARD_COUNT_BY_TYPE - 2; i++)
    {
        char cardCount = _cardCount[i];
        if(cardCount == count)
        {
            if(thisFromIndex < 0)
                thisFromIndex = i;
            thisContinueCount++;
        }
        else
        {
            if(continueIndex[thisContinueCount] < 0)
            {
                if(thisFromIndex >= 0)
                    continueIndex[thisContinueCount] = thisFromIndex;
                thisFromIndex = -1;
                thisContinueCount = 0;
            }
        }
    }
    if(thisFromIndex >= 0)
        continueIndex[thisContinueCount] = thisFromIndex;
    if(continueIndex[1] < 0 && _cardCount[0] == count)
        continueIndex[1] = 0;
}

-(void)calcBombCount
{
    for(char i = 0; i < MAX_CARD_COUNT_BY_TYPE - 2; i++)
    {
        if(_cardCount[i] >= 4)
            _bombCount ++;
    }
    if(_cardCount[MAX_CARD_COUNT_BY_TYPE - 2] + _cardCount[MAX_CARD_COUNT_BY_TYPE - 1] == 4)
        _bombCount++;
}

-(char)calcQDZScore:(char)currentScore
{
    [self calcBombCount];
    if(_bombCount >= 3)
        return 3;
    else if(_bombCount >= 2)
        return currentScore + 1;
    return currentScore;
}

-(void)resetIndex
{
    for(_currIndex = 1; _currIndex < GENERAL_CARD_COUNT_BY_TYPE; _currIndex++)
        if(_cardCount[_currIndex])
            return;
    if(_cardCount[0])
    {
        _currIndex = 0;
        return;
    }
    for(_currIndex = 13; _currIndex < MAX_CARD_COUNT_BY_TYPE; _currIndex++)
        if(_cardCount[_currIndex])
            return;
}

-(void)hintCard
{
    [self resetIndex];
    _hintCount = 0;
    if(!self._sentry)
    {
        while(_currIndex < GENERAL_CARD_COUNT_BY_TYPE)
        {
            if(_cardCount[_currIndex] == 1)
                return [self hintSingle];
            else if(_cardCount[_currIndex] == 2)
                return [self hintDouble];
            else if(_cardCount[_currIndex] == 3)
                return [self hintThree];
            _currIndex++;
        }
        if([self hint2] || [self hintJoker])
            return;
        [self hintBomb];
    }
}

-(void)hint
{
    [self hintCard];
    [self setHintNumbers];
}

-(void)setHintNumbers
{
    char count = 0;

//    [self reset];
//    char tmp_hit[] = {0,0,0,0,0};
//    char tmp_card[] = {2,1,3,0,0};
//    
//    memcpy(_hintCard, tmp_hit, 5);
//    memcpy(_cardNumbers, tmp_card, 5);
//    _hintCount = 5;
    
    for(char i = 0; i < MAX_CARD_COUNT_BY_NUMBER; i++)
    {
        _hintNumber[i] = -1;
        if(_cardNumbers[i] >= 0)
            count++;
    }
    for(char i = 0; i < count; i++)
    {
        for(char j = 0; j < _hintCount; j++)
        {
            if(_hintNumber[j] >= 0)
                continue;
            if(_hintCard[j] == (_cardNumbers[i] / 4))
            {
                _hintNumber[j] = _cardNumbers[i];
                _cardNumbers[i] = -1;
                break;
            }
        }
    }
}

-(void)hintSingle
{
    float score = 0;
    char i;
    float stepScore[15];
    char step = 0;
    float scaled[] = {1.0f,-1.3f,-1.2f,-3.0f,-0.8f,-0.3f,-0.1f,-1.4f};
    for(i = _currIndex; i < GENERAL_CARD_COUNT_BY_TYPE; i++)
    {
        char count = _cardCount[i];
        if(count == 0)
            break;
        score += (15 - i) * scaled[count - 1];
        stepScore[step++] = score;
    }
    _hintCount = 1;
    _hintCard[0] = _currIndex;
    if(step < 5)
        return;
    char maxStep = 0;
    float maxScore = 0;
    for(i = 4; i < step; i++)
    {
        if(stepScore[i] > maxScore)
        {
            maxScore = stepScore[i];
            maxStep = i;
        }
    }
    if(maxScore < 10)
        return;
    _hintCount= maxStep + 1;
    for(i = 0; i <= maxStep; i++)
        _hintCard[i] = _currIndex + i;
}

-(char)calcContinueCount:(char)count
{
    char continueCount = 0;
    while(_cardCount[_currIndex + continueCount] == count && _currIndex + continueCount < GENERAL_CARD_COUNT_BY_TYPE)
        continueCount++;
    return continueCount;
}

//只有一对
-(void)hintDoubleContinue1:(char)index
{
    char threeIndex = -1;
    if(_ThreeContinueIndex[1] >= 0)  //找一个三条
    {
        if(_ThreeContinueIndex[2] >= 0)
        {
            threeIndex = (_ThreeContinueIndex[1] < _ThreeContinueIndex[2] && _ThreeContinueIndex[1] != 0)?_ThreeContinueIndex[1] : _ThreeContinueIndex[2];
        }
        else
            threeIndex = _ThreeContinueIndex[1];
    }
    else if(_ThreeContinueIndex[2] >= 0)  //或者两个三条，拿出一个
        threeIndex = _ThreeContinueIndex[2];
    else
    {
        for(char i = 4; i < 11; i++)    //或者从4个以上的三条中拿出一个
        {
            if(_ThreeContinueIndex[i] >= 0)
            {
                threeIndex = _ThreeContinueIndex[i];
                break;
            }
        }
    }
    [self putHintCard:2 :1 :index];
    if(threeIndex < 0)
        return;
    [self putHintCard:3 :1 :threeIndex];
}

//两对
-(void)hintDoubleContinue2:(char)index
{
    char threeIndex = -1;
    if(_ThreeContinueIndex[3] >= 0)         //找三个三条
        threeIndex = _ThreeContinueIndex[3];
    else
    {
        for(char i = 6; i < 11; i++)   //或者从6个三条以上中拿出三个出来，可能有6个三条连一起么？
        {
            if(_ThreeContinueIndex[i] >= 0)
            {
                threeIndex = _ThreeContinueIndex[i];
                break;
            }
        }
    }
    if(threeIndex < 0)         //找不到，只能按照一个连对处理
    {
        [self hintDoubleContinue1:index];
        return;
    }
//还差一对
    char otherDouble = [self findSingleDouble:-1];
     if(otherDouble < 0)  //找不到？这么倒霉
    {
        [self hintDoubleContinue1:index];
        return;
    }
    [self putHintCard:2 :2 :index];
    if(otherDouble < threeIndex && otherDouble != 0)
    {
        [self putHintCard:2 :1 :otherDouble];
        [self putHintCard:3 :3 :threeIndex];      
    }
    else
    {
        [self putHintCard:3 :3 :threeIndex]; 
        [self putHintCard:2 :1 :otherDouble];
    }
}

-(char)findSingleDouble:(char)exclueseIdx
{
    char otherDouble = -1;
    if(_doubleContinueIndex[1] >= 0 && exclueseIdx != 1)
    {
        if(_doubleContinueIndex[2] >= 0 && exclueseIdx != 2)
        {
            otherDouble = (_doubleContinueIndex[1] < _doubleContinueIndex[2] && _doubleContinueIndex[1] != 0)?_doubleContinueIndex[1] : _doubleContinueIndex[2];
        }
        else
            otherDouble = _doubleContinueIndex[1];
    }
    else if(_doubleContinueIndex[2] >= 0 && exclueseIdx != 2)  //两连对直接拿出一对
        otherDouble = _doubleContinueIndex[2];
    else
    {
        for(char i = 4; i < 11; i++)  //从4连对中拆出一对
        {
            if(_doubleContinueIndex[i] >= 0 && i != exclueseIdx) 
            {
                otherDouble = _doubleContinueIndex[i];
                break;
            }
        }
    }
    return otherDouble;
}

-(void)hintDoubleContinue3:(char)count:(char)index
{
    char threeIndex = -1;
    if(_ThreeContinueIndex[count] >= 0)
        threeIndex = _ThreeContinueIndex[count];
    if(threeIndex < 0)
    {
        for(char i = count + 3; i < 11; i++)
        {
            if(_ThreeContinueIndex[i] >= 0)
            {
                threeIndex = i;
                break;
            }
        }
    }
    [self putHintCard:2 :count :index];
    if(threeIndex >= 0)
    {
        [self putHintCard:3 :count :threeIndex];
        return;
    }
    
    if(_ThreeContinueIndex[count + 1] >= 0)  //试着找多一个三连
        threeIndex = _ThreeContinueIndex[count + 1];
    if(threeIndex < 0)
    {
        for(char i = count + 4; i < 11; i++)
        {
            if(_ThreeContinueIndex[i] >= 0)
            {
                threeIndex = i;
                break;
            }
        }
    }
    char otherDouble = [self findSingleDouble:-1];

    if(threeIndex < 0 || otherDouble < 0)  //连对
        return;
    
    if(otherDouble < threeIndex && otherDouble != 0)
    {
        [self putHintCard:2 :1 :otherDouble];
        [self putHintCard:3 :count + 1:threeIndex];      
    }
    else
    {
        [self putHintCard:3 :count + 1:threeIndex]; 
        [self putHintCard:2 :1 :otherDouble];
    }
}

-(void)hintDouble
{
    char continueCount = [self calcContinueCount:2];
    char recordIndex = _currIndex;
    _currIndex += continueCount;
    [self calcThreeContinue];
    [self calcDoubleContinue];
    if(continueCount == 1)
        [self hintDoubleContinue1:recordIndex];
    else if(continueCount == 2)
        [self hintDoubleContinue2:recordIndex];
    else
        [self hintDoubleContinue3:continueCount:recordIndex];
}

-(void)putHintCard:(char)count:(char)cardCount:(char)index
{
    for(char i = 0; i < count * cardCount; i++)
        _hintCard[_hintCount++] = index + i / count;
}

-(void)hintThree
{
    char continueCount = [self calcContinueCount:3];
    char recordIndex = _currIndex;
    _currIndex += continueCount;
    [self calcThreeContinue];
    [self calcDoubleContinue];
    if(continueCount == 1 || continueCount == 2)
    {
        [self putHintCard:3 :1 :recordIndex];
        char d = [self findSingleDouble:-1];
        if(d >= 0)
            [self putHintCard:2 :1 :d];
        return;
    }
    [self putHintCard:3 :continueCount :recordIndex];

    
    char doubleIndex = -1;
    if(_doubleContinueIndex[continueCount - 1] >= 0)
        doubleIndex = _doubleContinueIndex[continueCount - 1];
    char otherDouble = [self findSingleDouble:continueCount - 1];
    
    if(doubleIndex >= 0 && otherDouble >= 0)
    {
        if(otherDouble > doubleIndex)
        {
            [self putHintCard:2 :continueCount - 1 :doubleIndex];
            [self putHintCard:2 :1 :otherDouble];
        }
        else
        {
            [self putHintCard:2 :1 :otherDouble];
            [self putHintCard:2 :continueCount - 1 :doubleIndex];
        }
        return;
    }
    if(_doubleContinueIndex[continueCount] >= 0)
        doubleIndex = _doubleContinueIndex[continueCount];
    if(doubleIndex >= 0)
        [self putHintCard:2 :continueCount :doubleIndex];
}

-(void)hintBomb
{
    char minBombIndex[6];
    for(char i = 0; i < 6; i++)
        minBombIndex[i] = -1;
    
    for(char i = 1; i < GENERAL_CARD_COUNT_BY_TYPE; i++)
    {
        if(_cardCount[i] >= 4)
        {
            if(minBombIndex[_cardCount[i] - 4] < 0)
                minBombIndex[_cardCount[i] - 4] = i;
        }
    }
    if(_cardCount[0] >= 4 && (minBombIndex[_cardCount[0] - 4] < 0))
            minBombIndex[_cardCount[0] - 4] = 0;
    if([self hasJokerBomb])
        minBombIndex[5] = 13;
    
    for(char i = 0; i < 5; i++)
    {
        if(minBombIndex[i] >= 0)
        {
            for(char j = 0; j < i + 4; j++)
                _hintCard[j] = minBombIndex[i];
            _hintCount = i + 4;
            return;
        }
    }
    if(minBombIndex[5] > 0)
    {
        for(char i = 0; i < 4; i++)
            _hintCard[i] = 13;
        _hintCount = 4;
    }
}

-(BOOL)hasJokerBomb
{
    return (_cardCount[13] + _cardCount[14] == 4);
}

-(BOOL)hint2
{
    if(_cardCount[0] >= 4)
        return NO;
    for(char i = 0; i < _cardCount[0]; i++)
        _hintCard[i] = 0;
    _hintCount = _cardCount[0];
    return _hintCount != 0;
}

-(BOOL)hintJoker
{
    if([self hasJokerBomb])
        return NO;
    for(char i = 0; i < _cardCount[13]; i++)
        _hintCard[i] = 13;
    _hintCount = _cardCount[13];
    if(_hintCount != 0)
        return YES;
    for(char i = 0; i < _cardCount[14]; i++)
        _hintCard[i] = 13;
    _hintCount = _cardCount[14];
    return _hintCount != 0;
}

-(char)getHintCount
{
    return _hintCount;
}

-(char*)getHintCard
{
    return _hintCard;
}

-(char*)getHintNumbers
{
    return _hintNumber;
}
@end
