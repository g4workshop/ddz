//
//  G4DDZRuler.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4DDZRuler.h"

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
    [G4DDZRuler cardOutType:data->_cardSelected :data->_selectedCount :&data->result];
    if(data->_outedCount == 0)
        return;
    if(data->result._analyzeResult == CARD_INVALID)
        return;
    if(outedResult._analyzeResult != data->result._analyzeResult)
    {
        if(outedResult._analyzeResult == CARD_JOKER_BOMB)
        {
            data->result._analyzeResult = CARD_INVALID;
            return;
        }
        if(outedResult._analyzeResult != CARD_BOMB && (data->result._analyzeResult == CARD_BOMB || data->result._analyzeResult == CARD_JOKER_BOMB))
            return;
        data->result._analyzeResult = CARD_INVALID;
        return;
    }
    if(outedResult._minDigit == 0)
        outedResult._minDigit = 17;
    if(outedResult._otherDigit == 0)
        outedResult._otherDigit = 17;
    if(data->result._minDigit == 0)
        data->result._minDigit = 17;
    if(data->result._otherDigit == 0)
        data->result._otherDigit = 17;
    
    if(outedResult._analyzeResult == CARD_BOMB)
    {
        if(outedResult._cardCount == data->result._cardCount)
        {
            if(outedResult._minDigit >= data->result._minDigit)
            {
                data->result._analyzeResult = CARD_INVALID;
                return;
            }
            else
                return;
        }
        else if(outedResult._cardCount < data->result._cardCount)
            return;
        else
        {
            data->result._analyzeResult = CARD_INVALID;
            return;
        }
    }
    if(outedResult._minDigit >= data->result._minDigit)
    {
        data->result._analyzeResult = CARD_INVALID;
        return;
    }
    if(outedResult._analyzeResult == CARD_PLANE_DOUBLE || outedResult._analyzeResult == CARD_THREE_DOUBLE)
    {
        if(outedResult._otherDigit >= data->result._otherDigit)
        {
            data->result._analyzeResult = CARD_INVALID;
            return;
        }
    }
    if(outedResult._analyzeResult == CARD_STRAIGHT)
    {
        if(outedResult._cardCount != data->result._cardCount)
        {
            data->result._analyzeResult = CARD_INVALID;
            return;
        }
    }
}

+(void)calcCardCount:(CARD_ANALYZE_DATA*)data:(CARD_COUNT_INFO*)countInfo
{
    for(int i = 0; i < 15; i++)
        countInfo->_cardCount[i] = 0;
    for(int i = 0; i < data->_totalCount; i++)
    {
        char cardDigit = data->_cardTotal[i] / 4;
        if(cardDigit < 13)
            countInfo->_cardCount[cardDigit]++;
        else if(cardDigit == 13)
        {
            if(data->_cardTotal[i] == 52)
                countInfo->_cardCount[13]++;
            else
                countInfo->_cardCount[14]++;
        }
    }
}

+(char)calcQDZScore:(CARD_ANALYZE_DATA*)data:(char)currentScore
{
    CARD_COUNT_INFO count_info;
    [G4DDZRuler calcCardCount:data :&count_info];
    char bomb_count = 0;
    for(char i = 0; i < 13; i++)
    {
        if(count_info._cardCount[i] >= 4)
            bomb_count ++;
    }
    if(count_info._cardCount[13] + count_info._cardCount[14] == 4)
        bomb_count ++;
    if(bomb_count >= 3)
        return 3;
    else if(bomb_count >= 2)
        return currentScore + 1;
    return currentScore;
}
@end
