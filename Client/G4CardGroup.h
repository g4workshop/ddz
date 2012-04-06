//
//  G4CardGroup.h
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G4PokerCard.h"
#import "G4DDZRuler.h"


@protocol G4CardGroupDelegate <NSObject>

-(void)didShowed;

@end

@interface G4CardGroup : NSObject
{
@private
    NSMutableArray* _cardArray;
    CALayer* _superLayer;
    CABasicAnimation* _animationShow;
    CABasicAnimation* _animationSort;
    CALayer* _groupLayer;
    float _cardShowWidth;
    CGRect _frame;
}

@property(nonatomic)char playerId;
@property(nonatomic)char maxCardCount;
@property(nonatomic,assign)NSObject<G4CardGroupDelegate>* delegate;

-(id)initWithSuperLayer:(CALayer*)superLayer andFrame:(CGRect)frame;
-(void)dealloc;
-(float)addPokerCard:(char)cardNumber;
-(void)addPokerCard:(NSMutableArray*)cardArray:(G4PokerCard *)card;
-(void)rmvPokerCard:(char)cardNumber;
-(void)sortCards;
-(BOOL)isReachMaxCardCount;
-(float)layoutCards;
-(void)layoutCardsNeedCalcNewCardShowWidth;
-(void)animationFrom:(float)from:(float)to:(float)duration;
-(void)setMaxCardCount:(char)max;
-(void)calcCardShowWidth:(char)count;
-(void)cardSwitchSelect:(CGPoint)point;
-(void)unSelectAllCard;
-(float)getGroupCenterX;
-(float)getFirstSelectX;
-(void)show:(char)fromIndex:(BOOL)animation;
-(void)sort:(BOOL)animation;
-(void)hide;
-(void)copyCardImage;
-(void)showAnimationStopped:(char)index;
-(void)sortAnimationStopped:(char)state;
-(void)animationShow:(char)index;
-(void)animationSort:(char)state;
-(BOOL)yInvalid:(float)y;
-(void)selectCard:(BOOL)select fromIndex:(char)fromIndex toIndex:(char)toIndex;
-(char)indexOfCardByX:(float)x;

-(void)getSelectedCard:(CARD_ANALYZE_DATA*)data;
-(void)getTotalCard:(CARD_ANALYZE_DATA*)data;
-(void)selectCard:(G4CardTotal*)total;

@end


