//
//  GalleryConnection.h

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

#import <Foundation/Foundation.h>
#import "URLCallDelegate.h"
#import "SBJSON.h"

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
