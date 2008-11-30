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
    url = format(@"http://www.maniadb.com/api/search.asp?key=d232a03189c58cab2868&target=music&display=10&itemtype=album&option2=artist&query2=%@",
                 query(_method, artistEsc, songEsc, escape(album)));
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
    NSLog(@"%@", largeVersion(textOf(albumDoc, @"//image")));
    setImage(albumView, largeVersion(textOf(albumDoc, @"//image")));
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
