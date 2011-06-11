//
//  RestfulGallery.m
//  Tutorial
//
//  Created by Scott Selberg on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestfulGallery.h"


@implementation RestfulGallery
@synthesize url;
@synthesize galleryApiKey;
@synthesize bVerbose;
@synthesize results;
@synthesize delegate;
@synthesize bGalleryValid;

- (RestfulGallery *)init;
{
    self = [super init];
    if( self )
    { 
        _userAgent         = @"ApertureToGallery3ExportPlugin";
        _encoding          = NSASCIIStringEncoding;
        _galleryConnection = [GalleryConnection alloc];
        _addPhotoQueue     = [[NSMutableArray alloc] init];
        _standardTimeout   = 20;
        _shortTimeout      = 5;
        self.bVerbose = false;
        self.delegate = self;
        self.bGalleryValid = false;
    }
    
    return self;    
}

- (void)dealloc
{
    [_galleryConnection release];
    [_addPhotoQueue release];
    _galleryConnection = nil;
    _addPhotoQueue = nil;
    
    self.galleryApiKey     = nil;
    self.url               = nil;
    self.results           = nil;

    [super dealloc];
}

- (void)cancel
{
    [_galleryConnection cancel];
}


- (void)got:(NSMutableDictionary *)myResults;
{
    self.results = myResults;

//    NSLog( @"%@", results );
//    NSLog( @"Restful Gallery Done!" );
}

- (void) updateTotalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}

- (void)getApiKeyforGallery:(NSString *)myGallery AndUsername:(NSString *)username AndPassword:(NSString *)password;
{    
    if( [self bVerbose] ){ NSLog( @"getting API" ); }
    results = nil;
    //build the request
    NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest", myGallery]] autorelease];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:_standardTimeout];
	[request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"post"    forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setHTTPMethod:@"POST"];
    
    NSString *requestString = [NSString stringWithFormat:@"user=%@&password=%@", 
                               [username stringByAddingPercentEscapesUsingEncoding:_encoding], 
                               [password stringByAddingPercentEscapesUsingEncoding:_encoding]];
    NSData   *requestData   = [requestString dataUsingEncoding:_encoding allowLossyConversion:YES];
	[request setHTTPBody:requestData];
    
    _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
    self.results = [_galleryConnection parseRequest:_data];
}

- (BOOL)galleryValid
{
    if( !self.bGalleryValid )
    {
        if( [self bVerbose] ){ NSLog( @"Testing Gallery Validity" ); }
        if( [self.galleryApiKey length] > 0 )
        {
            self.results = nil;
        
            NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest/item/1", self.url]] autorelease];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                timeoutInterval:_shortTimeout];
            [request setValue:_userAgent         forHTTPHeaderField:@"User-Agent"];
            [request setValue:self.galleryApiKey forHTTPHeaderField:@"X-Gallery-Request-Key"];
            [request setValue:@"get"             forHTTPHeaderField:@"X-Gallery-Request-Method"];
            [request setHTTPMethod:@"POST"];
        
            NSData *requestData = [@"ouput=json&type=album" dataUsingEncoding:_encoding allowLossyConversion:YES];
            [request setHTTPBody:requestData];
        
            _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
            self.results = [_galleryConnection parseRequest:_data];

            if( [[self.results objectForKey:@"RESPONSE_TYPE"] isEqualToString:@"JSON"] )
            {
                self.bGalleryValid = true;
            }
        }
    }
    return self.bGalleryValid;
}

- (void)getApiKeyforUsername:(NSString *)username AndPassword:(NSString *)password;
{    
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"getting API" ); }
       results = nil;
       //build the request
       NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest", self.url]] autorelease];
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:_standardTimeout];
	   [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
       [request setValue:@"post"    forHTTPHeaderField:@"X-Gallery-Request-Method"];
	   [request setHTTPMethod:@"POST"];

       NSString *requestString = [NSString stringWithFormat:@"user=%@&password=%@", username, password];
       NSData   *requestData   = [requestString dataUsingEncoding:_encoding allowLossyConversion:YES];
	   [request setHTTPBody:requestData];
        
       _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
        self.results = [_galleryConnection parseRequest:_data];
    }
}

- (void)getInfoForItem:(NSNumber *)restItem
{
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"getting albums for item" ); }
       results = nil;
       NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest/item/%d", self.url, [restItem integerValue]]] autorelease];
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:_standardTimeout];
	   [request setValue:_userAgent         forHTTPHeaderField:@"User-Agent"];
	   [request setValue:self.galleryApiKey forHTTPHeaderField:@"X-Gallery-Request-Key"];
	   [request setValue:@"get"             forHTTPHeaderField:@"X-Gallery-Request-Method"];
	   [request setHTTPMethod:@"POST"];
	
       NSData *requestData = [@"ouput=json&type=album" dataUsingEncoding:_encoding allowLossyConversion:YES];
	   [request setHTTPBody:requestData];
    
       _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
        self.results = [_galleryConnection parseRequest:_data];
    }
}

