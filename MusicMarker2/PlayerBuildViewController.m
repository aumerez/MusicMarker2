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
#import "AppDelegate.h"
#import "Curation.h"


@interface PlayerBuildViewController ()

@property (strong, nonatomic) NSMutableArray *song;
@property (strong, nonatomic) NSMutableArray *veredict;

@end

@implementation PlayerBuildViewController
@synthesize playPauseButton, musicToPlay, hitMarker, negativeMarker,positiveMarker;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"docDirPath 790:%@",docDirPath);
    
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    
    [self.progressSlider addTarget:self action:@selector(progressSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    }

- (void)viewDidAppear:(BOOL)animated {
    
    if ([self.changedSong isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self playThisSong];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Curation"
                    inManagedObjectContext:context];
        [request setEntity:entity];
        
        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"song == %@", musicToPlay];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        
        if (array.count > 0)
        {
            Curation *curation = array[0];
            NSString *valueSong = curation.veredict;
            
            if ([valueSong  isEqualToString: @"positive"]) {
                
                UIImage * buttonImage=[UIImage imageNamed:@"goodbtn2mark.png"];
                [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
                
                UIImage * buttonImage2=[UIImage imageNamed:@"badbtn.png"];
                [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
                
                UIImage * buttonImage3=[UIImage imageNamed:@"hit2.png"];
                [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
                
            } else if ([valueSong  isEqualToString: @"negative"]) {
                
                UIImage * buttonImage=[UIImage imageNamed:@"goodbtn.png"];
                [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
                
                UIImage * buttonImage2=[UIImage imageNamed:@"badbtn2mark.png"];
                [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
                
                UIImage * buttonImage3=[UIImage imageNamed:@"hit2.png"];
                [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
                
            } else if ([valueSong  isEqualToString: @"hit"]) {
                
                UIImage * buttonImage=[UIImage imageNamed:@"goodbtn.png"];
                [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
                
                UIImage * buttonImage2=[UIImage imageNamed:@"badbtn.png"];
                [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
                
                UIImage * buttonImage3=[UIImage imageNamed:@"hit2mark.png"];
                [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
                
            }
        } else {
            
            UIImage * buttonImage=[UIImage imageNamed:@"goodbtn.png"];
            [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
            
            UIImage * buttonImage2=[UIImage imageNamed:@"badbtn.png"];
            [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
            
            UIImage * buttonImage3=[UIImage imageNamed:@"hit2.png"];
            [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
            
        }

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
        UIImage * buttonImage=[UIImage imageNamed:@"Pausebut2.png"];
        [playPauseButton setImage:buttonImage forState:UIControlStateNormal];
        
    } else {
        [self.audioPlayer pause];
        [self.playPauseButton setTitle:@"" forState:UIControlStateNormal];
        UIImage * buttonImage=[UIImage imageNamed:@"playbut2.png"];
        [playPauseButton setImage:buttonImage forState:UIControlStateNormal];
        
    }
}


-(void)playThisSong{

    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, musicToPlay];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    UIImage * buttonImage=[UIImage imageNamed:@"Pausebut2.png"];
    [playPauseButton setImage:buttonImage forState:UIControlStateNormal];

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
        UIImage * buttonImage=[UIImage imageNamed:@"playbut2.png"];
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

//Codigo nuevo para llevar lo de la tabla
- (void)addToTableSong:(NSString *)song withValue:(NSString *)value{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Curation"
                inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"song == %@", song];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array.count > 0)
    {
        Curation *curation = array[0];
        curation.veredict = value;
        [context save:&error];
    }
    else {
        
        NSManagedObject *newSong = [NSEntityDescription insertNewObjectForEntityForName:@"Curation" inManagedObjectContext:context];
        [newSong setValue:song forKey:@"song"];
        [newSong setValue:value forKey:@"veredict"];
        [context save:&error];
    }
    
}
- (IBAction)positiveMarker:(id)sender {
    
    //[selecctions addObject:musicToPlay];
    
    //This is the Dictionary manager
    
    NSLog(@"1:%@",musicToPlay);
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[musicToPlay,@"positive"] forKeys:@[@"selectedSong",@"rating"]];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ratingNotification"
     object:self userInfo:dictionary];
    
    [self addToTableSong:musicToPlay withValue:@"positive"];
    
    UIImage * buttonImage=[UIImage imageNamed:@"goodbtn2mark.png"];
    [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
    
    UIImage * buttonImage2=[UIImage imageNamed:@"badbtn.png"];
    [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
    
    UIImage * buttonImage3=[UIImage imageNamed:@"hit2.png"];
    [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
    
}

- (IBAction)negativeMarker:(id)sender {
    //This is the Dictionary manager
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[musicToPlay,@"negative"] forKeys:@[@"selectedSong",@"rating"]];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ratingNotification"
     object:self userInfo:dictionary];
    
    [self addToTableSong:musicToPlay withValue:@"negative"];
    
    UIImage * buttonImage=[UIImage imageNamed:@"goodbtn.png"];
    [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
    
    UIImage * buttonImage2=[UIImage imageNamed:@"badbtn2mark.png"];
    [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
    
    UIImage * buttonImage3=[UIImage imageNamed:@"hit2.png"];
    [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
    
}

- (IBAction)hitMarker:(id)sender {
    //This is the Dictionary manager
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:@[musicToPlay,@"hit"] forKeys:@[@"selectedSong",@"rating"]];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ratingNotification"
     object:self userInfo:dictionary];
    
    [self addToTableSong:musicToPlay withValue:@"hit"];
    
    UIImage * buttonImage=[UIImage imageNamed:@"goodbtn.png"];
    [positiveMarker setImage:buttonImage forState:UIControlStateNormal];
    
    UIImage * buttonImage2=[UIImage imageNamed:@"badbtn.png"];
    [negativeMarker setImage:buttonImage2 forState:UIControlStateNormal];
    
    UIImage * buttonImage3=[UIImage imageNamed:@"hit2mark.png"];
    [hitMarker setImage:buttonImage3 forState:UIControlStateNormal];
    
}


@end
