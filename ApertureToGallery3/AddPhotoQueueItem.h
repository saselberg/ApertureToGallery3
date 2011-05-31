//
//  AddPhotoQueueItem.h
//  Tutorial
//
//  Created by Scott Selberg on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
