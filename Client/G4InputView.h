//
//  G4InputView.h
//  DDZ
//
//  Created by gyf on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G4InputView : NSObject
{
@private
    UIAlertView* _alertView;
    UITextField* _textField;
}

-(id)init:(NSString*)text;
-(void)show;
-(void)dealloc;

@end
