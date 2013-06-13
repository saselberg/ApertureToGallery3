//
//  AddPhotoQueueItem.m

/*
 Copyright (C) 2013 Scott Selberg
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 */

#import "AddPhotoQueueItem.h"


@implementation AddPhotoQueueItem
@synthesize path;
@synthesize parameters;
@synthesize url;
@synthesize isPhoto;
@synthesize uploadAttempts;

- (id)init
{
    self = [super init];
    if (self) {
        self.uploadAttempts = [NSNumber numberWithInt:0];
    }
    
    return self;
}

- (id)initPhotoWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters
{
    self = [super init];
    if (self) {
        [self loadIsPhoto:YES withUrl:myUrl andPath:myPath andParameters:myParameters];
    }
    return self;
}

- (id)initMovieWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters
{
    self = [super init];
    if (self) {
        [self loadIsPhoto:NO withUrl:myUrl andPath:myPath andParameters:myParameters];
    }
    return self;
    
}

- (id)initWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters
{
    self = [super init];
    if (self) {
        [self loadIsPhoto:YES withUrl:myUrl andPath:myPath andParameters:myParameters];
    }
    return self;
}

- (void)loadIsPhoto:(BOOL)myIsPhoto withUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters
{
    self.isPhoto    = myIsPhoto;
    self.url        = myUrl;
    self.path       = myPath;
    self.parameters = myParameters;
}

- (void)dealloc
{
    self.path       = nil;
    self.parameters = nil;
    self.url        = nil;
    [super dealloc];
}

@end