- (void)getInfoForItems:(NSArray *)urls
{
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"getting items" ); }
       results = nil;
       NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest/items", self.url]] autorelease];
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:_standardTimeout];
       [request setValue:_userAgent         forHTTPHeaderField:@"User-Agent"];
       [request setValue:self.galleryApiKey forHTTPHeaderField:@"X-Gallery-Request-Key"];
       [request setValue:@"get"             forHTTPHeaderField:@"X-Gallery-Request-Method"];
       [request setHTTPMethod:@"POST"];
	
       NSData *requestData = [ [NSString stringWithFormat:@"urls=[\"%@\"]",[urls componentsJoinedByString:@"\",\""]] dataUsingEncoding:_encoding allowLossyConversion:YES];
       [request setHTTPBody:requestData];
    
       _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
        self.results = [_galleryConnection parseRequest:_data];
    }
}

- (void)createAlbumInEntity:(NSNumber *)restItem withParameters:(NSMutableDictionary *)parameters
{
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"creating album" ); }
       results = nil;
       SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease ];
    
       [parameters setObject:@"json"  forKey:@"output"];
       [parameters setObject:@"album" forKey:@"type"];
     
       NSURL *localURL = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/index.php/rest/item/%d", self.url, [restItem integerValue]]] autorelease];
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:_standardTimeout];
	   [request setValue:_userAgent         forHTTPHeaderField:@"User-Agent"];
	   [request setValue:self.galleryApiKey forHTTPHeaderField:@"X-Gallery-Request-Key"];
	   [request setValue:@"post"            forHTTPHeaderField:@"X-Gallery-Request-Method"];
	   [request setHTTPMethod:@"POST"];
    
       NSString *requestString = [[NSString stringWithFormat:@"%@%@", @"entity=",[jsonWriter stringWithObject:parameters]] stringByAddingPercentEscapesUsingEncoding:_encoding];
       NSData *requestData = [requestString dataUsingEncoding:_encoding allowLossyConversion:YES];     
       [request setHTTPBody:requestData];
    
       _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
        self.results = [_galleryConnection parseRequest:_data];
   }
}

- (void)addPhotoAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters
{
    [self addItemIsPhoto:YES AtPath:imagePath toUrl:restUrl withParameters:parameters];
}

- (void)addMovieAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters
{
    [self addItemIsPhoto:NO AtPath:imagePath toUrl:restUrl withParameters:parameters];
}

- (void)addItemIsPhoto:(BOOL)isPhoto AtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters
{
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"adding photo" ); }
       self.results = nil;
    
       SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease ];
       if( !isPhoto ){
           [parameters setObject:@"movie"                      forKey:@"type"];
       } else {
           [parameters setObject:@"photo"                      forKey:@"type"];
       }
       [parameters setObject:[imagePath lastPathComponent] forKey:@"name"];   
    
       NSMutableData *requestData = [[[NSMutableData alloc] init] autorelease]; 
       NSData   *imageData = [[[NSData alloc] initWithContentsOfFile:imagePath] autorelease];
    
       // Make a unique string for the boundary. Leveraged from Zach Wiley in iPhotoToGallery
       NSString *boundary = [NSString stringWithFormat:@"%@", [[NSProcessInfo processInfo] globallyUniqueString]];
    
       //build the request    
       NSURL *localURL = [[[NSURL alloc] initWithString:restUrl] autorelease];
    
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:localURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:60.0];
       [request setHTTPMethod:@"POST"];
	   [request setValue:_userAgent                                                                    forHTTPHeaderField:@"User-Agent"];
	   [request setValue:self.galleryApiKey                                                            forHTTPHeaderField:@"X-Gallery-Request-Key"];
	   [request setValue:@"post"                                                                       forHTTPHeaderField:@"X-Gallery-Request-Method"];
       [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundary] forHTTPHeaderField:@"Content-Type"];

        NSString *requestString =  [[NSArray arrayWithObjects:
                                   @"--", boundary, @"\n",
                                   @"Content-Disposition: form-data; name=\"entity\"\n",
                                   @"Content-Type: text/plain; charset=UTF-8\n",
                                   @"Content-Transfer-Encoding: 8bit\n",
                                   @"\n",
                                   [jsonWriter stringWithObject:parameters],@"\n",
                                   @"--", boundary, @"\n",
                                   @"Content-Disposition: form-data; name=\"file\"; filename=\"",[imagePath lastPathComponent],@"\"\n",
                                   @"Content-Type: application/octet-stream\n",
                                   @"Content-Transfer-Encoding: binary\n",
                                    @"\n", nil] componentsJoinedByString:@""];

       if( [self bVerbose ] ){ NSLog( @"%@<data>\n--%@--", requestString, boundary ); }
    
       [requestData appendData:[requestString dataUsingEncoding:_encoding allowLossyConversion:YES]];
       [requestData appendData:imageData];
       [requestData appendData:[[NSString stringWithFormat:@"\n--%@--\n", boundary ] dataUsingEncoding:_encoding]];    
    
	   [request setHTTPBody:requestData];
    
       [_galleryConnection initWithRequest:request andDelegate:self.delegate];
       [_galleryConnection start];
    }
}

