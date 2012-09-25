//
//  LSModel.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Foundation/Foundation.h>
#import "LSLyricFile.h"

@interface LSModel : NSObject
{
    NSMutableArray* _lyricFiles;
}

@property (assign) BOOL fullscreen;
@property (assign) BOOL blankscreen;
@property (readonly) NSArray* lyricFiles;
@property (readonly) BOOL lyricFilesExist;
@property (assign) LSLyricFile* selectedLyricFile;
@property (retain) NSURL* compositionFile;
@property (retain) id compositionProperties;
@property (retain) NSString* displayedText;
@property (assign) NSScreen* selectedScreen;

-(id)init;
-(void)addLyricFile:(LSLyricFile*)file;
-(void)removeLyricFile:(LSLyricFile*)file;

- (NSUInteger)countOfLyricFiles;
- (id)objectInLyricFilesAtIndex:(NSUInteger)index;
- (void)insertObject:(id)obj inLyricFilesAtIndex:(NSUInteger)index;
- (void)removeObjectFromLyricFilesAtIndex:(NSUInteger)index;
- (void)replaceObjectInLyricFilesAtIndex:(NSUInteger)index withObject:(id)obj;

@end
