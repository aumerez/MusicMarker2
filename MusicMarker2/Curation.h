//
//  Curation.h
//  MusicMarker2
//
//  Created by Armando Umerez on 8/4/15.
//  Copyright (c) 2015 Radiolobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Curation : NSManagedObject

@property (nonatomic, retain) NSString * song;
@property (nonatomic, retain) NSString * veredict;

@end
