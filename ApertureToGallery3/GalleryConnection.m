//
//  GalleryConnection.m

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

#import "GalleryConnection.h"


@implementation GalleryConnection
@synthesize results;
@synthesize bVerbose;
@synthesize delegate;

- (GalleryConnection *)initWithRequest:(NSMutableURLRequest *)myRequest andDelegate:(id)myDelegate
{
    _request    = [myRequest retain];
    _connection = [NSURLConnection alloc];
    _mutableData       = [[NSMutableData alloc] init];
    _isRunning    = false;
    _encoding   = NSUTF8StringEncoding;

    self.delegate   = myDelegate;
    self.results    = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.bVerbose = false;
    
    return self;
}

- (void)dealloc
{
      [_request release];
      [_connection release];
      [_mutableData release];
      [_error release];
    
    _request = nil;
    _connection = nil;
    _mutableData = nil;

     if( _response ){ [_response release]; _response = nil;}
      if( _error    ){ [_error    release]; _error    = nil;}
    
    self.results    = nil;
    self.delegate   = nil;
        [super dealloc];
}

#pragma mark NSURLConnection
-(void) start {
    if( self.bVerbose ){ NSLog( @"Starting Gallery Connection..." ); }
    _isRunning = true;
    [_connection initWithRequest:_request delegate:self startImmediately:true];
}

-(void) cancel{
    if( _isRunning )
    {
        if( self.bVerbose ){NSLog( @"Canceling Gallery Connection..." );}
       [_connection cancel];
    }
}

#pragma mark NSURLConnection Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    if( self.bVerbose ){NSLog( @"Gallery Connection Did Received A Response" );}
      _response = [aResponse retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)someData
{
    if( self.bVerbose ){NSLog( @"Gallery Connection Received Some Data" );}
    [_mutableData appendData:someData];    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError
{
    if( self.bVerbose ){NSLog( @"Gallery Connection Failed with Error" );}
      _error = [anError retain];
    
    [self.results setValue:@"ERROR"   forKey:@"RESPONSE_TYPE"];
    [self.results setValue:_error forKey:@"ERROR"];    
    [self.results setValue:[NSNumber numberWithBool:YES] forKey:@"HAS_ERROR"];

    _isRunning = false;    
    [self.delegate got:self.results];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if( self.bVerbose ){NSLog( @"Gallery Connection Completed Successfully" );}
    
    self.results = nil;
    self.results = [self parseRequest:_mutableData];

    _isRunning = false;    
    [self.delegate got:self.results];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [self.delegate updateTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

-(NSMutableDictionary*)parseRequest:(NSData *)myData
{
    // Get UTF8 String as a NSString from NSData response
    NSString *galleryResponseString = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];
    
    NSMutableDictionary *newResults = [[NSMutableDictionary new] autorelease];
    
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
    
    [newResults setValue:_error forKey:@"ERROR"];  // connection errors rather than syntax errors
    if( [newResults objectForKey:@"errors"] != nil ){
        [newResults setValue:[NSNumber numberWithBool:YES] forKey:@"HAS_ERROR"];
    } else {
        [newResults setValue:[NSNumber numberWithBool:NO] forKey:@"HAS_ERROR"];

    }
     

    
    
    
    return newResults;
}


@end