- (void) waterMarkImage:(NSString *)myBaseImageName with:(NSString *)myWaterMarkImageName andTransformIndex:(NSInteger)indexOfSelectedItem
{    
    CIImage *_baseImage   = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:myBaseImageName]];
    CIImage *_resultImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:myWaterMarkImageName]];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    BOOL executeTransform        = NO;
    BOOL addWatermark            = YES;
    
    switch( indexOfSelectedItem )
    {
        case 0: addWatermark = NO; break;
        case 2: [transform scaleXBy:([_baseImage extent].size.width/[_resultImage extent].size.width)
                                yBy:([_baseImage extent].size.height/[_resultImage extent].size.height)];
            executeTransform = YES;
            break;
        case 4: [transform translateXBy:0
                                    yBy:[_baseImage extent].size.height - [_resultImage extent].size.height];
            executeTransform = YES;
            break;
        case 5: [transform translateXBy:([_baseImage extent].size.width - [_resultImage extent].size.width)/2
                                    yBy:[_baseImage extent].size.height - [_resultImage extent].size.height];
            executeTransform = YES;
            break;
        case 6: [transform translateXBy:[_baseImage extent].size.width - [_resultImage extent].size.width
                                    yBy:[_baseImage extent].size.height - [_resultImage extent].size.height];
            executeTransform = YES;
            break;
        case 7: [transform translateXBy:0
                                    yBy:([_baseImage extent].size.height - [_resultImage extent].size.height)/2];
            executeTransform = YES;
            break;
        case 8: [transform translateXBy:([_baseImage extent].size.width - [_resultImage extent].size.width)/2
                                    yBy:([_baseImage extent].size.height - [_resultImage extent].size.height)/2];
            executeTransform = YES;
            break;
        case 9: [transform translateXBy:[_baseImage extent].size.width - [_resultImage extent].size.width
                                    yBy:([_baseImage extent].size.height - [_resultImage extent].size.height)/2];
            executeTransform = YES;
            break;
        case 10: [transform translateXBy:0
                                     yBy:0];
            executeTransform = YES;
            break;
        case 11: [transform translateXBy:([_baseImage extent].size.width - [_resultImage extent].size.width)/2
                                     yBy:0];
            executeTransform = YES;
            break;
        case 12: [transform translateXBy:[_baseImage extent].size.width - [_resultImage extent].size.width
                                     yBy:0];
            executeTransform = YES;
            break;
        default: break;
    }
    
    if( executeTransform )
    {
        CIFilter* _affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
        [_affineTransformFilter setValue:_resultImage forKey:@"inputImage"];
        [_affineTransformFilter setValue:transform forKey:@"inputTransform"];
        _resultImage = [_affineTransformFilter valueForKey:@"outputImage"];        
    }
    
    if( addWatermark )
    {
        CIFilter* _softLightFilter = [CIFilter filterWithName:@"CISoftLightBlendMode"];
        [_softLightFilter setDefaults];
        [_softLightFilter setValue:_baseImage forKey:@"inputBackgroundImage"];
        [_softLightFilter setValue:_resultImage forKey:@"inputImage"];
        _resultImage = [_softLightFilter valueForKey: @"outputImage" ];
    } else {
        _resultImage = _baseImage;
    }
    
    CGRect ourRect = [_baseImage extent];
    NSBitmapImageRep* bitmap = [NSBitmapImageRep imageRepWithContentsOfFile:myBaseImageName] ;
    
    NSGraphicsContext* graphicsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep: bitmap];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: graphicsContext];
    NSRectFill(NSMakeRect(0.0f, 0.0f, [bitmap pixelsWide], [bitmap pixelsHigh]));
    
    CGRect fromRect = [_resultImage extent];
    [[graphicsContext CIContext] drawImage:_resultImage inRect:CGRectMake(0.0f, 0.0f,ourRect.size.width, ourRect.size.height) fromRect:fromRect];
    
    [NSGraphicsContext restoreGraphicsState];    
    
    NSData *imageData = [bitmap representationUsingType:NSJPEGFileType properties:nil];
    [imageData writeToFile:myBaseImageName atomically:NO];
    
    return;
}

@end
