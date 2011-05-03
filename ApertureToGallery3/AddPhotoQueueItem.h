//
//  AddPhotoQueueItem.h
//  Tutorial
//
//  Created by Scott Selberg on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AddPhotoQueueItem : NSObject {
@private
    
}

@property (retain) NSString            *path;
@property (retain) NSString            *url;
@property (retain) NSMutableDictionary *parameters;

- (id)initWithUrl:(NSString *)myUrl andPath:(NSString *)myPath andParameters:(NSMutableDictionary *)myParameters;

@end
