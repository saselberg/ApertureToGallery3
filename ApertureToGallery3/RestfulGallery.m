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
    
    NSString *requestString = [NSString stringWithFormat:@"user=%@&password=%@", username, password];
    NSData   *requestData   = [requestString dataUsingEncoding:_encoding allowLossyConversion:YES];
	[request setHTTPBody:requestData];
    
    //    [galleryConnection initWithRequest:request andDelegate:self];
    //    [galleryConnection start];
    
    _data = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
    [self parseSynchronousRequest:_data];
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
            [self parseSynchronousRequest:_data];
        
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
       [self parseSynchronousRequest:_data];
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
       [self parseSynchronousRequest:_data];
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
       [self parseSynchronousRequest:_data];
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
       [self parseSynchronousRequest:_data];
   }
}

- (void)addPhotoAtPath:(NSString *)imagePath toUrl:(NSString *)restUrl withParameters:(NSMutableDictionary *)parameters
{
    if( [self galleryValid] )
    {
       if( [self bVerbose] ){ NSLog( @"adding photo" ); }
       self.results = nil;
    
       SBJsonWriter *jsonWriter = [[[SBJsonWriter alloc] init] autorelease ];
       [parameters setObject:@"photo"                      forKey:@"type"];
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
	
       NSString *requestString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
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
                                  @"\n"];
    
       if( [self bVerbose ] ){ NSLog( @"%@<data>\n--%@--", requestString, boundary ); }
    
       [requestData appendData:[requestString dataUsingEncoding:_encoding allowLossyConversion:YES]];
       [requestData appendData:imageData];
       [requestData appendData:[[NSString stringWithFormat:@"\n--%@--\n", boundary ] dataUsingEncoding:_encoding]];    
    
	   [request setHTTPBody:requestData];
    
       [_galleryConnection initWithRequest:request andDelegate:self.delegate];
       [_galleryConnection start];
    }
}

-(void)parseSynchronousRequest:(NSData *)myData
{
    // Get UTF8 String as a NSString from NSData response
    NSString *galleryResponseString = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];
    NSMutableDictionary *newResults = [NSMutableDictionary new];
    
    // Testing is received string is a json object. i.e. bounded by {}
    if( [galleryResponseString length] >= 1 )
    {
        //      char startChar = [galleryResponseString characterAtIndex:0];
        //      char endChar   = [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)];
        //      if( startChar == '{' && endChar == '}' ) -> just saving a few bits of memory.  
        if( [galleryResponseString characterAtIndex:0] == '{' && [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)] == '}' )
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            
            [newResults addEntriesFromDictionary:[parser objectWithString:galleryResponseString error:nil]];             
            [newResults setValue:@"JSON" forKey:@"RESPONSE_TYPE"];
            
            [parser release];
            parser = nil;
        }
        else if( [galleryResponseString characterAtIndex:0] == '[' && [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)] == ']' )
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            
            [newResults setValue:[parser objectWithString:galleryResponseString error:nil] forKey:@"RESULTS"];             
            [newResults setValue:@"JSON" forKey:@"RESPONSE_TYPE"];
            
            [parser release];
            parser = nil;
        }
        else if( [galleryResponseString characterAtIndex:0] == '"' && [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)] == '"' )
        {
            [newResults setValue:[galleryResponseString stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] forKey:@"GALLERY_RESPONSE"];
            [newResults setValue:@"TEXT" forKey:@"RESPONSE_TYPE"];
            
        }   
        else
        {
            [newResults setValue:galleryResponseString forKey:@"GALLERY_RESPONSE"];
            [newResults setValue:@"TEXT" forKey:@"RESPONSE_TYPE"];
        }
    }
    else
    {
        [newResults setValue:galleryResponseString forKey:@"GALLERY_RESPONSE"];
        [newResults setValue:@"TEXT" forKey:@"RESPONSE_TYPE"];
        
    }
    
    [newResults setValue:_error forKey:@"ERROR"];
    
    self.results = newResults;
}

@end
