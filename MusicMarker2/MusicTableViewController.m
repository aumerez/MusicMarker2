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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetList{

    [self.restClient loadMetadata:@"/Music"];
    
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
        cell.backgroundColor = [UIColor grayColor];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    if(count<0){
        if(indexPath.row==0)
            cell.backgroundColor = [UIColor grayColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"uno:%li, dos:%li",(long)indexPath.row, (long)actualSong);
    
    if (indexPath.row != actualSong) {

        NSLog(@"DIFERENTE:");
        actualSong = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *musictoplayname = cell.textLabel.text;
        
        pbvc.musicToPlay = musictoplayname;
        pbvc.changedSong = [NSNumber numberWithBool:YES];
        
        
        [self.navigationController pushViewController:pbvc animated:YES];
    } else {
        NSLog(@"IGUAL");
        [self.navigationController pushViewController:pbvc animated:YES];
        pbvc.changedSong = [NSNumber numberWithBool:NO];
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
      
        for (DBMetadata *file in metadata.contents) {
            if (!file.isDirectory)
            {
                [Songs addObject:file.filename];
                NSLog(@"%@", file.filename);
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
            NSString *fullFilename = [NSString stringWithFormat:@"Music/%@",filename];
            NSLog(@"file:%@", fullFilename);
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
/*- (IBAction)sendSelections:(id)sender {
    [selections ]
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
