//
//  MusicTableViewController.m
//  MusicMarker2
//
//  Created by Armando Umerez on 5/21/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import "MusicTableViewController.h"
#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface MusicTableViewController () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;

@end

Boolean startMusicApp;

Boolean stopMusic;
Boolean songOver;
int count;

NSInteger actualSong;

@implementation MusicTableViewController

@synthesize tableV;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedRatingNotification:)
                                                 name:@"ratingNotification"
                                               object:nil];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    pbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"musicplayerbuild"];
    
    downloadedSongs = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;

    Songs = [[NSMutableArray alloc] init];
    count=0;
    startMusicApp=NO;
    songOver=NO;
    stopMusic=NO;
    actualSong = -1;
    
    [self resetList];
    

    selectionDictionary = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetList{
    
    NSLog(@"File loaded into path: %@", self.style);
    [self.restClient loadMetadata:[NSString stringWithFormat:@"/%@/",self.style]];
 
}

//TABLE VIEW STUFF BELOW===============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [downloadedSongs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    
    cell.textLabel.text = [downloadedSongs objectAtIndex:(indexPath.row)];
    
    
    if(indexPath.row==count)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    if(count<0){
        if(indexPath.row==0)
            cell.backgroundColor = [UIColor grayColor];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != actualSong) {

        actualSong = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *musictoplayname = cell.textLabel.text;
        cell.backgroundColor = [UIColor yellowColor];
        
        pbvc.musicToPlay = musictoplayname;
        pbvc.changedSong = [NSNumber numberWithBool:YES];
        
        [self.navigationController pushViewController:pbvc animated:YES];
        
    } else {

        [self.navigationController pushViewController:pbvc animated:YES];
        pbvc.changedSong = [NSNumber numberWithBool:NO];
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    if (metadata.isDirectory) {

      
        for (DBMetadata *file in metadata.contents) {
            
            if (!file.isDirectory)
            {
                if ([file.filename containsString:@".mp3"] || [file.filename containsString:@".m4a"]) {
                    [Songs addObject:file.filename];

                }

            }
            
        }
        
        [self download];
        [tableV reloadData];
    
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

- (void)download {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    
    for (NSString *filename in Songs) {
        
        if (![filePathsArray containsObject:filename]) {
            NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *localPath = [localDir stringByAppendingPathComponent:filename];
            NSString *fullFilename = [NSString stringWithFormat:@"/%@/%@",self.style, filename];
            [self.restClient loadFile:fullFilename intoPath:localPath];
        } else {
            [downloadedSongs addObject:filename];
            [tableV reloadData];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
    
    [downloadedSongs addObject:[[localPath componentsSeparatedByString:@"/"] lastObject]];
    [tableV reloadData];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}
- (IBAction)unLink:(id)sender {
    [[DBSession sharedSession] unlinkAll];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSNotification Method

- (void) receivedRatingNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    //[selectionDictionary addObject:[notification userInfo]];
    
    BOOL isNew = true;
    
    for (NSMutableDictionary *mDictionary in selectionDictionary) {
        if ([mDictionary[@"selectedSong"] isEqualToString:[[notification userInfo] objectForKey:@"selectedSong"] ]) {
            mDictionary[@"rating"] = [[notification userInfo] objectForKey:@"rating"];
            isNew = false;
        }
        
    }
    
    if (isNew) {
        [selectionDictionary addObject:[[notification userInfo] mutableCopy]];
    }
    
    /*
    NSString *rating = [[notification userInfo] objectForKey:@"rating"];
    NSString *selectedSong = [[notification userInfo] objectForKey:@"selectedSong"];
    
    if ( [rating  isEqualToString: @"positive"] ){
        
        [positiveSelection addObject:selectedSong];
        
    } else if ( [rating isEqualToString: @"negative"] ){
        
        NSLog(@"Está entrando: %@", selectedSong );
        [negativeSelection addObject:selectedSong];
        
    } else if ( [rating isEqualToString:@"hit"]){
        
        [hitSelection addObject:selectedSong];
    
    } else {
        
    }
     */
    
    //if ([[notification name] isEqualToString:@"TestNotification"])
}

- (IBAction)saveFile:(id)sender {
    
    [self writeToFileWithName:@"SelectedSongs"];
}

-(void)writeToFileWithName:(NSString *)fileName {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyyhhmma"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    fileName = [NSString stringWithFormat:@"%@%@%@",self.nombreUser,fileName,dateString];
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt", docDirPath, fileName];
    [@"Music Marker \n" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    
    NSMutableArray *finalArray =[[NSMutableArray alloc] init];
    
    [finalArray addObject:@"\n---- Good Songs ----\n"];
    
    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"positive"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];
        }
    }

    [finalArray addObject:@"\n---- Bad Songs ----\n"];
    
    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"negative"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];

    }

    [finalArray addObject:@"\n---- Hit Songs ----\n"];

    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"hit"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];
        }
    }
    
    for (NSString *line in finalArray) {
        
        [fh seekToEndOfFile];
        [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [fh closeFile];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/",self.style];
    
    
    NSLog(@"fileName:%@, FILEPath:%@",[NSString stringWithFormat:@"%@.txt", fileName], filePath);
    [self.restClient uploadFile:[NSString stringWithFormat:@"/%@.txt", fileName] toPath:destDir withParentRev:nil fromPath:filePath];

    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

-(NSArray *)readFromFile:(NSString *)fileName {
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt", docDirPath, fileName];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    
    NSAssert(array, @"arrayWithContentsOfFile failed");
 
    return array;
    
}


@end
