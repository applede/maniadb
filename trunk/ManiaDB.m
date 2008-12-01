//
//  ManiaDB.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "ManiaDB.h"
#import "ListView.h"
#import "AlbumView.h"
#import "RegexKitLite/RegexKitLite.h"
#import "Util.h"

static NSString* albumIdFrom(NSString* str)
{
  return [str stringByMatching:@".*a=([0-9]+)" capture:1];
}

static NSString* largeVersion(NSString* str)
{
  if (includes(str, @"popLargeCover")) {
    return str;
  }
  return [str stringByReplacingOccurrencesOfRegex:@"www\\." withString:@"image."];
}

static NSString* hackVersion(NSString* str, int i)
{
  NSString* number = match(str, @"a=([0-9]+)", 1);
  NSString* three = match(number, @"...", 0);
  switch (i) {
  case 0:
    return format(@"http://image.maniadb.com/images/album/%@/%@_f_1.jpg", three, number);
  case 1:
    return format(@"http://image.maniadb.com/images/album/%@/%@_1_f.jpg", three, number);
  case 2:
    return format(@"http://image.maniadb.com/images/album/%@/%@_2_f.jpg", three, number);
  case 3:
    return format(@"http://image.maniadb.com/images/album/%@/%@_mca_f.jpg", three, number);
  case 4:
    return format(@"http://image.maniadb.com/images/album/%@/%@_cda_f.jpg", three, number);
  case 5:
    return format(@"http://image.maniadb.com/images/album/%@/%@_f.jpg", three, number);
  case 6:
    return format(@"http://image.maniadb.com/images/album/%@/%@_0_f.jpg", three, number);
  case 7:
    return format(@"http://image.maniadb.com/images/album/%@/%@_f_2.jpg", three, number);
  default:
    return nil;
  }
}

static NSString* chomp(NSString* str)
{
  return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@implementation ManiaDB

- initMethod:(SearchMethod)method
{
  _method = method;
  return self;
}

- (NSArray*)uniqItems:(NSArray*)items
{
  NSMutableArray* results = [NSMutableArray array];
  for (NSXMLNode* item in items) {
    NSString* albumId = _method == 0 ? albumIdFrom(textOf(item, @"maniadb:album/link")) :
                                       textOf(item, @"@id");
    if (![_ids objectForKey:albumId]) {
      [_ids setObject:item forKey:albumId];
      [results addObject:item];
    }
  }
  return results;
}

- (void)searchArtist:(NSString*)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView
{
  _ids = [NSMutableDictionary dictionary];
  NSString* artistEsc = escape(artist);
  NSString* songEsc = escape(song);
  NSString* url = nil;
  if (_method == M_ArtistSong) {
    url = format(@"http://www.maniadb.com/api/search.asp?key=d232a03189c58cab2868&target=music&display=10&itemtype=song&option=song&query=%@&option2=artist&query2=%@",
                 songEsc, artistEsc);
  } else if (_method == M_Artist) {
    url = format(@"http://www.maniadb.com/api/search.asp?key=d232a03189c58cab2868&target=music&display=10&itemtype=album&option2=artist&query2=%@",
                 artistEsc);
  } else {
    NSString* queryStr = query(_method, artistEsc, songEsc, escape(album));
    if ([queryStr length] == 0) {
      return;
    }
    url = format(@"http://www.maniadb.com/api/search.asp?key=d232a03189c58cab2868&target=music&display=10&itemtype=album&option=album&query=%@",
                 queryStr);
  }
  NSXMLDocument* doc = xmlDoc(url);
  NSArray* items = [self uniqItems:nodes(doc, @"//item")];
  addSection(listView, format(@"Mania DB: %@", section(_method, artist, song, album)));

  for (NSXMLNode* item in items) {
    AlbumView* albumView = add(listView);
    NSString* albumId = _method == M_ArtistSong ? albumIdFrom(textOf(item, @"maniadb:album/link")) :
                                 textOf(item, @"@id");
    url = [NSString stringWithFormat:@"http://www.maniadb.com/api/album.asp?key=d232a03189c58cab2868&a=%@", albumId];
    NSXMLDocument* albumDoc = xmlDoc(url);

    NSString* imageURL = textOf(albumDoc, @"//image");
    if (!setImageDirect(albumView, largeVersion(imageURL))) {
      for (int i = 0; i < 100; i++) {
        NSString* str = hackVersion(imageURL, i);
        if (str) {
          if (setImageDirect(albumView, str)) {
            break;
          }
        } else {
          NSLog(@"%@", imageURL);
          break;
        }
      }
    }
    setArtist(albumView, textOf(albumDoc, @"//maniadb:artist/name"));
    setAlbum(albumView, textOf(albumDoc, @"//maniadb:shorttitle"));
    setYear(albumView, yearFrom(textOf(albumDoc, @"//item/releasedate")));
    NSArray* discs = nodes(albumDoc,@"//disc");
    for (NSXMLNode* disc in discs) {
      NSString* discNumber = [discs count] > 1 ? chomp(textOf(disc, @"@no")) : nil;
      NSArray* songs = nodes(disc, @"song");
      for (NSXMLNode* s in songs) {
        NSString* trackNumber = textOf(s, @"@track");
        NSString* name = textOf(s, @"title");
        addSong(albumView, name, discNumber, trackNumber, score(song, name));
      }
    }
  }
}

@end
