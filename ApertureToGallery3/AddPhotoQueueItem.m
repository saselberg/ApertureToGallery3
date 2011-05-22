//
//  AddPhotoQueueItem.m
//  Tutorial
//
//  Created by Scott Selberg on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoQueueItem.h"


@implementation AddPhotoQueueItem
@synthesize path;
@synthesize parameters;
@synthesize url;
@synthesize isPhoto;

- (id)init
{
    self = [super init];
    if (self) {
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
