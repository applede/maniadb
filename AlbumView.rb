#
#  album_view.rb
#  ManiaDB
#
#  Created by Appledelhi on 11/16/08.
#  Copyright (c) 2008 Appledelhi. All rights reserved.
#

include OSX

class AlbumView < NSView
  attr_reader :tracks
  attr_writer :imageURL
  
  def initWithFrameActive frame, active
    initWithFrame frame
    setAutoresizingMask NSViewWidthSizable

    @delegate = NSApp.delegate

    button_size = frame[3] - 10
    if active
      @image = NSButton.alloc.initWithFrame [5, 10, button_size, button_size]
      @image.setBezelStyle NSRegularSquareBezelStyle
      @image.setTitle ""
      @image.setTarget self
      @image.setAction "imageClicked:"
    else
      @image = NSImageView.alloc.initWithFrame [5, 10, button_size, button_size]
      @image.setImageFrameStyle NSImageFrameGroove
    end
    @image.cell.setImageScaling NSImageScaleProportionallyUpOrDown
    addSubview @image
    
    @imageSize = addLabel 5, -10, button_size, NSMiniControlSize, nil
    @imageSize.setAlignment NSCenterTextAlignment
    
    x = 5 + button_size + 5
    y = 5 + button_size - 11
    w = frame[2] - x - 5 - 45
    @album = addLabel x, y, w, NSRegularControlSize, "albumClicked:"
    @all = addButton("All", x + w + 5, y + 2, 40, NSMiniControlSize, "allClicked:") if active
    
    y -= 22
    @artist = addLabel x, y, 295, NSSmallControlSize, "artistClicked:"
    @year = addLabel x + 300, y, 50, NSSmallControlSize, "yearClicked:"
    
    @tracks = []
    y -= 16
    for i in 0..3 do
      makeColumn x + (180 + 5) * i, y, 9 * i
    end
    @index = 0
    @score = 0
    
    return self
  end
  
  def image= image
    @image.setImage image
    if image and image.size.width > 0
      @imageSize.setStringValue "#{image.size.width.to_i}x#{image.size.height.to_i}"
    else
      @imageSize.setStringValue ""
    end
    @image.setNeedsDisplay(true)
  end
  
  def album= title
    @album.setStringValue title
    @album.sizeToFit
    frame = @album.frame
    @all.setFrameOrigin([frame.origin.x + frame.size.width + 10, frame.origin.y - 3]) if @all
  end
  
  def artist= artist
    @artist.setStringValue artist
  end
  
  def year= year
    @year.setStringValue year == 0 ? "" : year.to_s
  end
  
  def addTrack disc, track, title, score
    str = disc ? "#{disc}-#{track}. #{title}" : "#{track}. #{title}"
    if @tracks[@index]
      @tracks[@index].setStringValue str
      @tracks[@index].setToolTip(str)
      if score > @score
        @tracks[@score_index].setTextColor NSColor.whiteColor if @score_index
        @tracks[@index].setTextColor NSColor.greenColor
        # @tracks[@index].setStringValue("#{str} (#{score})")
        @track_number = track.to_i
        @song = title
        @score = score
        @score_index = @index
      end
      @index += 1
    end
  end

  def trackNumber= t
    @track_number = t
    if @track_number > 0
      if @song
        @tracks[0].setStringValue("#{@track_number}. #{@song}")
      else
        @tracks[0].setStringValue("#{@track_number}. ")
      end
    elsif @song
      @tracks[0].setStringValue(@song)
    end
  end
  
  def song= song
    @song = song
    @tracks[0].setStringValue @track_number > 0 ? "#{@track_number}. #{@song}" : @song
  end
  
  def addLabel x, y, w, size, action, action2=nil
    label = MyTextField.alloc.initWithFrame [x, y, w, 20]
    label.setAutoresizingMask NSViewWidthSizable
    label.setStringValue ""
    label.setEditable false
    label.setBezeled false
    label.setDrawsBackground false
    label.setTextColor(NSColor.whiteColor)
    label.setTarget self
    label.setAction action
    label.action2 = action2
    fontSize = NSFont.systemFontSizeForControlSize size
    cell = label.cell
    font = NSFont.fontWithName_size(cell.font.fontName, fontSize)
    cell.setFont font
    cell.setControlSize size
    cell.setLineBreakMode NSLineBreakByTruncatingTail
    addSubview label
    label
  end
  
  def addButton label, x, y, w, size, action
    button = NSButton.alloc.initWithFrame([x, y, w, 20])
    button.setBezelStyle(NSRoundRectBezelStyle)
    button.setAutoresizingMask(NSViewMaxXMargin)
    button.setTitle(label)
    button.setTarget(self)
    button.setAction(action)
    fontSize = NSFont.systemFontSizeForControlSize(size)
    cell = button.cell
    font = NSFont.fontWithName_size(cell.font.fontName, fontSize)
    cell.setFont(font)
    cell.setControlSize(size)
    cell.setLineBreakMode(NSLineBreakByTruncatingTail)
    addSubview button
    button
  end
  
  def makeColumn(x, y, start)
    for i in 0..8 do
      @tracks[start + i] = addLabel x, y, 180, NSMiniControlSize, "songClicked:", "trackClicked:"
      y -= 13
    end
  end

  def setTrackImage image
    begin
      @delegate.track.artworks.objectAtIndex(0).data = image
      @delegate.curView.image = image
    rescue
    end
  end
  
  def setTrackAlbum str
    begin
      @delegate.track.album = str
      @delegate.curView.album = str
    rescue
    end
  end
  
  def setTrackArtist str
    begin
      @delegate.track.artist = str
      @delegate.curView.artist = str
    rescue
    end
  end
  
  def setTrackYear str
    begin
      @delegate.track.year = str
      @delegate.curView.year = str
    rescue
    end
  end
  
  def setTrackNumber disc, number
    begin
      @delegate.track.discNumber = disc
      @delegate.track.trackNumber = number
      @delegate.track.trackCount = nil
      @delegate.curView.trackNumber = number
    rescue
    end
  end
  
  def setTrackName name
    begin
      @delegate.track.name = name
      @delegate.curView.song = name
    rescue
    end
  end
  
  def allClicked(sender)
    imageClicked(sender)
    albumClicked(sender)
    artistClicked(sender)
    yearClicked(sender)
    songClicked(@tracks[@score_index]) if @score_index
  end

  def imageClicked(sender)
    setTrackImage @image.image if @image.image
  end
  
  def albumClicked(sender)
    setTrackAlbum @album.stringValue if @album.stringValue != ""
  end
  
  def artistClicked(sender)
    setTrackArtist @artist.stringValue if @artist.stringValue != ""
  end
  
  def yearClicked(sender)
    setTrackYear @year.stringValue if @year.stringValue != ""
  end
  
  def trackClicked(sender)
    str = sender.stringValue
    if str.to_s =~ /(([^-]+)-)?([0-9]+)\. (.*)/
      setTrackNumber discFrom($2), $3.to_i
    end
  end
  
  def songClicked(sender)
    str = sender.stringValue
    if str.to_s =~ /(([^-]+)-)?([0-9]+)\. (.*)/
      setTrackNumber discFrom($2), $3.to_i
      setTrackName cleanUpTrackName($4)
    end
  end
  
  def loadImage
    self.image = image_from(@imageURL)
  end

  def cleanUpTrackName(name)
    artist = @artist.stringValue
    if name =~ /(.*) - (.*)/
      if $2.include?(artist)
        $1
      else
        $&
      end
    else
      name
    end
  end
end

def discFrom str
  if str
    if str >= '0' and str <= '9'
      str.to_i
    else
      " abcdefg".index str.downcase
    end
  else
    nil
  end
end
