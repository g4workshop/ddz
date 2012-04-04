//
//  G4PokerView.m
//  DDZ
//
//  Created by gyf on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4PokerView.h"
#import "G4ViewController.h"
#import "G4CardImage.h"
#import "G4CardSize.h"


@implementation G4PokerView

@synthesize _appState;
@synthesize _bkImageIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _appState = 0;
        _bkImageIndex = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* image;
    if(_appState == 0)
        image = [G4CardImage modeSelectBkImage];
    else
        image = [G4CardImage gameBKImage:_bkImageIndex];
    
    [image drawInRect:CGRectMake(0, 0, [G4CardSize deviceViewSize].width, [G4CardSize deviceViewSize].height)];

//    G4ViewController* controller = (G4ViewController*) [UIApplication sharedApplication].delegate.window.rootViewController;
//    [controller._image drawAtPoint:CGPointMake(300, 300)];
}


@end
