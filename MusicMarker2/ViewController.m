
//
//  ViewController.m
//  MusicMarker2
//
//  Created by Armando Umerez on 5/21/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import "ViewController.h"
#import "MusicTableViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "PlayerBuildViewController.h"
#import "AppDelegate.h"


@interface ViewController () <DBRestClientDelegate>

{
    NSArray *_pickerData;
}

@property (nonatomic, strong) DBRestClient *restClient;

@property (nonatomic, strong) NSArray *sortDescriptors;
@property (nonatomic, assign) BOOL isAddingList;

//Codigo nuevo para llevar lo de la tabla
@property (strong, nonatomic) NSMutableArray *song;
@property (strong, nonatomic) NSMutableArray *veredict;

@end

NSInteger genderSelect;
long numCol;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _pickerData = @[ @"Dance", @"Country", @"Pop", @"Latin", @"Rock"];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    [self.restClient loadAccountInfo];
    self.restClient.delegate = self;
    
    mtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"musictable"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enter:(id)sender {
   if (![[DBSession sharedSession] isLinked]) {
       [[DBSession sharedSession] linkFromController:self];
    }
    //- (IBAction)settingsButtonPressed:(id)sender
    //{
        // Show settings action sheet to link or unlink with a Dropbox account
        /*UIActionSheet *actionSheet = nil;
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        
        if (account == nil) {
            // Link to Dropbox
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Link to Dropbox", nil];
        } else {
            // Unlink from Dropbox
            actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Linked with Dropbox account:\n%@", account.info.displayName]
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:@"Unlink from Dropbox"
                                             otherButtonTitles:nil];
        }
        
        // Display action sheet
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [actionSheet showFromBarButtonItem:sender animated:YES];
        } else {
            [actionSheet showInView:self.view];
        }
    }*/

}

- (IBAction)player:(id)sender {
    
    mtvc.sendStyle = [NSNumber numberWithBool:YES];
    [self.navigationController pushViewController:mtvc animated:YES];

}


-(void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
    
    NSLog(@"userID:%@",[info displayName]);
    mtvc.nombreUser = [info displayName];
    
}

/*- (IBAction)settingsButtonPressed:(id)sender
{
    // Show settings action sheet to link or unlink with a Dropbox account
    UIActionSheet *actionSheet = nil;
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account == nil) {
        // Link to Dropbox
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Link to Dropbox", nil];
    } else {
        // Unlink from Dropbox
        actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Linked with Dropbox account:\n%@", account.info.displayName]
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Unlink from Dropbox"
                                         otherButtonTitles:nil];
    }
    
    // Display action sheet
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
}

- (IBAction)uptocloud:(id)sender {
    
    // Write a file to the local documents directory
    NSString *text = @"Hello world.";
    NSString *filename = @"working-draft.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}//Users/armandoumerez/Documents/Documentos Radiolobe/APPs/MusicMarker2/MusicMarker2/ViewController.m

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

/*- (IBAction)listcall:(id)sender {
    [self.restClient loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}


- (IBAction)download:(id)sender {
    
   NSString *filename = @"/Music/Tito Gómez - Vereda Tropical 0.mp3";

   NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
   NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    [self.restClient loadFile:filename intoPath:localPath];
    

    //NSArray *todosLosArchivos = [[NSArray alloc] initWithObjects:filename, nil];
    
    //for (NSString *filename in todosLosArchivos) {
        
       // NSString *fullFilename = [NSString stringWithFormat:@"/%@",filename];
        //[self.restClient loadFile:fullFilename intoPath:localPath];
    //}
    NSString *filename = [[NSString alloc] init];
    
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    //[self.restClient loadFile:filename intoPath:localPath];
    
    
    //NSArray *Songs = [[NSArray alloc] initWithObjects:filename, nil];
    
    for (NSString *filename in Songs) {
        
        NSString *fullFilename = [NSString stringWithFormat:@"/Music/%@",filename];
        NSLog(@"file:%@", fullFilename);
        [self.restClient loadFile:fullFilename intoPath:localPath];
    }
    
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}

- (IBAction)playerreal:(id)sender {
    
    PlayerBuildViewController *pbvc = [self.storyboard instantiateViewControllerWithIdentifier:@"musicplayerbuild"];
    
    [self.navigationController pushViewController:pbvc animated:YES];
}*/

// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

// Catpure the picker view selection

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    NSLog(@"Lo que lee el row:%ld", (long)row);
    
    NSInteger i = (int) (long) row;
    
    NSLog(@"La selección es: %ld/ %@", numCol, [_pickerData objectAtIndex:i]);
    
    mtvc.style = [_pickerData objectAtIndex:i];
    
}

@end
