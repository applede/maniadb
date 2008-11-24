include OSX

AlbumViewWidth = 5 + 150 + 5 + (180 + 5) * 4

class ListView < NSView
  
  def initWithFrame frame
    super_initWithFrame frame
    @y = 5
    @to_load = []
    self
  end
  
  def isFlipped
    true
  end

  def add
    view = AlbumView.alloc.initWithFrameActive [5, @y, AlbumViewWidth, 150], true
    view.setAutoresizingMask NSViewMaxYMargin
    addSubview view
    @y += 155
    @to_load << view
    view
  end
  
  def addSection label, count
    view = NSTextField.alloc.initWithFrame [0, @y, AlbumViewWidth, 20]
    view.setAutoresizingMask NSViewMaxYMargin
    cell = view.cell
    cell.setFont NSFont.fontWithName_size(cell.font.fontName, 16)
    view.setStringValue "  "+label
    view.setEditable false
    view.setBezeled false
    view.setBackgroundColor NSColor.grayColor
    view.setTextColor NSColor.whiteColor
    addSubview view
    @y += 25
    setFrameSize [AlbumViewWidth, @y + (5 + 150) * count + 5]
    view
  end
  
  def addButton(action)
    button = NSButton.alloc.initWithFrame [10, @y, 80, 30]
    button.setAutoresizingMask NSViewMaxYMargin
    button.setBezelStyle NSRoundedBezelStyle
    button.setTitle "More ..."
    button.setTarget NSApp.delegate
    button.setAction(action)
    addSubview button
    @y += 35
    setFrameSize [AlbumViewWidth, @y]
    button
  end
  
  def removeButton button
    button.removeFromSuperview
    @y -= 35
  end
  
  def removeAll
    views = subviews.dup
    views.each do |view|
      view.removeFromSuperview
    end
    @y = 5
    @to_load = []
  end
  
  def loadImages
    @to_load.each { |v| v.loadImage }
    @to_load = []
  end
end
