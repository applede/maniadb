MyTableViewDataType = "MyTableViewDataType"

class MyArrayController < NSArrayController
  attr_accessor :tableView
  
  def tableView_writeRowsWithIndexes_toPasteboard(tableView, rowIndexes, pboard)
    data = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
    pboard.declareTypes_owner([MyTableViewDataType], self)
    pboard.setData_forType(data, MyTableViewDataType)
    true
  end
  
  def tableView_validateDrop_proposedRow_proposedDropOperation(tableView, info, row, op)
    tableView.setDropRow_dropOperation(row, NSTableViewDropAbove)
    NSDragOperationMove
  end
  
  def tableView_acceptDrop_row_dropOperation(tableView, info, row, op)
    pboard = info.draggingPasteboard
    rowData = pboard.dataForType(MyTableViewDataType)
    rowIndexes = NSKeyedUnarchiver.unarchiveObjectWithData(rowData)
    dragRow = rowIndexes.firstIndex
    obj = arrangedObjects.objectAtIndex(dragRow)
    insertObject_atArrangedObjectIndex(obj, row)
    removeObjectAtArrangedObjectIndex(dragRow > row ? dragRow + 1 : dragRow)
    true
  end
  
  def awakeFromNib
    @tableView.setDraggingSourceOperationMask_forLocal(NSDragOperationMove, true)
    @tableView.registerForDraggedTypes([MyTableViewDataType])
  end
end
