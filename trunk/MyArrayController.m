//
//  MyArrayController.m
//  ManiaDB
//
//  Created by Appledelhi on 11/30/08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "MyArrayController.h"

static NSString* MyTableViewDataType = @"MyTableViewDataType";

@implementation MyArrayController

- (BOOL)tableView:(NSTableView*)tableView writeRowsWithIndexes:(NSIndexSet*)rowIndexes
     toPasteboard:(NSPasteboard*)pboard
{
  NSData* data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
  [pboard declareTypes:[NSArray arrayWithObject:MyTableViewDataType] owner:self];
  [pboard setData:data forType:MyTableViewDataType];
  return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
  [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
  return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation
{
  NSPasteboard* pboard = [info draggingPasteboard];
  NSData* rowData = [pboard dataForType:MyTableViewDataType];
  NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
  int dragRow = [rowIndexes firstIndex];
  id obj = [[self arrangedObjects] objectAtIndex:dragRow];
  [self insertObject:obj atArrangedObjectIndex:row];
  [self removeObjectAtArrangedObjectIndex:dragRow > row ? dragRow + 1 : dragRow];
  return YES;
}

- (void)awakeFromNib
{
  [_tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
  [_tableView registerForDraggedTypes:[NSArray arrayWithObject:MyTableViewDataType]];
}

@end
