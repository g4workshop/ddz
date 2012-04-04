//
//  ZXViewController.m
//  Upgrade
//
//  Created by gyf on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4ViewController.h"
#import "G4CardSize.h"
#import "G4CardImage.h"
#import "G4GameFSM.h"
#import "G4Key.h"
#import "G4DDZRuler.h"
#import "G4GameInit.h"
#import "G4PokerView.h"
#import "G4DDZAudioManager.h"


@implementation G4ViewController

@synthesize _appState;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

@synthesize _image;

-(void)drawImageForTest:(UIImage *)image
{
    self._image = image;
    [self.view setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [G4CardSize setDeviceType:DEVICE_TYPE_480_320];
    else
        [G4CardSize setDeviceType:DEVICE_TYPE_1024_768];
    srand(time(NULL));
    [G4CardImage initAllImages];
            
    _gameState = G4_GAME_INITING;
    _appState = G4_DDZ_APP_STATE_SELECT_MODE;

    [self createModeWifiButton];
    [self createModeGamecenterButton];

}

-(void)changeBkgroundImage:(char)index
{   
    if(((G4PokerView*)self.view)._bkImageIndex == index)
        return;
    ((G4PokerView*)self.view)._bkImageIndex = index;
    [self.view setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseAll];
}

-(void)releaseAll
{
    [G4CardImage releaseAllImage];
    [_comm stop];
    [_comm release];
    [_waitingLayer release];
    [_adLayer release];
    [_gameManager release];
    [_deckCard release];
    [_watcher release];
    [_displayName release];
    [_cmdPannel release];
    [_resultLayer  release];
    [_cmdOptionButton release];
    [[G4DDZAudioManager sharedManager] releaseManager];
}

-(void)onCmdButtonClicked:(id)sender
{
    UIButton* cmdButton = (UIButton*)sender;
    if(cmdButton.tag == 1)
    {
        _optionView = [[G4OptionView alloc] init:self.view];
        [_optionView show:YES :10.0f];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    if(_gameState == G4_GAME_PLAYING)
    {
        if(!_moveSelect)
            [_gameManager cardSwitchSelect:pt];
        [self doEnableOutCardCmdButton];
    }
    if(_gameState == G4_GAME_WAITING_PLAYERS)
    {
        if([_waitingLayer hitTest:pt])
            [self doAddAComputerPlayer];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    if([_gameManager cardGroupYInvalid:pt.y])
    {
        _touchBeganOfCardIndex = [_gameManager indexOfCardByX:pt.x];
        _touchLastMovedOfCardIndex = -1;
        _moveSelect = NO;
  //      NSLog(@"begin index=%d\n", _touchBeganOfCardIndex);
    }
}

-(char)touchMoveDirction:(char)index1:(char)index2
{
    return index1 < index2?1:-1;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_moveSelect && _touchLastMovedOfCardIndex >= 0)
        return;
    UITouch* touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.view];
    if(![_gameManager cardGroupYInvalid:pt.y])
    {
        _moveSelect = NO;
        return;
    }
    char currentMovedIndex = [_gameManager indexOfCardByX:pt.x];
    if(_touchBeganOfCardIndex < 0 || currentMovedIndex < 0)
        return;
    
    if(_touchLastMovedOfCardIndex < 0)
    {
        if(currentMovedIndex != _touchBeganOfCardIndex)
        {
            char direction = [self touchMoveDirction:_touchBeganOfCardIndex :currentMovedIndex];
            if(direction > 0)
                [_gameManager selectCard:YES fromIndex:_touchBeganOfCardIndex toIndex:currentMovedIndex];
            else
                [_gameManager selectCard:YES fromIndex:currentMovedIndex toIndex:_touchBeganOfCardIndex];
            [self doEnableOutCardCmdButton];
            _moveSelect = YES;
            _touchLastMovedOfCardIndex = currentMovedIndex;
  //          NSLog(@"first select:%d-%d\n", _touchBeganOfCardIndex, _touchLastMovedOfCardIndex);
        }
 //       NSLog(@"first select\n");
        return;
    }
           
    
    char origDirection = [self touchMoveDirction:_touchBeganOfCardIndex :_touchLastMovedOfCardIndex];
    
    char thisDirection = [self touchMoveDirction:_touchLastMovedOfCardIndex :currentMovedIndex];
    
//    NSLog(@"origdirect:%d,thisdirect:%d,currentIndex:%d,beginIndex:%d,moveIndex:%d\n", origDirection, thisDirection, currentMovedIndex, _touchBeganOfCardIndex, _touchLastMovedOfCardIndex);
    
    if(origDirection == thisDirection)
    {
        if(origDirection > 0)
            [_gameManager selectCard:YES fromIndex:_touchLastMovedOfCardIndex toIndex:currentMovedIndex];
        else
            [_gameManager selectCard:YES fromIndex:currentMovedIndex toIndex:_touchBeganOfCardIndex];
        _touchLastMovedOfCardIndex = currentMovedIndex;
        [self doEnableOutCardCmdButton];
        return;
    }
    
    if(origDirection > 0)
    {
        if(currentMovedIndex < _touchBeganOfCardIndex)
        {
            [_gameManager selectCard:NO fromIndex:_touchBeganOfCardIndex + 1 toIndex:_touchLastMovedOfCardIndex];
            [_gameManager selectCard:YES fromIndex:currentMovedIndex toIndex:_touchBeganOfCardIndex];
        }
        else
        {
            [_gameManager selectCard:NO fromIndex:currentMovedIndex + 1 toIndex:_touchLastMovedOfCardIndex];
        }
    }
    else
    {
        if(currentMovedIndex > _touchBeganOfCardIndex)
        {
            [_gameManager selectCard:NO fromIndex:_touchLastMovedOfCardIndex toIndex:_touchBeganOfCardIndex - 1];
            [_gameManager selectCard:YES fromIndex:_touchBeganOfCardIndex toIndex:currentMovedIndex];
        }
        else
        {
            [_gameManager selectCard:NO fromIndex:_touchLastMovedOfCardIndex toIndex:currentMovedIndex - 1];
        }
    }
    _touchLastMovedOfCardIndex = currentMovedIndex;

    [self doEnableOutCardCmdButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
                && interfaceOrientation != UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
                && interfaceOrientation != UIInterfaceOrientationPortrait);
    }
    
}

