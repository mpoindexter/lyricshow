//
//  LSLyricChunk.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Foundation/Foundation.h>

@interface LSLyricChunk : NSObject

@property (retain) NSString* rawText;
@property (retain) NSString* displayText;

-(id)initWithRawText:(NSString*)rawText displayText:(NSString*)displayText;
@end
