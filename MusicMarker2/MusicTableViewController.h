//
//  MusicTableViewController.h
//  MusicMarker2
//
//  Created by Armando Umerez on 5/21/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerBuildViewController.h"


@interface MusicTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    
    
    NSMutableArray * Songs;
    NSMutableArray * downloadedSongs;
    
    PlayerBuildViewController *pbvc;
}

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (strong, nonatomic)NSMutableArray *musicListDropbox;

@end
