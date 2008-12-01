//
//  Util.h
//  ManiaDB
//
//  Created by Appledelhi on 11/28/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RegexKitLite/RegexKitLite.h"
#import "ListView.h"

static inline BOOL includes(NSString* a, NSString* b)
{
  return [a rangeOfString:b].location != NSNotFound;
}

static inline NSString* gsub(NSString* str, NSString* pattern, NSString* replace)
{
  return [str stringByReplacingOccurrencesOfRegex:pattern withString:replace];
}

static inline NSString* match(NSString* str, NSString* pattern, int capture)
{
  return [str stringByMatching:pattern capture:capture];
}

static inline NSString* format(NSString* f, ...)
{
  va_list ap;
  va_start(ap, f);
  NSString* str = [[NSString alloc] initWithFormat:f arguments:ap];
  va_end(ap);
  return str;
}

static inline NSString* escape(NSString* str)
{
  return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

static inline NSString* unescape(NSString* str)
{
  return [[str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
          stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

static inline NSXMLDocument* xmlDoc(NSString* url)
{
  return [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:url]
                                              options:0 error:nil];
}

static inline NSArray* nodes(NSXMLNode* node, NSString* path)
{
  return [node nodesForXPath:path error:nil];
}

static inline NSArray* map(NSArray* array, SEL sel)
{
  NSMutableArray* narray = [NSMutableArray arrayWithCapacity:[array count]];
  for (id e in array) {
    [narray addObject:[e performSelector:sel]];
  }
  return narray;
}

static inline NSString* artistList(NSArray* nodes)
{
  if (nodes && [nodes count] > 0) {
    return unescape([map(nodes, @selector(stringValue)) componentsJoinedByString:@", "]);
  } else {
    return nil;
  }
}

static int yearFrom(NSString* str)
{
  return [[str stringByMatching:@"[0-9]+"] intValue];
}

static void addSection(ListView* listView, NSString* label)
{
  [listView performSelectorOnMainThread:@selector(addSection:) withObject:label waitUntilDone:YES];
}

static void setAlbum(AlbumView* albumView, NSString* str)
{
  [albumView performSelectorOnMainThread:@selector(setAlbum:) withObject:str waitUntilDone:NO];
}

static void setArtist(AlbumView* albumView, NSString* str)
{
  [albumView performSelectorOnMainThread:@selector(setArtist:) withObject:str waitUntilDone:NO];
}

static void setYear(AlbumView* albumView, int year)
{
  [albumView performSelectorOnMainThread:@selector(setYear:) withObject:(id)year waitUntilDone:NO];
}

AlbumView* add(ListView* listView);
void addButton(ListView* listView, id target, SEL action);
void addSong(AlbumView* albumView, NSString* song, NSString* discNumber, NSString* trackNumber,
             int score);
NSString* textOf(NSXMLNode* node, NSString* path);
NSImage* imageFrom(NSString* str);
int discFrom(NSString* str);
int score(NSString* a, NSString* b);
NSString* cleanUpTrackName(NSString* str, NSString* artist);
void setImage(AlbumView* albumView, NSString* url);
BOOL setImageDirect(AlbumView* albumView, NSString* url);
