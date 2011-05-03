//
//  GalleryInfo.h
//  Tutorial
//
//  Created by Scott Selberg on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GalleryInfo : NSObject {
@private
    
}

- (id)initWithName:(NSString*)myName andUrl:(NSString*)myUrl andUsername:(NSString*)myUsername andKey:(NSString*)myKey;

@property(retain) NSString *name;
@property(retain) NSString *url;
@property(retain) NSString *key;
@property(retain) NSString *username;

@end
