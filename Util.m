//
//  Util.m
//  ManiaDB
//
//  Created by Appledelhi on 11/28/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "Util.h"
#import "SearchInfo.h"
#import "AlbumView.h"

int score(NSString* a, NSString* b)
{
  if ([a isEqualToString:b]) {
    return 100;
  } else {
    NSString* as = [a lowercaseString];
    NSString* bs = [b lowercaseString];
    int alen = [as length];
    int blen = [bs length];
    if ([as isEqualToString:bs]) {
      return 99;
    } else if (includes(bs, as)) {
      return 98 - (blen - alen);
    } else if (includes(as, bs)) {
      return 97 - (alen - blen);
    } else {
      NSString* am = gsub(as, @"feat(\\.|uring).*", @"");
      NSString* bm = gsub(bs, @"feat(\\.|uring).*", @"");
      am = gsub(am, @"[- .,!'/\"\\?\\(\\)]", @"");
      bm = gsub(bm, @"[- .,!'/\"\\?\\(\\)]", @"");
      int alen = [am length];
      int blen = [bm length];
      if ([am isEqualToString:bm]) {
        return 96;
      } else if (includes(bm, am)) {
        return 95 - (blen - alen);
      } else if (includes(am, bm)) {
        return 94 - (alen - blen);
      } else {
        return 0;
      }
    }
  }
}

NSString* textOf(NSXMLNode* node, NSString* path)
{
  NSArray* array = [node nodesForXPath:path error:nil];
  if ([array count] > 0)
    return [[array objectAtIndex:0] stringValue];
  return nil;
}

NSImage* imageFrom(NSString* str)
{
  if (!str) return nil;
  NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str]];
  // NSImage* image = [[NSImage alloc] initByReferencingURL:[NSURL URLWithString:str]];
  NSImage* image = [[NSImage alloc] initWithData:data];
  if (image) {
    NSArray* array = [image representations];
    if ([array count] > 0) {
      NSImageRep* rep = [array objectAtIndex:0];
      [image setSize:NSMakeSize([rep pixelsWide], [rep pixelsHigh])];
    }
  }
  return image;
}

int discFrom(NSString* str)
{
  if (str) {
    unichar c = [str characterAtIndex:0];
    if (c >= '0' && c <= '9') {
      return [str intValue];
    } else if (c >= 'A' && c <= 'Z') {
      return c - 'A' + 1;
    } else if (c >= 'a' && c <= 'z') {
      return c - 'a' + 1;
    }
  }
  return 0;
}

NSString* cleanUpTrackName(NSString* str, NSString* artist)
{
  NSString* pattern = @"(.*) - (.*)";
  NSString* left = match(str, pattern, 1);
  NSString* right = match(str, pattern, 2);
  if (left && right && includes(right, artist)) {
    return left;
  }
  return str;
}

NSString* query(SearchMethod m, NSString* artist, NSString* song, NSString* album)
{
  NSMutableArray* array = [NSMutableArray array];
  if (m & M_Artist && artist) {
    [array addObject:artist];
  }
  if (m & M_Song && song) {
    [array addObject:song];
  }
  if (m & M_Album && album) {
    [array addObject:album];
  }
  return [array componentsJoinedByString:@"+"];
}

NSString* section(SearchMethod m, NSString* artist, NSString* song, NSString* album)
{
  NSMutableArray* array = [NSMutableArray array];
  if (m & M_Artist && artist) {
    [array addObject:artist];
  }
  if (m & M_Song && song) {
    [array addObject:song];
  }
  if (m & M_Album && album) {
    [array addObject:album];
  }
  return [array componentsJoinedByString:@" + "];
}

AlbumView* add(ListView* listView)
{
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:
                       [listView methodSignatureForSelector:@selector(add)]];
  [inv setTarget:listView];
  [inv setSelector:@selector(add)];
  [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
  AlbumView* result;
  [inv getReturnValue:&result];
  return result;
}

void addSong(AlbumView* albumView, NSString* song, NSString* discNumber, NSString* trackNumber, int score)
{
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:
                       [albumView methodSignatureForSelector:@selector(addSong:disc:track:score:)]];
  [inv setTarget:albumView];
  [inv setSelector:@selector(addSong:disc:track:score:)];
  [inv setArgument:&song atIndex:2];
  [inv setArgument:&discNumber atIndex:3];
  [inv setArgument:&trackNumber atIndex:4];
  [inv setArgument:&score atIndex:5];
  [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}

void addButton(ListView* listView, id target, SEL action)
{
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:
                       [listView methodSignatureForSelector:@selector(addButton:action:)]];
  [inv setTarget:listView];
  [inv setSelector:@selector(addButton:action:)];
  [inv setArgument:&target atIndex:2];
  [inv setArgument:&action atIndex:3];
  [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}

void setImage(AlbumView* albumView, NSString* url)
{
  if ([[NSThread currentThread] isCancelled]) {
    [NSThread exit];
  }
  [albumView performSelectorInBackground:@selector(setImageFrom:) withObject:url];
}

BOOL setImageDirect(AlbumView* albumView, NSString* url)
{
  if ([[NSThread currentThread] isCancelled]) {
    [NSThread exit];
  }
  NSImage* image = imageFrom(url);
  [albumView setImage:image];
  return image != nil;
}
