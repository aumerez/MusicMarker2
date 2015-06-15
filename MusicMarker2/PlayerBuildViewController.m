//
//  PlayerBuildViewController.m
//  MusicMarker2
//
//  Created by Armando Umerez on 5/27/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import "PlayerBuildViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIView.h>


@interface PlayerBuildViewController ()

@end

@implementation PlayerBuildViewController
@synthesize playPauseButton, musicToPlay;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    
    [self.progressSlider addTarget:self action:@selector(progressSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if ([self.changedSong isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self playThisSong];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)playPauseAudio:(id)sender {
    if (!self.audioPlayer.playing) {
        
        self.progressSlider.maximumValue = self.audioPlayer.duration;
        
        [self.audioPlayer play];
        
        [self.playPauseButton setTitle:@"" forState:UIControlStateNormal];
        UIImage * buttonImage=[UIImage imageNamed:@"PauseBtnMid.png"];
        [playPauseButton setImage:buttonImage forState:UIControlStateNormal];
        
    } else if (self.audioPlayer.playing){
        [self.audioPlayer pause];
        [self.playPauseButton setTitle:@"" forState:UIControlStateNormal];
        UIImage * buttonImage=[UIImage imageNamed:@"PlayBtnMid.png"];
        [playPauseButton setImage:buttonImage forState:UIControlStateNormal];
        
    }
}


-(void)playThisSong{

    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, musicToPlay];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    NSLog(@"filePath:%@",filePath);

    url = [NSURL fileURLWithPath:filePath];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    } else {
        self.audioPlayer.delegate = self;
        self.progressSlider.value = 0.0;
        self.volumeSlider.value = 0.5;
        self.durationLabel.text = [self stringFromInterval:self.audioPlayer.duration];
        
        if (self.audioPlayer.duration <= 3600) {
            self.currentTimeLabel.text = [NSString stringWithFormat:@"00:00"];
        } else {
            self.currentTimeLabel.text = [NSString stringWithFormat:@"0:00:00"];
        }
        
        [self.currentTimeLabel sizeToFit];
        [self.audioPlayer prepareToPlay];
        
        self.progressSlider.maximumValue = self.audioPlayer.duration;
        
        [self.audioPlayer play];
    }
    
}
- (NSString*)stringFromInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    
    int seconds = ti % 60;
    int minutes = (ti /60) % 60;
    long hours = (int)(ti / 3600);
    
    if (ti <= 3600) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%ld:%02d:%02d",hours, minutes, seconds];
}
- (void) updateSlider
{
    self.progressSlider.value = self.audioPlayer.currentTime;
    self.currentTimeLabel.text = [self stringFromInterval:self.audioPlayer.currentTime];
    
}

- (IBAction)stopAudio:(id)sender
{
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        
    }
    
    [self.audioPlayer setCurrentTime:0.0];
    //[self.sliderTimer invalidate];
    self.progressSlider.value = 0;
    
    if (self.audioPlayer.duration <= 3600) {
        self.currentTimeLabel.text = [NSString stringWithFormat:@"00:00"];
         } else {
             self.currentTimeLabel.text = [NSString stringWithFormat:@"0:00:00"];
         }
         
         [self.currentTimeLabel sizeToFit];
         
         [self.playPauseButton setTitle:@"" forState:UIControlStateNormal];
        UIImage * buttonImage=[UIImage imageNamed:@"PlayBtnMid.png"];
        [playPauseButton setImage:buttonImage forState:UIControlStateNormal];
    
}

- (IBAction)adjustVolume:(id)sender
{
    if (self.audioPlayer != nil) {
        self.audioPlayer.volume = self.volumeSlider.value;
    }
}
         
- (IBAction)progressSliderChanged:(id)sender
{
            [self.audioPlayer stop];
            [self.audioPlayer setCurrentTime:self.progressSlider.value];
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self stopAudio:nil];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Codificación Error: %@", error.localizedDescription);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // Audio Player interrup
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionOptionShouldResume && self.audioPlayer != nil) {
        [self.audioPlayer play];
    }
}
- (IBAction)positiveMarker:(id)sender {
    
    [selecctions addObject:musicToPlay];
    
}
- (IBAction)negativeMarker:(id)sender {
    [selecctions addObject:musicToPlay];
    
}
- (IBAction)hitMarker:(id)sender {
    [selecctions addObject:musicToPlay];
    
}


@end
