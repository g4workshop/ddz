//
//  G4DeckCard.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define COUNT_OF_CARD       54
#define COUNT_OF_RAND_POSITION      6
#define COUNT_OF_SWAP           64

//#define CARD_TYPE_HEART     0
//#define CARD_TYPE_CLUB      1
//#define CARD_TYPE_DIAMOND   2
//#define CARD_TYPE_SPADE     3

#define PLAYER_COUNT        4

#import <Foundation/Foundation.h>

@interface G4DeckCard : NSObject
{
@private
    char* _cardNumbers;
    char _countOfDeck;
    char _dealingPos;
}

-(id)init:(char)countOfDeck;
+(void)shuffle:(char*)cardNumber;
-(void)shuffle;
-(char)dealCard;
-(BOOL)hasCard;
-(void)dealloc;
-(char*)getCardNumber;
-(int)getCount;

@end
