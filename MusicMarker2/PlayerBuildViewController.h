//
//  PlayerBuildViewController.h
//  MusicMarker2
//
//  Created by Armando Umerez on 5/27/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerBuildViewController : UIViewController <AVAudioPlayerDelegate> {
    
    NSMutableArray *selecctions;
    
}

- (IBAction)stopAudio:(id)sender;
- (IBAction)playPauseAudio:(id)sender;
- (IBAction)progressSliderChanged:(id)sender;
- (IBAction)adjustVolume:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *sliderTimer;
@property (strong, nonatomic) NSString *musicToPlay;
@property (strong, nonatomic) NSNumber *changedSong;


- (NSString*)stringFromInterval:(NSTimeInterval)interval;
- (void) updateSlider;

- (void)playThisSong;

@end
