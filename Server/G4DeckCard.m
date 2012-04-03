//
//  G4DeckCard.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4DeckCard.h"

@implementation G4DeckCard

-(id)init:(char)countOfDeck
{
    self = [super init];
    _countOfDeck = countOfDeck;
    _cardNumbers = (char*)malloc(sizeof(char) * COUNT_OF_CARD * _countOfDeck);
    return self;
}

#define INIT_CARD_NUM       -1

+(void)shuffle:(char*)cardNumber
{
    for(int i = 0; i < COUNT_OF_CARD; i++)
        cardNumber[i] = INIT_CARD_NUM;
    for(int i = 0; i < COUNT_OF_CARD; i++)
    {
        for(int j = 0; j < COUNT_OF_RAND_POSITION; j++)
        {
            int p = rand() % COUNT_OF_CARD;
            if(cardNumber[p] == INIT_CARD_NUM)
            {
                cardNumber[p] = i;
                break;
            }
        }
    }
    int tmp[COUNT_OF_CARD];
    for(int i = 0; i < COUNT_OF_CARD; i++)
        tmp[i] = 0;
    for(int i = 0; i < COUNT_OF_CARD; i++)
    {
        if(cardNumber[i] != INIT_CARD_NUM)
            tmp[cardNumber[i]] = 1;
    }
    /*   for(int i = 0; i < COUNT_OF_CARD; i++)
     {
     if(tmp[i] == 0)
     printf("%d ", i);
     }*/
    //    printf("\n");
    int tmpPos = 0;
    for(int i = 0; i < COUNT_OF_CARD; i++)
    {
        if(cardNumber[i] == INIT_CARD_NUM)
        {
            
            while(tmpPos < COUNT_OF_CARD)
            {
                if(tmp[tmpPos] == 0)
                    break;
                tmpPos++;
            }
            if(tmpPos == COUNT_OF_CARD)
                break;
            
            cardNumber[i] = tmpPos;
            //            printf("pos:%d is zero set to %d\n", i, number[i]);
            tmpPos++;
        }
    }
    //    for(int i = 0; i < COUNT_OF_CARD; i++)
    //        printf("%d:%d ", i, number[i]);
    for(int i = 0; i < COUNT_OF_SWAP; i++)
    {
        int pos1 = rand() % COUNT_OF_CARD;
        int pos2 = rand() % COUNT_OF_CARD;
        int tmpNumber = cardNumber[pos1];
        cardNumber[pos1] = cardNumber[pos2];
        cardNumber[pos2] = tmpNumber;
    }
    //    printf("\n");
    //    for(int i = 0; i < COUNT_OF_CARD; i++)
    //        printf("%d:%d ", i, number[i]);
}

-(void)shuffle
{
    for(char i = 0; i < _countOfDeck; i++)
        [G4DeckCard shuffle:_cardNumbers + i * COUNT_OF_CARD];
    for(char i = 0; i < COUNT_OF_SWAP; i++)
    {
        int pos1 = rand() % (_countOfDeck * COUNT_OF_CARD);
        int pos2 = rand() % (_countOfDeck * COUNT_OF_CARD);
        int tmpNumber = _cardNumbers[pos1];
        _cardNumbers[pos1] = _cardNumbers[pos2];
        _cardNumbers[pos2] = tmpNumber;
    }
}

-(char)dealCard
{
    return _cardNumbers[_dealingPos++];
}

-(BOOL)hasCard
{
    if(_dealingPos >= COUNT_OF_CARD * _countOfDeck)
        return NO;
    else
        return YES;
}

-(char*)getCardNumber
{
    return _cardNumbers;
}

-(int)getCount
{
    return _countOfDeck * COUNT_OF_CARD;
}

-(void)dealloc
{
    free(_cardNumbers);
}

@end
