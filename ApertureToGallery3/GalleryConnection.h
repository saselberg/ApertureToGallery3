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
    NSMutableData        *_mutableData;
    NSMutableURLRequest  *_request;
    NSURLResponse        *_response;
    NSURLConnection      *_connection;
    NSError              *_error;
    NSStringEncoding     _encoding;
    BOOL                 _isRunning;
    NSMutableDictionary  *results;
    BOOL                 bVerbose;    
    id <URLCallDelegate> delegate;
}

@property(retain)             NSMutableDictionary  *results;
@property                     BOOL                 bVerbose;
@property (retain, nonatomic) id <URLCallDelegate> delegate;

- (GalleryConnection *)initWithRequest:(NSMutableURLRequest *)myRequest andDelegate:(id)myDelegate;
- (void)start;
- (void)cancel;
- (NSMutableDictionary*)parseRequest:(NSData *)myData;

@end
