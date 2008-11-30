//
//  Amazon.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchInfo.h"

@class ListView;

@interface Amazon : NSObject
{
  SearchMethod _method;
  SearchSite _site;
  NSString* _artist;
  NSString* _song;
  NSString* _album;
  ListView* _listView;
  int _page;
  int _totalPage;
}

- initMethod:(SearchMethod)method site:(SearchSite)site;
- (void)searchArtist:(NSString*)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView;

@end
