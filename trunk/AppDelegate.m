//
//  AppDelegate.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "AppDelegate.h"
#import "ListView.h"
#import "AlbumView.h"
#import "SearchInfo.h"
#import "ManiaDB.h"
#import "Amazon.h"
#import "CoverZzlZzl.h"
#import "AlbumArtExchange.h"

static NSDictionary* searchInfo(BOOL enabled, SearchMethod method, SearchSite site)
{
  return [NSMutableDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:enabled], @"enabled",
          [NSNumber numberWithInt:method], @"method",
          [NSNumber numberWithInt:site], @"site",
          nil];
}

@implementation AppDelegate

+ (void)initialize
{
  NSDictionary* defaultValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSMutableArray arrayWithObjects:
                                  searchInfo(YES, M_ArtistSong, S_ManiaDB),
                                  searchInfo(YES, M_Artist, S_ManiaDB),
                                  searchInfo(YES, M_Artist, S_Amazon),
                                  searchInfo(YES, M_Song, S_Amazon),
                                  searchInfo(YES, M_Artist, S_CoverZzlZzl),
                                  searchInfo(YES, M_Artist, S_AlbumArtExchange),
                                  searchInfo(YES, M_Artist, S_AmazonJapan),
                                  nil],
                                 @"searchers",
                                 nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
  // [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
}

- (void)setUpView
{
  _listView = [[ListView alloc] initWithFrame:[[_scrollView contentView] frame]];
  [_scrollView setDocumentView:_listView];
  
  NSSize s = [_contentView bounds].size;
  _curView = [[AlbumView alloc] initWithFrame:NSMakeRect(5, s.height - 155, AlbumViewWidth, 150)
                                       active:NO delegate:self];
  [_curView setAutoresizingMask:NSViewMinYMargin];
  [_curView setAlbum:@"Nothing Playing"];
  [_contentView addSubview:_curView];
}

- (void)showCurrent:(NSString*)artist album:(NSString*)album song:(NSString*)song track:track
{
  [_curView setArtist:artist];
  [_curView setTrackNumber:[track trackNumber]];
  [_curView setSong:song];
  [_curView setAlbum:album];
  [_curView setYear:[track year]];
  NSArray* artworks = [track artworks];
  if ([artworks count] > 0) {
    [_curView setImage:(id)[[artworks objectAtIndex:0] data]];
  } else {
    [_curView setImage:nil];
  }
}

- (id)eventDidFail:(const AppleEvent *)event withError:(NSError *)error
{
  return nil;
}

- (void)searchThread
{
  NSArray* searchers = [[NSUserDefaults standardUserDefaults] valueForKey:@"searchers"];
  for (NSDictionary* searchInfo in searchers) {
    BOOL enabled = [[searchInfo valueForKey:@"enabled"] boolValue];
    SearchMethod method = [[searchInfo valueForKey:@"method"] intValue];
    SearchSite site = [[searchInfo valueForKey:@"site"] intValue];
    if (!enabled) {
      continue;
    }
    id searcher = nil;
    switch (site) {
      case S_ManiaDB:
        searcher = [[ManiaDB alloc] initMethod:method];
        break;
      case S_Amazon:
      case S_AmazonJapan:
        searcher = [[Amazon alloc] initMethod:method site:site];
        break;
      case S_CoverZzlZzl:
        searcher = [[CoverZzlZzl alloc] initMethod:method];
        break;
      case S_AlbumArtExchange:
        searcher = [[AlbumArtExchange alloc] initMethod:method];
        break;
    }
    [searcher searchArtist:_artist song:_song album:_album listView:_listView];
  }
}

- (void)findInfo
{
  id iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
  [iTunes setDelegate:self];
  _track = [iTunes currentTrack];
  NSString* artist = [_track artist];
  if (artist) {
    NSString* album = [_track album];
    NSString* song = [_track name];
    if ([song isEqualToString:_song] && [artist isEqualToString:_artist])
      return;
    if (_thread) {
      [_thread cancel];
      [NSThread sleepForTimeInterval:1];
    }
    _album = album;
    _song  = song;
    _artist = artist;
    [self showCurrent:artist album:album song:song track:_track];
    [_window orderFront:self];
    [_listView removeAll];
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(searchThread) object:nil];
    [_thread start];
  }
}

- (void)iTunesNotification:(NSNotification*)notification
{
  if ([[[notification userInfo] valueForKey:@"Player State"] isEqualToString:@"Playing"]) {
    [self findInfo];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
  [self setUpView];
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(iTunesNotification:)
                                                          name:@"com.apple.iTunes.playerInfo"
                                                        object:nil];
  [self findInfo];
}

- (AlbumView*)curView
{
  return _curView;
}

- (id<ITunes>)track
{
  return _track;
}

- (void)didEndSheet:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
  [sheet orderOut:self];
}

- (IBAction)endSheet:sender
{
  [NSApp endSheet:_addSheet];
}

- (IBAction)add:sender
{
  [NSApp beginSheet:_addSheet modalForWindow:_preferences modalDelegate:self
    didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
  [_searchController addObject:searchInfo(YES, M_Artist, S_ManiaDB)];
}

- (IBAction)remove:sender
{
  [_searchController remove:sender];
}

- (IBAction)save:sender
{
  [_preferences orderOut:self];
}

- (void)awakeFromNib
{
  [self willChangeValueForKey:@"searchers"];
  _searchers = [[NSUserDefaults standardUserDefaults] valueForKey:@"searchers"];
  [self didChangeValueForKey:@"searchers"];
}

@end
