//
//  SearchInfo.m
//  ManiaDB
//
//  Created by Appledelhi on 11/30/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "SearchInfo.h"
#import "ManiaDB.h"
#import "Amazon.h"
#import "AlbumArtExchange.h"
#import "CoverZzlZzl.h"

// @implementation SearchInfo
// 
// - (void)setSite:(SearchSite)site
// {
//   _site = site;
//   switch (site) {
//     case S_ManiaDB:
//     default:
//       _searcher = [[ManiaDB alloc] initMethod:_method];
//       break;
//     case S_Amazon:
//       _searcher = [[Amazon alloc] initMethod:_method site:site];
//       break;
//     case S_AmazonJapan:
//       _searcher = [[Amazon alloc] initMethod:_method site:site];
//       break;
//     case S_CoverZzlZzl:
//       _searcher = [[CoverZzlZzl alloc] initMethod:_method];
//       break;
//     case S_AlbumArtExchange:
//       _searcher = [[AlbumArtExchange alloc] initMethod:_method];
//       break;
//   }
// }
// 
// - (void)setMethod:(SearchMethod)method
// {
//   _method = method;
//   [_searcher setMethod:method];
// }
// 
// - initEnabled:(BOOL)enabled method:(SearchMethod)method site:(SearchSite)site
// {
//   _enabled = enabled;
//   _method = method;
//   [self setSite:site];
//   return self;
// }
// 
// - (void)searchArtist:(NSString *)artist song:(NSString*)song album:(NSString*)album
//             listView:(ListView*)listView
// {
//   if (_enabled) {
//     [_searcher searchArtist:artist song:song album:album listView:listView];
//   }
// }
// 
// @end

@implementation SiteToLabel

+ (Class)transformedValueClass
{
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
  return NO;
}

- transformedValue:value
{
  switch ([value intValue]) {
    case S_ManiaDB:
      return @"Mania DB";
    case S_Amazon:
      return @"Amazon";
    case S_AmazonJapan:
      return @"Amazon Japan";
    case S_CoverZzlZzl:
      return @"Cover ZzlZzl";
    case S_AlbumArtExchange:
      return @"Album Art Exchange";
    default:
      return @"Unknown";
  }
}

@end
