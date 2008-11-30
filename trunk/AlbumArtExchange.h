//
//  AlbumArtExchange.h
//  ManiaDB
//
//  Created by Appledelhi on 11/30/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchInfo.h"

@class ListView;

@interface AlbumArtExchange : NSObject
{
  SearchMethod _method;
}

- initMethod:(SearchMethod)method;
- (void)searchArtist:(NSString*)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView;

@end