int random_player_random_id(void)
{
    return rand() % (rand() % 100000);
}

-(void)createModeWifiButton
{
    CGRect buttonRect;
    buttonRect.origin = [G4CardSize lanImagePosition];
    buttonRect.size = CGSizeMake([G4CardSize sizeOfModeImage], [G4CardSize sizeOfModeImage]);
    _wifiButton = [[UIButton alloc] initWithFrame:buttonRect];
    [_wifiButton setShowsTouchWhenHighlighted:YES];
    _wifiButton.tag = 1;
    [_wifiButton setImage:[G4CardImage wifiImage] forState:UIControlStateNormal];
    [_wifiButton addTarget:self action:@selector(onButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wifiButton];    
}

-(void)createModeGamecenterButton
{
    CGRect buttonRect;
    buttonRect.origin = [G4CardSize gamecenterImagePostion];
    buttonRect.size = CGSizeMake([G4CardSize sizeOfModeImage], [G4CardSize sizeOfModeImage]);
    _gamecenterButton = [[UIButton alloc] initWithFrame:buttonRect];
    [_gamecenterButton setShowsTouchWhenHighlighted:YES];
    _gamecenterButton.tag = 2;
    [_gamecenterButton addTarget:self action:@selector(onButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_gamecenterButton setImage:[G4CardImage gamecenterImage] forState:UIControlStateNormal];
    [self.view addSubview:_gamecenterButton];
}

-(void)createCmdButtons
{
    UIImage* image = [UIImage imageNamed:@"config.png"];
    float x = [G4CardSize deviceViewSize].width - [G4CardSize edgeSpace];
    _cmdOptionButton = [[self createCmdButton:x:image] retain];
    _cmdOptionButton.tag = 1;
}

-(UIButton*)createCmdButton:(float)rightX:(UIImage*)image
{
    float scaled = [G4CardSize mainViewCmdButtonHeight] / image.size.height;
    float width = scaled * image.size.width;
    
    float x = rightX - width;
    
    float y = [G4CardSize edgeSpace];
    
    UIButton* button = [[[UIButton alloc] initWithFrame:CGRectMake(x, y, width, [G4CardSize mainViewCmdButtonHeight])] autorelease];
    
    [button setShowsTouchWhenHighlighted:YES];

    [button addTarget:self action:@selector(onCmdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    return button;
}

-(void)onButtonTouched:(id)sender
{
    [[G4DDZAudioManager sharedManager] playBackgroundMusic];
    [self createCmdButtons];
    if(((UIButton*)sender).tag == 1)
    {
        _appState = G4_DDZ_APP_STATE_WIFI_MODE;
        ((G4PokerView*)self.view)._appState = _appState;
        [self.view setNeedsDisplay];
        [self performSelector:@selector(getPlayerName)];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"抱歉" message:@"我们万分的抱歉，gamecenter模式暂时还未开放" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [_gamecenterButton removeFromSuperview];
    [_wifiButton removeFromSuperview];
    [_gamecenterButton release];
    [_wifiButton release];
}
@end
