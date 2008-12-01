//
//  AlbumView.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "AlbumView.h"
#import "MyTextField.h"
#import "Util.h"
#import "AppDelegate.h"

@implementation AlbumView

- (NSTextField*)addLabel:(NSRect)frame size:(int)controlSize action:(SEL)action
{
  MyTextField* label = [[MyTextField alloc] initWithFrame:frame];
  [label setAutoresizingMask:NSViewWidthSizable];
  [label setStringValue:@""];
  [label setEditable:NO];
  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setTextColor:[NSColor whiteColor]];
  [label setTarget:self];
  [label setAction:action];
  float fontSize = [NSFont systemFontSizeForControlSize:controlSize];
  NSCell* cell = [label cell];
  NSFont* font = [NSFont fontWithName:[[cell font] fontName] size:fontSize];
  [cell setFont:font];
  [cell setControlSize:controlSize];
  [cell setLineBreakMode:NSLineBreakByTruncatingTail];
  [self addSubview:label];
  return label;
}

- (NSButton*)addButton:(NSString*)label frame:(NSRect)frame size:(int)controlSize
                action:(SEL)action
{
  NSButton* button = [[NSButton alloc] initWithFrame:frame];
  [button setBezelStyle:NSRoundRectBezelStyle];
  [button setAutoresizingMask:NSViewMaxXMargin];
  [button setTitle:label];
  [button setTarget:self];
  [button setAction:action];
  float fontSize = [NSFont systemFontSizeForControlSize:controlSize];
  NSCell* cell = [button cell];
  NSFont* font = [NSFont fontWithName:[[cell font] fontName] size:fontSize];
  [cell setFont:font];
  [cell setControlSize:controlSize];
  [cell setLineBreakMode:NSLineBreakByTruncatingTail];
  [self addSubview:button];
  return button;
}

- (void)makeColumnX:(float)x y:(float)y
{
  for (int i = 0; i < 9; ++i) {
    [_tracks addObject:[self addLabel:NSMakeRect(x, y, 180, 13) size:NSMiniControlSize
                               action:@selector(trackClicked:)]];
    y -= 13;
  }
}

- (id)initWithFrame:(NSRect)frame active:(BOOL)active delegate:(AppDelegate*)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
      [self setAutoresizingMask:NSViewWidthSizable];
      _delegate = delegate;

      float buttonSize = frame.size.height - 10;
      if (active) {
        _image = [[NSButton alloc] initWithFrame:NSMakeRect(5, 10, buttonSize, buttonSize)];
        [_image setBezelStyle:NSRegularSquareBezelStyle];
        [_image setTitle:@""];
        [_image setTarget:self];
        [_image setAction:@selector(imageClicked:)];
      } else {
        _image = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 10, buttonSize, buttonSize)];
        [(id)_image setImageFrameStyle:NSImageFrameGroove];
      }
      [[_image cell] setImageScaling:NSImageScaleProportionallyDown];
      [self addSubview:_image];
      
      _imageSize = [self addLabel:NSMakeRect(5, -10, buttonSize, 20) size:NSMiniControlSize action:nil];
      [_imageSize setAlignment:NSCenterTextAlignment];
      [_imageSize setAutoresizingMask:0];
      
      float x = 5 + buttonSize + 5;
      float y = 5 + buttonSize - 11;
      float w = frame.size.width - x - 5 - 45;

      _album = [self addLabel:NSMakeRect(x, y, w, 20) size:NSRegularControlSize
                       action:@selector(albumClicked:)];
      if (active)
        _all = [self addButton:@"Set" frame:NSMakeRect(x + 5, y + 2, 40, 20)
                          size:NSMiniControlSize action:@selector(allClicked:)];
      y -= 22;
      _artist = [self addLabel:NSMakeRect(x, y, 295, 20) size:NSSmallControlSize
                        action:@selector(artistClicked:)];
      _year = [self addLabel:NSMakeRect(x + 300, y, 50, 20) size:NSSmallControlSize
                      action:@selector(yearClicked:)];
      _tracks = [NSMutableArray array];
      y -= 10;
      for (int i = 0; i < 4; ++i) {
        [self makeColumnX:x + (180 + 5) * i y:y];
      }
      _index = 0;
      _score = 0;
      _scoreIndex = -1;
    }
    return self;
}

- (void)setAlbum:(NSString*)album
{
  [_album setStringValue:album];
  [_album sizeToFit];
  [_album setToolTip:album];
  NSRect frame = [_album frame];
  if (_all)
    [_all setFrameOrigin:NSMakePoint(frame.origin.x + frame.size.width + 10, frame.origin.y - 3)];
}

