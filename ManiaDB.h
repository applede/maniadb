//
//  ManiaDB.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchInfo.h"

@class ListView;

@interface ManiaDB : NSObject
{
  SearchMethod _method;
  NSMutableDictionary* _ids;
}

- initMethod:(SearchMethod)method;
- (void)searchArtist:(NSString *)artist song:(NSString*)song album:(NSString*)album
            listView:(ListView*)listView;

@end
