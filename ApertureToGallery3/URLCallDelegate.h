//
//  URLCallDelegate.h
//  Tutorial
//
//  Created by Scott Selberg on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLCallDelegate
-(void) got:(NSMutableDictionary *)results;
@end