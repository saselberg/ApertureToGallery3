//
//  Version.h
//  ApertureToGallery3
//
//  Created by Scott Selberg on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Version : NSObject {
    NSNumber* RestfulGalleryVersion;
    NSNumber* ApertureToGalleryVersion;
    NSNumber* iPhotoToGalleryVersion;
    NSNumber* AppleToGalleryVersion;
}

@property (retain) NSNumber* RestfulGalleryVersion;
@property (retain) NSNumber* ApertureToGalleryVersion;
@property (retain) NSNumber* iPhotoToGalleryVersion;
@property (retain) NSNumber* AppleToGalleryVersion;

@end
