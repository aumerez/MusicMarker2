//
//  LoginUserViewController.h
//  MusicMarker2
//
//  Created by Armando Umerez on 6/15/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginUserViewController : UIViewController
- (IBAction)loginButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *username;

@end