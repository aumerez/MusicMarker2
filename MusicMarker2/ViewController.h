//
//  ViewController.h
//  MusicMarker2
//
//  Created by Armando Umerez on 5/21/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTableViewController.h"

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDelegate, UITableViewDataSource> {
MusicTableViewController *mtvc;
}

@property (weak, nonatomic) IBOutlet UIPickerView *gender;


@end

