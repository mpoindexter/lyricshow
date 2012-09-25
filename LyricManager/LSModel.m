//
//  LSModel.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import "LSModel.h"

@implementation LSModel

@synthesize fullscreen;
@synthesize blankscreen;
@synthesize selectedLyricFile;
@synthesize compositionFile;
@synthesize compositionProperties;
@synthesize displayedText;
@synthesize selectedScreen;

-(id) init
{
    self = [super init];
    if (self != nil) {
        _lyricFiles = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(void) awakeFromNib
{
    [self init];
}

-(NSArray*) lyricFiles
{
    return _lyricFiles;
}

-(void) addLyricFile:(LSLyricFile *)file
{
    [self insertObject:file inLyricFilesAtIndex:[self countOfLyricFiles]];
}

-(void) removeLyricFile:(LSLyricFile *)file
{
    [self removeObjectFromLyricFilesAtIndex:[_lyricFiles indexOfObject:file]];
}

- (NSUInteger)countOfLyricFiles
{
    return [_lyricFiles count];
}

- (id)objectInLyricFilesAtIndex:(NSUInteger)index
{
    return [_lyricFiles objectAtIndex:index];
}

- (void)insertObject:(id)obj inLyricFilesAtIndex:(NSUInteger)index
{
    BOOL wasEmpty = ![self lyricFilesExist];
    [self willChangeValueForKey:@"lyricFilesExist"];
    [_lyricFiles insertObject:obj atIndex:index];
    [self didChangeValueForKey:@"lyricFilesExist"];
    if (wasEmpty) {
        [self setSelectedLyricFile:obj];
    }
}

- (void)removeObjectFromLyricFilesAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"lyricFilesExist"];
    [_lyricFiles removeObjectAtIndex:index];
    [self didChangeValueForKey:@"lyricFilesExist"];
}

- (void)replaceObjectInLyricFilesAtIndex:(NSUInteger)index withObject:(id)obj
{
    [_lyricFiles replaceObjectAtIndex:index withObject:obj];
}

- (BOOL)lyricFilesExist
{
    return [_lyricFiles count] > 0;
}
@end
