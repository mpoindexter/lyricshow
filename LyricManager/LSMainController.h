//
//  LSMainController.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/4/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#import "LSLyricsContainerView.h"
#import "LSPresentationController.h"
#import "LSModel.h"

@interface LSMainController : NSObject 

@property (assign) IBOutlet LSModel* model;
@property (assign) IBOutlet LSPresentationController* presentationController;
@property (assign) IBOutlet NSPathControl* pathView;
@property (assign) IBOutlet LSLyricsContainerView* lyricsView;
@property (assign) IBOutlet NSWindow* window;
@property (assign) IBOutlet NSArrayController* screensArrayController;

- (IBAction)selectLyricsButtonWasClicked:(id)sender;

- (IBAction)selectCompositionButtonWasClicked:(id)sender;

- (IBAction)fullscreenButtonWasClicked:(id)sender;

- (void)refreshAvailableScreens;

@end
