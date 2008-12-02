//
//  CoverZzlZzl.m
//  ManiaDB
//
//  Created by Appledelhi on 11/30/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "CoverZzlZzl.h"
#import "Util.h"
#import "AlbumView.h"
#import "ListView.h"

@implementation CoverZzlZzl

- initMethod:(SearchMethod)method
{
  _method = method;
  return self;
}

- imageURLFrom:(NSString*)url
{
  NSError* err = nil;
  NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                           encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR)
                                           error:&err];
  return match(html, @"<img src='([^']*)'>", 1);
}

- (void)searchArtist:(NSString*)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView
{
  int encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingEUC_KR);
  // sometimes stringByAddingPercentEscapesUsingEncoding: doesn't work
  const char* bytes = [artist cStringUsingEncoding:encoding];
  if (!bytes) {
    return;
  }
  artist = [[NSString alloc] initWithBytes:bytes length:strlen(bytes) encoding:encoding];
  NSString* url = format(@"http://cover.zzlzzl.net/?search_str=%@&mode=search&Submit=Submit",
                         query(_method,
                               [artist stringByAddingPercentEscapesUsingEncoding:encoding],
                               [song stringByAddingPercentEscapesUsingEncoding:encoding],
                               [album stringByAddingPercentEscapesUsingEncoding:encoding]));
  NSError* err = nil;
  NSString* html = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                           encoding:encoding
                                           error:&err];
  if (!html) {
    return;
  }
  NSXMLDocument* doc = [[NSXMLDocument alloc] initWithXMLString:html options:NSXMLDocumentTidyHTML error:&err];
  NSArray* items = nodes(doc, @"//tr");
  addSection(listView, format(@"Cover ZzlZzl: %@", section(_method, artist, song, album)));

  int i = 0;
  for (NSXMLNode* item in items) {
    if (i++ == 0) {  // avoid first row (header)
      continue;
    }
    if (i > 10) {
      break;
    }
    AlbumView* albumView = add(listView);
  
    NSString* imageURL = textOf(item, @"td[1]/div/a/@href");
    setImage(albumView, [self imageURLFrom:format(@"http://cover.zzlzzl.net/%@", imageURL)]);
    NSString* artist = textOf(item, @"td[2]/div");
    setArtist(albumView, artist);
    NSString* album = textOf(item, @"td[3]/div/a");
    setAlbum(albumView, album);
    int year = yearFrom(textOf(item, @"td[5]/div"));
    [albumView setYear:year];
  }
}

@end
