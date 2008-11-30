//
//  AppDelegate.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ListView;
@class AlbumView;
@class MyArrayController;

// To eliminate warnings
@protocol ITunes

- artworks;
- setDiscNumber:(int)d;
- setTrackCount:(int)n;
- (int)trackNumber;
- currentTrack;
- artist;
- (void)setArtist:(NSString*)str;
- album;
- (void)setAlbum:(NSString*)str;
- (void)setYear:(int)year;
- (void)setName:(NSString*)str;

@end

@interface AppDelegate : NSObject {
  IBOutlet NSWindow* _window;
  IBOutlet NSWindow* _preferences;
  IBOutlet NSWindow* _addSheet;
  IBOutlet NSScrollView* _scrollView;
  IBOutlet NSView* _contentView;
  IBOutlet MyArrayController* _searchController;
  ListView* _listView;
  AlbumView* _curView;
  id _track;
  NSString* _song;
  NSString* _album;
  NSString* _artist;
  NSMutableArray* _searchers;
  NSThread* _thread;
}

- (AlbumView*)curView;
- (id<ITunes>) track;
- (IBAction)add:sender;
- (IBAction)remove:sender;
- (IBAction)endSheet:sender;
- (IBAction)save:sender;

@end
