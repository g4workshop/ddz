//
//  G4DDZAudioManager.m
//  DDZ
//
//  Created by gyf on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "G4DDZAudioManager.h"

static G4DDZAudioManager* _audioManager = nil;

@implementation G4DDZAudioManager

@synthesize backgroundMusicVolumn = _backgroundMusicVolumn;

+(id)sharedManager
{
    @synchronized(_audioManager)
    {
        if(_audioManager == nil)
            _audioManager = [[G4DDZAudioManager alloc] init];
    }
    return _audioManager;
}

+(void)releaseManager
{
    [_audioManager release];
}

-(void)playBackgroundMusic
{
    if(_backgroundMusicPlayer == nil)
    {
        NSString* backMusicPath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];       //创建音乐文件路径
        NSURL* backMusicURL = [[NSURL alloc] initFileURLWithPath:backMusicPath];
        _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backMusicURL error:nil];
        _backgroundMusicPlayer.delegate = self;
        [backMusicURL  release];
        [self readMusicVolumn];
        _backgroundMusicPlayer.numberOfLoops = -1;
    }

    if(_backgroundMusicVolumn != 0 && ![_backgroundMusicPlayer isPlaying])
    {
        _backgroundMusicPlayer.volume = ((float)_backgroundMusicVolumn) / 10.0f;
        [_backgroundMusicPlayer prepareToPlay];
    }
}

-(void)playTimeCountMusic:(BOOL)play
{
    if(_timeCountPlayer == nil && play)
    {
        NSString* timeMusicPath = [[NSBundle mainBundle] pathForResource:@"timecount" ofType:@"mp3"];       //创建音乐文件路径
        NSURL* timeMusicURL = [[NSURL alloc] initFileURLWithPath:timeMusicPath];
        _timeCountPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:timeMusicURL error:nil];
        _timeCountPlayer.delegate = self;
        [timeMusicURL  release];
    }
    if(play)
        [_timeCountPlayer prepareToPlay];
    else if([_timeCountPlayer isPlaying])
        [_timeCountPlayer stop];
}

-(void)readMusicVolumn
{
    _backgroundMusicVolumn = 4;
}

-(void)writeMusicVolumn
{
    
}

-(void)dealloc
{
    [_backgroundMusicPlayer release];
}

-(void)playCardAudio:(CARD_ANALYZE_DATA*)data
{
    
}

-(void)changeBackgroundMusicVolumnTo:(char)volumn
{
    if(_backgroundMusicVolumn == volumn)
        return;
    _backgroundMusicVolumn = volumn;
    if(_backgroundMusicPlayer != nil)
    {
        _backgroundMusicPlayer.volume = ((float)volumn) / 10.0f;
        if(volumn == 0)
        {
            if([_backgroundMusicPlayer isPlaying])
                [_backgroundMusicPlayer stop];
        }
        else
        {
            if(![_backgroundMusicPlayer isPlaying])
                [_backgroundMusicPlayer prepareToPlay];
        }
    }
    [self writeMusicVolumn];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    [self playBackgroundMusic];
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self playBackgroundMusic];
}

@end
