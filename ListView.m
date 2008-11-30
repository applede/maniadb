//
//  ListView.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "ListView.h"
#import "AlbumView.h"

@implementation ListView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _y = 5;
  }
  return self;
}

- (BOOL)isFlipped
{
  return YES;
}

- (void)addSection:(NSString*)label
{
  NSTextField* view = [[NSTextField alloc] initWithFrame:NSMakeRect(0, _y, AlbumViewWidth, 20)];
  [view setAutoresizingMask:NSViewMaxYMargin];
  NSCell* cell = [view cell];
  [cell setFont:[NSFont fontWithName:[[cell font] fontName] size:16]];
  [view setStringValue:[NSString stringWithFormat:@"  %@", label]];
  [view setEditable:NO];
  [view setBezeled:NO];
  [view setBackgroundColor:[NSColor grayColor]];
  [view setTextColor:[NSColor whiteColor]];
  [self addSubview:view];
  _y += 25;
  [self setFrameSize:NSMakeSize(AlbumViewWidth, _y)];
}

- (void)addButton:target action:(SEL)action
{
  NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(10, _y, 80, 30)];
  [button setAutoresizingMask:NSViewMaxYMargin];
  [button setBezelStyle:NSRoundedBezelStyle];
  [button setTitle:@"More ..."];
  [button setTarget:target];
  [button setAction:action];
  [self addSubview:button];
  _y += 35;
  [self setFrameSize:NSMakeSize(AlbumViewWidth, _y)];
}

- (AlbumView*)add
{
  AlbumView* view = [[AlbumView alloc] initWithFrame:NSMakeRect(5, _y, AlbumViewWidth, 150)
                                              active:YES delegate:[NSApp delegate]];
  [view setAutoresizingMask:NSViewMaxYMargin];
  [self addSubview:view];
  _y += 155;
  [self setFrameSize:NSMakeSize(AlbumViewWidth, _y)];
  return view;
}

- (void)removeAll
{
  NSArray* views = [[self subviews] copy];
  for (NSView* view in views) {
    [view removeFromSuperview];
  }
  _y = 5;
  [self setFrameSize:NSMakeSize(AlbumViewWidth, _y)];
}

- (void)removeButton:(NSButton*)button
{
  [button removeFromSuperview];
}

@end
