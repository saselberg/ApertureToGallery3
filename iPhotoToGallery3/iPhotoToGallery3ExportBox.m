//
//  iPhotoToGallery3ExportBox.m
//  ApertureToGallery3
//
//  Created by Scott Selberg on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPhotoToGallery3ExportBox.h"


@implementation iPhotoToGallery3ExportBox

- (BOOL)performKeyEquivalent:(NSEvent *)anEvent
{
    NSString *keyString = [anEvent charactersIgnoringModifiers];
    unichar keyChar = [keyString characterAtIndex:0];
    switch (keyChar)
    {
        case NSFormFeedCharacter:
        case NSNewlineCharacter:
        case NSCarriageReturnCharacter:
        case NSEnterCharacter:
        {
            [mPlugin clickExport];
            return(YES);
        }
        default:
            break;
    }
    return([super performKeyEquivalent:anEvent]);
}
@end
