//
//  SearchInfo.h
//  ManiaDB
//
//  Created by Appledelhi on 11/29/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ListView;

typedef enum {
  M_Artist              = 0x01,
  M_Song                = 0x02,
  M_ArtistSong          = 0x03,
  M_Album               = 0x04,
  M_ArtistAlbum         = 0x05,
  M_SongAlbum           = 0x06,
  M_ArtistSongAlbum     = 0x07
} SearchMethod;

typedef enum {
  S_ManiaDB,
  S_Amazon,
  S_AmazonJapan,
  S_CoverZzlZzl,
  S_AlbumArtExchange
} SearchSite;

// @interface SearchInfo : NSObject
// {
//   BOOL _enabled;
//   SearchMethod _method;
//   SearchSite _site;
//   id _searcher;
// }
// 
// - initEnabled:(BOOL)enabled method:(SearchMethod)method site:(SearchSite)site;
// - (void)searchArtist:(NSString *)artist song:(NSString*)song album:(NSString*)album
//             listView:(ListView*)listView;
// 
// @end

NSString* query(SearchMethod m, NSString *artist, NSString* song, NSString* album);
NSString* section(SearchMethod m, NSString *artist, NSString* song, NSString* album);

@interface SiteToLabel: NSValueTransformer
{
  
}

@end
