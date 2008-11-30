//
//  MyTextField.m
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "MyTextField.h"


@implementation MyTextField

- (void)mouseUp:(NSEvent*)event
{
  [super mouseUp:event];
  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
  _nameClicked = (p.x > 30);
  [self sendAction:[self action] to:[self target]];
}

- (BOOL)nameClicked
{
  return _nameClicked;
}

@end
