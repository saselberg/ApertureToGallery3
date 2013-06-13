//
//  AddPhotoQueueItem.h

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


@interface AddPhotoQueueItem : NSObject {
    NSString            *path;
    NSString            *url;
    NSNumber            *uploadAttempts;
    NSMutableDictionary *parameters;
    BOOL                isPhoto;
    
}

@property (retain) NSString            *path;
@property (retain) NSString            *url;
@property (retain) NSMutableDictionary *parameters;
@property (retain) NSNumber            *uploadAttempts;
@property          BOOL                isPhoto;


- (void)loadIsPhoto:(BOOL)myIsPhoto withUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters;
- (id)initWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters;
- (id)initPhotoWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters;
- (id)initMovieWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters;

@end
