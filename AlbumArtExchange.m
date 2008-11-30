//
//  AlbumArtExchange.m
//  ManiaDB
//
//  Created by Appledelhi on 11/30/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "AlbumArtExchange.h"
#import "Util.h"
#import "ListView.h"
#import "AlbumView.h"

@implementation AlbumArtExchange

- initMethod:(SearchMethod)method
{
  _method = method;
  return self;
}

- (NSString*)imageURLFrom:(NSString*)url
{
  NSString* src = match(url, @"src=(.*)", 1);
  return format(@"http://www.albumartexchange.com%@",
                [src stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

// - (void)setImage:(NSArray*)array
// {
//   setImage([array objectAtIndex:0], [self imageFrom:[array objectAtIndex:1]]);
// }

- (void)searchArtist:(NSString*)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView
{
  NSString* url = format(@"http://www.albumartexchange.com/covers.php?sort=4&q=%@&omi=&bgc=&page=",
                         query(_method, escape(artist), escape(song), escape(album)));
  NSXMLDocument* doc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:url]
                                                            options:NSXMLDocumentTidyHTML error:nil];

  NSArray* items = nodes(doc, @"//table/tr/td/table");
  addSection(listView, format(@"Album Art Exchange: %@", section(_method, artist, song, album)));
  
  for (NSXMLNode* item in items) {
    NSString* album = textOf(item, @"tr/td//i");
    if (album) {
      AlbumView* albumView = add(listView);

      // [self performSelectorInBackground:@selector(setImage:)
      //                        withObject:[NSArray arrayWithObjects:albumView,
      //                                    textOf(item, @"tr/td/a/img/@src"), nil]];
      setImage(albumView, [self imageURLFrom:textOf(item, @"tr/td/a/img/@src")]);
      setAlbum(albumView, album);
      setArtist(albumView, textOf(item, @"tr[2]/td/a[2]"));
    }
  }
}

@end