- (void)setImage:(NSImage*)image
{
  [_image setImage:image];
  if (image && [image size].width > 0)
    [_imageSize setStringValue:[NSString stringWithFormat:@"%dx%d", (int)[image size].width,
                                (int)[image size].height]];
  else
    [_imageSize setStringValue:@""];
  [_image setNeedsDisplay:YES];
}

- (void)setImageFrom:(NSString*)url
{
  [self setImage:imageFrom(url)];
}

- (void)setArtist:(NSString*)artist
{
  if (artist) {
    [_artist setStringValue:artist];
    [_artist setToolTip:artist];
  }
}

- (void)setYear:(int)year
{
  if (year > 0) {
    [_year setIntValue:year];
  }
}

- (void)setTrackNumber:(int)trackNumber
{
  _trackNumber = trackNumber;
  if (_trackNumber > 0) {
    [[_tracks objectAtIndex:0] setStringValue:_song ? format(@"%d. %@", _trackNumber, _song) :
                                                      format(@"%d.", _trackNumber)];
  } else if (_song) {
    [[_tracks objectAtIndex:0] setStringValue:_song];
  }
}

- (void)setSong:(NSString*)song
{
  _song = song;
  NSTextField* track = [_tracks objectAtIndex:0];
  NSString* str = _trackNumber > 0 ? format(@"%d. %@", _trackNumber, _song) : _song;
  [track setStringValue:str];
  [track setToolTip:str];
}

- (void)addSong:(NSString*)song disc:(NSString*)disc track:(NSString*)trackNo score:(int)score
{
  NSString* label = disc ? format(@"%@-%@. %@", disc, trackNo, song) : format(@"%@. %@", trackNo, song);
  if (_index < [_tracks count]) {
    NSTextField* track = [_tracks objectAtIndex:_index];
    [track setStringValue:label];
    [track setToolTip:label];
    if (score > _score) {
      if (_scoreIndex >= 0)
        [[_tracks objectAtIndex:_scoreIndex] setTextColor:[NSColor whiteColor]];
      [track setTextColor:[NSColor greenColor]];
      _trackNumber = [trackNo intValue];
      _song = song;
      _score = score;
      _scoreIndex = _index;
    }
    _index++;
  }
}

- (void)setTrackImage:(NSImage*)image
{
  [[[[_delegate track] artworks] objectAtIndex:0] setData:(id)image];
  [[_delegate curView] setImage:image];
}

- (void)setTrackAlbum:(NSString*)str
{
  [[_delegate track] setAlbum:str];
  [[_delegate curView] setAlbum:str];
}

- (void)setTrackArtist:(NSString*)str
{
  [[_delegate track] setArtist:str];
  [[_delegate curView] setArtist:str];
}

- (void)setTrackYear:(int)year
{
  [[_delegate track] setYear:year];
  [[_delegate curView] setYear:year];
}

- (void)setTrackDisc:(int)disc number:(int)num
{
  id track = [_delegate track];
  [track setDiscNumber:disc];
  [track setTrackNumber:num];
  [track setTrackCount:0];
  [[_delegate curView] setTrackNumber:num];
}

- (void)setTrackName:(NSString*)str
{
  [[_delegate track] setName:str];
  [[_delegate curView] setSong:str];
}

- (void)imageClicked:sender
{
  NSImage* image = [_image image];
  if (image) {
    [self setTrackImage:image];
  }
}

- (void)albumClicked:sender
{
  NSString* str = [_album stringValue];
  if ([str length] > 0) {
    [self setTrackAlbum:str];
  }
}

- (void)artistClicked:sender
{
  NSString* str = [_artist stringValue];
  if ([str length] > 0) {
    [self setTrackArtist:str];
  }
}

- (void)yearClicked:sender
{
  int year = [_year intValue];
  if (year > 0) {
    [self setTrackYear:year];
  }
}

static NSString* trackPattern = @"(([^-]+)-)?([0-9]+)\\. (.*)";

- (void)trackClicked:sender
{
  NSString* str = [sender stringValue];
  NSString* disc = match(str, trackPattern, 2);
  NSString* track = match(str, trackPattern, 3);
  NSString* name = match(str, trackPattern, 4);
  if (track && name) {
    [self setTrackDisc:discFrom(disc) number:[track intValue]];
    if ([sender nameClicked]) {
      [self setTrackName:cleanUpTrackName(name, [_artist stringValue])];
    }
  }
}

- (void)allClicked:sender
{
  [self imageClicked:sender];
  [self albumClicked:sender];
  [self artistClicked:sender];
  [self yearClicked:sender];
  if (_scoreIndex >= 0) {
    [self trackClicked:[_tracks objectAtIndex:_scoreIndex]];
  }
}

@end
