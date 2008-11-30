//
//  ListView.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define AlbumViewWidth (5 + 150 + 5 + (180 + 5) * 4)

@class AlbumView;

@interface ListView : NSView {
  float _y;
}

- (void)addSection:(NSString*)label;
- (AlbumView*)add;
- (void)addButton:target action:(SEL)action;
- (void)removeAll;
- (void)removeButton:(NSButton*)button;

@end
