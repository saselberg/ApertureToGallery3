//
//  ApertureToGallery3.m
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ApertureToGallery3.h"


@implementation ApertureToGallery3

//---------------------------------------------------------
// initWithAPIManager:
//
// This method is called when a plug-in is first loaded, and
// is a good point to conduct any checks for anti-piracy or
// system compatibility. This is also your only chance to
// obtain a reference to Aperture's export manager. If you
// do not obtain a valid reference, you should return nil.
// Returning nil means that a plug-in chooses not to be accessible.
//---------------------------------------------------------

- (id)initWithAPIManager:(id<PROAPIAccessing>)apiManager
{
	if ((self = [super init]))
	{
		_apiManager	= apiManager;
		_exportManager = [[_apiManager apiForProtocol:@protocol(ApertureExportManager)] retain];
		if (!_exportManager)
			return nil;
		
        _progressLock = [[NSLock alloc] init];
		
		// Finish your initialization here
	}
	
	return self;
}

- (void)dealloc
{
    // Release the top-level objects from the nib.
	[_topLevelNibObjects makeObjectsPerformSelector:@selector(release)];
	[_topLevelNibObjects release];
	
	[_progressLock release];
	[_exportManager release];
	
	[super dealloc];
}


#pragma mark -
// UI Methods
#pragma mark UI Methods

- (NSView *)settingsView
{
	if (nil == settingsView)
	{
		// Load the nib using NSNib, and retain the array of top-level objects so we can release
		// them properly in dealloc
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSNib *myNib = [[NSNib alloc] initWithNibNamed:@"BundleTest" bundle:myBundle];
		if ([myNib instantiateNibWithOwner:self topLevelObjects:&_topLevelNibObjects])
		{
			[_topLevelNibObjects retain];
		}
        [myNib release];
	}
	
	return settingsView;
}

- (NSView *)firstView
{
	return firstView;
}

- (NSView *)lastView
{
	return lastView;
}

- (void)willBeActivated
{
}

- (void)willBeDeactivated
{
}

#pragma mark
// Aperture UI Controls
#pragma mark Aperture UI Controls

- (BOOL)allowsOnlyPlugInPresets
{
	return NO;	
}

- (BOOL)allowsMasterExport
{
	return YES;	
}

- (BOOL)allowsVersionExport
{
	return YES;	
}

- (BOOL)wantsFileNamingControls
{
	return YES;	
}

- (void)exportManagerExportTypeDidChange
{
	// Nothing to do here - this plug-in doesn't show the user any information about the selected images,
	// so there's no need to see if the count or properties changed here.
}


#pragma mark -
// Save Path Methods
#pragma mark Save/Path Methods

- (BOOL)wantsDestinationPathPrompt
{
	// We have already destermined a temporary destination for our images and we delete them as soon as
	// we're done with them, so the user should not select a location.
	return NO;
}

- (NSString *)destinationPath
{
    return nil;
}

- (NSString *)defaultDirectory
{
	// Since this plug-in is not asking Aperture to present an open/save dialog,
	// this method should never be called.
	return nil;
}


#pragma mark -
// Export Process Methods
#pragma mark Export Process Methods

- (void)exportManagerShouldBeginExport
{
	// Before telling Aperture to begin generating image data, test the connection using the user-entered values
}

- (void)exportManagerWillBeginExportToPath:(NSString *)path
{
	// Nothing to do here. We could test the path argument and confirm that it's the same path we passed, but that's not really necessary.
}

- (BOOL)exportManagerShouldExportImageAtIndex:(unsigned)index
{
	// This plug-in doesn't exclude any images for any reason, so it always returns YES here.
	return YES;
}

- (void)exportManagerWillExportImageAtIndex:(unsigned)index
{
	// Nothing to do here - this is just a confirmation that we returned YES above. We could
	// check to make sure we get confirmation messages for every image.
}

- (BOOL)exportManagerShouldWriteImageData:(NSData *)imageData toRelativePath:(NSString *)path forImageAtIndex:(unsigned)index
{
	// Add to the total bytes we have to upload so we can properly indicate progress.
	return YES;	
}

- (void)exportManagerDidWriteImageDataToRelativePath:(NSString *)relativePath forImageAtIndex:(unsigned)index
{
    
}

- (void)exportManagerDidFinishExport
{
    // You must call [_exportManager shouldFinishExport] before Aperture will put away the progress window and complete the export.
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling. 
    [_exportManager shouldFinishExport];
}

- (void)exportManagerShouldCancelExport
{
	// You must call [_exportManager shouldCancelExport] here or elsewhere before Aperture will cancel the export process
	// NOTE: You should assume that your plug-in will be deallocated immediately following this call. Be sure you have cleaned up
	// any callbacks or running threads before calling.
    [_exportManager shouldCancelExport];
}


#pragma mark -
// Progress Methods
#pragma mark Progress Methods

- (ApertureExportProgress *)progress
{
	return &exportProgress;
}

- (void)lockProgress
{
	
	if (!_progressLock)
		_progressLock = [[NSLock alloc] init];
    
	[_progressLock lock];
}

- (void)unlockProgress
{
	[_progressLock unlock];
}

@end
