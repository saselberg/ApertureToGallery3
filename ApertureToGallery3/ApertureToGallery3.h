//
//  ApertureToGallery3.h
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ApertureExportManager.h"
#import "ApertureExportPlugIn.h"

@interface ApertureToGallery3 : NSObject <ApertureExportPlugIn> 
{
        // The cached API Manager object, as passed to the -initWithAPIManager: method.
        id _apiManager; 
        
        // The cached Aperture Export Manager object - you should fetch this from the API Manager during -initWithAPIManager:
        NSObject<ApertureExportManager, PROAPIObject> *_exportManager; 
        
        // The lock used to protect all access to the ApertureExportProgress structure
        NSLock *_progressLock;
        
        // Top-level objects in the nib are automatically retained - this array
        // tracks those, and releases them
        NSArray *_topLevelNibObjects;
        
        // The structure used to pass all progress information back to Aperture
        ApertureExportProgress exportProgress;
        
        // Outlets to your plug-ins user interface
        IBOutlet NSView *settingsView;
        IBOutlet NSView *firstView;
        IBOutlet NSView *lastView;
}
@end

