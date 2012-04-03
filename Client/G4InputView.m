//
//  G4InputView.m
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4InputView.h"
#import "G4ViewController.h"
#import "G4GameInit.h"

@implementation G4InputView

-(id)init:(NSString*)text
{
    if(self = [super init])
    {
        _alertView = [[UIAlertView alloc]initWithTitle:@"请输入您的昵称" 
                                                      message:@"\n\n"
                                                     delegate:self   
                                            cancelButtonTitle:nil 
                                            otherButtonTitles:@"确定",nil];
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 45.0, 230.0, 25.0)]; 
        [_textField setBackgroundColor:[UIColor whiteColor]];
        [_textField setPlaceholder:@"昵称"];
        [_textField setText:text];
        [_alertView addSubview:_textField];
       // [_alertView setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];
        return self;
    }
    return nil;
}

-(void)show
{
    [_alertView show];
    [_textField becomeFirstResponder];
//    NSArray* array = _alertView.subviews;
//    for(UIView* view in array)
//    {
//        NSLog(@"%@=%@\n", view, [view class]);
//    }
}

-(void)dealloc
{
    [_alertView release];
    [_textField release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    G4ViewController* controller = (G4ViewController*) [UIApplication sharedApplication].delegate.window.rootViewController;
    [controller playerNameGetted:_textField.text];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{

}

@end
