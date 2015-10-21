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
#import "AppDelegate.h"
#import "Curation.h"

@interface MusicTableViewController () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;


@property (strong, nonatomic) NSMutableArray *song;
@property (strong, nonatomic) NSMutableArray *veredict;

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

- (void)viewDidAppear:(BOOL)animated {
    [tableV reloadData];
    
    
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
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Curation"
                inManagedObjectContext:context];
    [request setEntity:entity];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"song == %@", [downloadedSongs objectAtIndex:(indexPath.row)]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    
    if(array.count >0)
    {
        Curation *curation = array[0];
        NSString *valueSong = curation.veredict;
        
        if ([valueSong  isEqualToString: @"positive"]) {
            
            cell.backgroundColor = [UIColor greenColor];
            
        } else if ([valueSong  isEqualToString: @"negative"]) {
            
            cell.backgroundColor = [UIColor redColor];
            
        } else if ([valueSong  isEqualToString: @"hit"]) {
            
            cell.backgroundColor = [UIColor yellowColor];
            
        }
    } else {
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    
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
        //cell.backgroundColor = [UIColor yellowColor];
        
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
}

- (IBAction)saveFile:(id)sender {
    
    [self writeToFileWithName:@"selectedSongs"];
    NSLog(@"Paso por el saveFile:");
}


-(void)writeToFileWithName:(NSString *)fileName {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMddyyyyhhmma"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    
    fileName = [NSString stringWithFormat:@"%@%@%@",self.nombreUser, fileName, dateString];
    
    //NSLog(@"El nombre del archivo para guardar es %@", fileName);
    
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt", docDirPath, fileName];
    [@"Music Marker \n" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    //NSLog(@"El nombre de la canión para guardar es %@", filePath);
    
    NSMutableArray *finalArray =[[NSMutableArray alloc] init];
    
    //NSLog(@"Los elementos son:%@", finalArray[0]);

    [finalArray addObject:@"\n---- Good Songs ----\n"];
    
    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"positive"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];
            
            NSLog(@"1%@", fileName);
            
        }
    }

    [finalArray addObject:@"\n---- Bad Songs ----\n"];
    
    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"negative"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];

        }
        
    }

    [finalArray addObject:@"\n---- Hit Songs ----\n"];

    for (NSMutableDictionary * mDictionary in selectionDictionary) {
        if ([mDictionary[@"rating"] isEqualToString:@"hit"]) {
            [finalArray addObject:mDictionary[@"selectedSong"]];
            NSLog(@"1%@", fileName);
        }
    }
    
    for (NSString *line in finalArray) {
        
        NSLog(@"EL COMPADRE!!!:%@",line);
        [fh seekToEndOfFile];
        [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [fh closeFile];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/",self.style];
    
    [self.restClient uploadFile:[NSString stringWithFormat:@"/%@.txt", fileName] toPath:destDir withParentRev:nil fromPath:filePath];

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
