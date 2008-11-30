//
//  MyTextField.h
//  ManiaDB
//
//  Created by Appledelhi on 11/27/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyTextField : NSTextField {
  BOOL _nameClicked;
}

- (BOOL)nameClicked;

@end
