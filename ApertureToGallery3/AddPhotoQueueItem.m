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

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters
{
    self = [super init];
    if (self) {
        self.url        = myUrl;
        self.path       = myPath;
        self.parameters = myParameters;
    }
    
    return self;
    
}
- (void)dealloc
{
    self.path       = nil;
    self.parameters = nil;
    self.url        = nil;
    [super dealloc];
}

@end
