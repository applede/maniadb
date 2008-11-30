//
//  AlbumView.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface AlbumView : NSView {
  NSTextField* _album;
  NSButton* _all;
  AppDelegate* _delegate;
  NSButton* _image;
  NSTextField* _imageSize;
  NSTextField* _artist;
  NSTextField* _year;
  NSMutableArray* _tracks;
  int _index;
  int _score;
  int _scoreIndex;
  int _trackNumber;
  NSString* _song;
}

- (id)initWithFrame:(NSRect)frame active:(BOOL)active delegate:(AppDelegate*)delegate;
- (void)setAlbum:(NSString*)album;
- (void)setImage:(NSImage*)image;
- (void)setImageFrom:(NSString*)url;
- (void)setArtist:(NSString*)artist;
- (void)setYear:(int)year;
- (void)setTrackNumber:(int)trackNumber;
- (void)setSong:(NSString*)song;

- (void)addSong:(NSString*)song disc:(NSString*)disc track:(NSString*)track score:(int)score;

@end
