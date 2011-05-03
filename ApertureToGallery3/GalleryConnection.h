//
//  GalleryConnection.h
//  Tutorial
//
//  Created by Scott Selberg on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLCallDelegate.h"
#import "JSON.h"

@interface GalleryConnection : NSObject {
    NSMutableData        *data;
    NSMutableURLRequest  *request;
    NSURLResponse        *response;
    NSURLConnection      *connection;
    NSError              *error;
    NSMutableDictionary  *results;
    BOOL                 isRunning;
    BOOL                 beVerbose;
    id <URLCallDelegate> delegate;
}

- (GalleryConnection *)initWithRequest:(NSMutableURLRequest *)myRequest andDelegate:(id)myDelegate;
- (void)start;
- (void)cancel;

@property(retain)             NSMutableData        *data;
@property(retain)             NSMutableURLRequest  *request;
@property(retain)             NSURLResponse        *response;
@property(retain)             NSURLConnection      *connection;
@property(retain)             NSMutableDictionary  *results;
@property(retain)             NSError              *error;
@property                     BOOL                 isRunning;
@property                     BOOL                 beVerbose;
@property (retain, nonatomic) id <URLCallDelegate> delegate;

@end
