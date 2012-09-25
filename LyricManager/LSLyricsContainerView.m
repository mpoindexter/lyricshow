//
//  LSLyricsContainerView.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/5/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#include <objc/runtime.h>
#import "LSLyricsContainerView.h"


static char kChunkKey;

@implementation LSLyricsContainerView

@synthesize model = _model;

+(void) initialize
{
    [LSLyricsContainerView exposeBinding:@"lyrics"];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void)viewDidActivate:(NSTextView*) view
{
    if (view == _activeView) {
        return;
    }
    
    [view setBackgroundColor:[NSColor redColor]];
    if (_activeView != nil) {
        [_activeView setBackgroundColor:[NSColor whiteColor]];
    }
    
    _activeView = view;
    if (_activeView != nil) {
        LSLyricChunk* chunk = objc_getAssociatedObject(_activeView, &kChunkKey);
        [_model setDisplayedText:chunk.displayText];
    } else {
        [_model setDisplayedText:@""];
    }
}

- (BOOL)isFlipped 
{
    return YES;
}

- (void) setLyrics: (LSLyricFile*) lyrics
{
    _lyrics = lyrics;
    [[self  subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _activeView = nil;
    
    int h = 0;
    int w = [self frame].size.width;
    for (int i = 0; i < [lyrics.chunks count]; i++) {
        LSLyricChunk* chunk = [lyrics.chunks objectAtIndex:i];
        NSRect frame = NSMakeRect(0, 0, w, MAXFLOAT);
        NSTextView *tv = [[[NSTextView alloc] initWithFrame:frame] autorelease];
        [tv setString:chunk.rawText];
        [tv setHorizontallyResizable:NO];
        [tv setEditable:NO];
        [tv setSelectable:NO];
        [tv setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin | NSViewMinXMargin];
        [tv sizeToFit];
        [tv setFrameOrigin:NSMakePoint(0, h)];
        h += [tv frame].size.height;
        [self setFrameSize:NSMakeSize(w, h)];
        [self addSubview:tv];
        objc_setAssociatedObject(tv, &kChunkKey, chunk, OBJC_ASSOCIATION_ASSIGN);
    }
    
    [[self superview] setNeedsDisplay:YES];
    [self setNeedsDisplay:YES];
}
- (LSLyricFile*) lyrics
{
    return _lyrics;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

- (void)keyUp:(NSEvent *)theEvent
{
    if ([[theEvent characters] isEqualToString:@"c"]) {
        [self viewDidActivate:nil];
        return;
    }
    
    if ([[theEvent characters] isEqualToString:@"b"]) {
        [_model setBlankscreen:!_model.blankscreen];
        return;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[self window] makeFirstResponder:self];
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    for (int i = 0; i < [self subviews].count; i++) {
        NSTextView* subview = [[self subviews] objectAtIndex:i];
        if (NSPointInRect(point, [subview frame])) {
            [self viewDidActivate:subview];
        }
    }
    [super mouseUp:theEvent];
}

-(IBAction)moveUp:(id)sender
{
    if (_activeView != nil) {
        NSUInteger activeIdx = [[self subviews] indexOfObject:_activeView];
        if (activeIdx != NSNotFound && activeIdx > 0) {
            [self viewDidActivate:[self.subviews objectAtIndex:activeIdx - 1]];
        }
    }
}

-(IBAction)moveDown:(id)sender
{
    if (_activeView != nil) {
        NSUInteger activeIdx = [[self subviews] indexOfObject:_activeView];
        if (activeIdx != NSNotFound && activeIdx + 1 < self.subviews.count) {
            [self viewDidActivate:[self.subviews objectAtIndex:activeIdx + 1]];
        }
    }
}



@end
