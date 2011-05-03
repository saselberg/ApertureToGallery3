//
//  GalleryConnection.m
//  Tutorial
//
//  Created by Scott Selberg on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GalleryConnection.h"


@implementation GalleryConnection
@synthesize data;
@synthesize request;
@synthesize response;
@synthesize connection;
@synthesize results;
@synthesize error;
@synthesize isRunning;
@synthesize beVerbose;
@synthesize delegate;

- (GalleryConnection *)initWithRequest:(NSMutableURLRequest *)myRequest andDelegate:(id)myDelegate
{
    self.request    = myRequest;
    self.delegate   = myDelegate;
    self.connection = [NSURLConnection alloc];
    self.data       = [[NSMutableData alloc] init];
    self.results    = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    self.isRunning = false;
    self.beVerbose = false;
    
    return self;
}

- (void)dealloc
{
    self.data       = nil;
    self.request    = nil;
    self.response   = nil;
    self.connection = nil;
    self.results    = nil;
    self.error      = nil;
    self.delegate   = nil;
    [super dealloc];
}

#pragma mark NSURLConnection
-(void) start {
    if( self.beVerbose ){ NSLog( @"Starting Gallery Connection..." ); }
    self.isRunning = true;
    self.connection = [self.connection initWithRequest:request delegate:self startImmediately:true];
}

-(void) cancel{
    if( self.isRunning )
    {
        if( self.beVerbose ){NSLog( @"Canceling Gallery Connection..." );}
       [self.connection cancel];
    }
}

#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    if( self.beVerbose ){NSLog( @"Gallery Connection Did Received A Response" );}
    self.response = [aResponse retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData
{
    if( self.beVerbose ){NSLog( @"Gallery Connection Received Some Data" );}
    [self.data appendData:someData];    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
    if( self.beVerbose ){NSLog( @"Gallery Connection Failed with Error" );}
    self.error = [anError retain];
    
    [self.results setValue:@"ERROR"   forKey:@"RESPONSE_TYPE"];
    [self.results setValue:self.error forKey:@"ERROR"];

    self.isRunning = false;    
    [self.delegate got:self.results];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if( self.beVerbose ){NSLog( @"Gallery Connection Completed Successfully" );}

    // Get UTF8 String as a NSString from NSData response
    NSString *galleryResponseString = [[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding] autorelease];

    // Testing is received string is a json object. i.e. bounded by {}
    if( [galleryResponseString length] >= 1 )
    {
//      char startChar = [galleryResponseString characterAtIndex:0];
//      char endChar   = [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)];
//      if( startChar == '{' && endChar == '}' ) -> just saving a few bits of memory.  
        if( [galleryResponseString characterAtIndex:0] == '{' && [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)] == '}' )
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            
            [self.results addEntriesFromDictionary:[parser objectWithString:galleryResponseString error:nil]];             
            [self.results setValue:@"JSON" forKey:@"RESPONSE_TYPE"];
            
            [parser release];
            parser = nil;
        }
        else if( [galleryResponseString characterAtIndex:0] == '[' && [galleryResponseString characterAtIndex:( [galleryResponseString length]-1)] == ']' )
        {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
        
            [self.results setValue:[parser objectWithString:galleryResponseString error:nil] forKey:@"RESULTS"];             
            [self.results setValue:@"JSON" forKey:@"RESPONSE_TYPE"];
        
            [parser release];
            parser = nil;
        }
        else
        {
            [self.results setValue:galleryResponseString forKey:@"GALLERY_RESPONSE"];
            [self.results setValue:@"TEXT" forKey:@"RESPONSE_TYPE"];
        }
    }
    else
    {
        [self.results setValue:galleryResponseString forKey:@"GALLERY_RESPONSE"];
        [self.results setValue:@"TEXT" forKey:@"RESPONSE_TYPE"];
        
    }
    
    [self.results setValue:self.error forKey:@"ERROR"];
        
    self.isRunning = false;    
    [self.delegate got:self.results];
}

@end
