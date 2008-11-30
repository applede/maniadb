//
//  Amazon.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "Amazon.h"
#import "ListView.h"
#import "Util.h"
#import "AlbumView.h"

static NSDate* _next;

static NSString* siteCode(SearchSite site)
{
  if (site == S_AmazonJapan) {
    return @"jp";
  } else {
    return @"com";
  }
}

static NSString* siteLabel(SearchSite site)
{
  if (site == S_AmazonJapan) {
    return @" Japan";
  } else {
    return @"";
  }
}

@implementation Amazon

- initMethod:(SearchMethod)method site:(SearchSite)site
{
  _method = method;
  _site = site;
  return self;
}

- (void)search
{
  NSString* artistEsc = escape(_artist);
  NSString* songEsc = escape(_song);
  NSString* url = nil;
  if (_method == M_Artist) {
    url = format(@"http://ecs.amazonaws.%@/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=1GWA5J4TFTE4RDMAAR82&Operation=ItemSearch&SearchIndex=Music&Artist=%@&Version=2008-08-19&ResponseGroup=Images,Tracks,Medium&ItemPage=%d",
                 siteCode(_site), artistEsc, _page);
  } else {
    url = format(@"http://ecs.amazonaws.%@/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=1GWA5J4TFTE4RDMAAR82&Operation=ItemSearch&SearchIndex=Music&Keywords=%@&Version=2008-08-19&ResponseGroup=Images,Tracks,Medium&ItemPage=%d",
                 siteCode(_site), query(_method, artistEsc, songEsc, escape(_album)), _page);
  }
  if (_next) {
    [NSThread sleepUntilDate:_next];
  }
  NSXMLDocument* doc = xmlDoc(url);
  _next = [NSDate dateWithTimeIntervalSinceNow:1];
  _totalPage = [textOf(doc, @"//TotalPages") intValue];
  if (_totalPage == 0) {
    //NSLog(@"%@", [doc XMLString]);
  }
  NSArray* items = nodes(doc, @"//Item");
  int p = _totalPage > 0 ? _page : 0;
  addSection(_listView, format(@"Amazon%@: %@  (%d/%d)", siteLabel(_site), section(_method, _artist, _song, _album),
                               p, _totalPage));
  for (NSXMLNode* item in items) {
    AlbumView* albumView = add(_listView);
    
    setImage(albumView, textOf(item, @"LargeImage/URL"));
    setAlbum(albumView, unescape(textOf(item, @"ItemAttributes/Title")));
    
    NSString* artists = artistList(nodes(item, @"ItemAttributes/Artist"));
    if (!artists) {
      artists = artistList(nodes(item, @"ItemAttributes/Author"));
      if (!artists) {
        artists = artistList(nodes(item, @"ItemAttributes/Creator"));
      }
    }
    setArtist(albumView, artists);
    
    int year = yearFrom(textOf(item, @"ItemAttributes/OriginalReleaseDate"));
    if (year == 0) {
      year = yearFrom(textOf(item, @"ItemAttributes/PublicationDate"));
    }
    setYear(albumView, year);
    // if (0 == year) {
    //   NSLog(@"%@", [item XMLString]);
    // }
    NSArray* discs = nodes(item, @"Tracks/Disc");
    for (NSXMLNode* disc in discs) {
      NSString* discNumber = [discs count] > 1 ? textOf(disc, @"@Number") : nil;
      NSArray* tracks = nodes(disc, @"Track");
      for (NSXMLNode* s in tracks) {
        NSString* trackNumber = textOf(s, @"@Number");
        NSString* name = unescape([s stringValue]);
        addSong(albumView, name, discNumber, trackNumber, score(_song, name));
      }
    }
  }
  if (_page < _totalPage) {
    addButton(_listView, self, @selector(moreResults:));
  }
}

- (void)searchArtist:(NSString*)artist
          song:(NSString*)song album:(NSString*)album listView:(ListView*)listView
{
  _artist = artist;
  _song = song;
  _album = album;
  _page = 1;
  _listView = listView;
  [self search];
}

- (void)moreResults:sender
{
  if (_page < _totalPage) {
    [_listView removeButton:sender];
    _page++;
    [self search];
  }
}

@end
