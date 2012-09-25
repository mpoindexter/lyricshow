//
//  LSMainController.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/4/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import "LSMainController.h"

static void OnDisplayReconfigured (CGDirectDisplayID display,
                                   CGDisplayChangeSummaryFlags flags,
                                   void *userInfo)
{
    if (!(flags & kCGDisplayBeginConfigurationFlag)) {
        [(LSMainController*)userInfo refreshAvailableScreens];
    }
}

@implementation LSMainController
@synthesize presentationController = _presentationController;
@synthesize pathView = _pathView;
@synthesize lyricsView = _lyricsView;
@synthesize window = _window;
@synthesize screensArrayController = _screensArrayController;
@synthesize model = _model;

- (NSString*) _screenNameForDisplay:(NSScreen*) screen
{
    NSDictionary* screenDictionary = [screen deviceDescription];
    NSNumber* screenID = [screenDictionary objectForKey:@"NSScreenNumber"];
    CGDirectDisplayID displayID = [screenID unsignedIntValue];
    
    NSString *screenName = nil;
    
    NSDictionary *deviceInfo = (NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName);
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
    
    if ([localizedNames count] > 0) {
        screenName = [[localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]] retain];
    }
    
    [deviceInfo release];
    return [screenName autorelease];
}

- (void)awakeFromNib
{
    
    [self refreshAvailableScreens];
    [_model setSelectedScreen:[NSScreen mainScreen]];
    [_model addObserver:self forKeyPath:@"displayedText" options:NSKeyValueObservingOptionInitial context:nil];
    
    [_presentationController bind:@"displayScreen" toObject:_model withKeyPath:@"selectedScreen" options:nil];
    [_presentationController bind:@"compositionFile" toObject:_model withKeyPath:@"compositionFile.path" options:nil];
    [_presentationController bind:@"fullscreen" toObject:_model withKeyPath:@"fullscreen" options:nil];
    [_presentationController bind:@"blankscreen" toObject:_model withKeyPath:@"blankscreen" options:nil];
    
    [_lyricsView bind:@"lyrics" toObject:_model withKeyPath:@"selectedLyricFile" options:nil];
    
    CGDisplayRegisterReconfigurationCallback(&OnDisplayReconfigured, self);
}
    
- (void)refreshAvailableScreens
{
    NSArray* allScreens = [NSScreen screens];
    NSMutableArray* screenDisplay = [[[NSMutableArray alloc] initWithCapacity:allScreens.count] autorelease];
    for (int i = 0; i < allScreens.count; i++) {
        NSScreen* screen = [allScreens objectAtIndex:i];
        [screenDisplay addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                                   screen, @"screen", 
                                   [self _screenNameForDisplay:screen], @"name", 
                                   nil ]];
    }
    
    [_screensArrayController setContent:screenDisplay];
    if ([screenDisplay indexOfObject:_model.selectedScreen] == NSNotFound) {
        [_model setSelectedScreen:[NSScreen mainScreen]];
    }
}

- (IBAction)selectLyricsButtonWasClicked:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ( [openDlg runModal] == NSOKButton ) {
        NSArray *files = [openDlg URLs];
        if( [files count] > 0 ) {
            NSURL* url = [files objectAtIndex: 0];
            LSLyricFile* lyricFile = [[[LSLyricFile alloc] initWithFile:url] autorelease];
            if (lyricFile != nil) {
                [_model addLyricFile:lyricFile];
            }
        }
    }
}

- (IBAction)selectCompositionButtonWasClicked:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"qtz", nil];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    
    if ( [openDlg runModal] == NSOKButton ) {
        NSArray *files = [openDlg URLs];
        if( [files count] > 0 ) {
            NSURL* url = [files objectAtIndex: 0];
            [_model setCompositionFile:url];
        }
    }

}

- (IBAction)fullscreenButtonWasClicked:(id)sender
{
    [_model setFullscreen:![_model fullscreen]];
}

- (BOOL) compositionParameterView:(QCCompositionParameterView *)parameterView shouldDisplayParameterWithKey:(NSString *)portKey attributes:(NSDictionary *)portAttributes {
    if ([portKey isEqualToString:@"Text"]) {
        return NO;
    }
    
    if ([portKey isEqualToString:@"Transition"]) {
        return NO;
    }
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _model && [keyPath isEqualToString:@"displayedText"]) {
        [_presentationController pauseRendering];
        [_presentationController.renderer setValue:[NSNumber numberWithBool:YES] forInputKey:@"Transition"];
        [_presentationController.renderer setValue:[_model displayedText] forInputKey:@"Text"];
        [_presentationController resumeRendering];
        [_presentationController.renderer setValue:[NSNumber numberWithBool:NO] forInputKey:@"Transition"];
        return;
    }
}


@end
