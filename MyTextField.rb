include OSX

class MyTextField < NSTextField
  # def initWithFrame frame
  #   super_initWithFrame frame
  #   tracking = NSTrackingArea.alloc.initWithRect_options_owner_userInfo [0, 0, frame[2], frame[3]],
  #                 NSTrackingMouseEnteredAndExited|NSTrackingInVisibleRect|NSTrackingActiveInKeyWindow, self, nil
  #   addTrackingArea tracking
  #   self
  # end
  attr_accessor :action2
  
  def mouseUp event
    p = convertPoint_fromView(event.locationInWindow, nil)
    if p.x < 30 and action2
      sendAction_to action2, target
    else
      sendAction_to action, target
    end
  end
  
  # def mouseEntered event
  #   setTextColor NSColor.redColor
  # end
  # 
  # def mouseExited event
  #   setTextColor NSColor.blackColor
  # end
end
