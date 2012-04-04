//
//  G4DDZAudioManager.h
//  DDZ
//
//  Created by gyf on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "G4DDZRuler.h"

@interface G4DDZAudioManager : NSObject<AVAudioPlayerDelegate>
{
@private
    AVAudioPlayer* _backgroundMusicPlayer;
    AVAudioPlayer* _timeCountPlayer;
    char _backgroundMusicVolumn;
}

@property(nonatomic)char backgroundMusicVolumn;

+(G4DDZAudioManager*)sharedManager;

-(void)releaseManager;

-(void)playBackgroundMusic;
-(void)playTimeCountMusic:(BOOL)play;

-(void)playCardAudio:(CARD_ANALYZE_DATA*)data;

-(void)dealloc;

-(void)changeBackgroundMusicVolumnTo:(char)volumn;

-(void)readMusicVolumn;
-(void)writeMusicVolumn;


@end
