require 'hpricot'
require 'open-uri'

include OSX

class AppDelegate < NSObject
  attr_accessor :scrollView, :contentView, :window, :tableView
  attr_reader :track, :curView
  
  def applicationShouldTerminateAfterLastWindowClosed(sender)
    false
  end
  
  def applicationDidFinishLaunching(notification)
    setUpView
    setUpSearchOrder

    NSDistributedNotificationCenter.defaultCenter.addObserver_selector_name_object_(
          self, "iTunesNotification:", "com.apple.iTunes.playerInfo", nil)

    findInfo
  end
  
  def applicationDidBecomeActive(notification)
    window.orderFront(self)
  end
  
  def applicationDidResignActive(notification)
    window.orderOut(self)
  end

  def setUpView
    @listView = ListView.alloc.initWithFrame(@scrollView.contentView.frame)
    @scrollView.setDocumentView(@listView)

    s = @contentView.bounds.size
    @curView = AlbumView.alloc.initWithFrameActive([5, s.height - 155, AlbumViewWidth, 150], false)
    @curView.setAutoresizingMask NSViewMinYMargin
    @curView.album = "Nothing Playing"
    @contentView.addSubview(@curView)
  end
  
  def setUpSearchOrder
    def_values = { :searchOrder => [ { :method => 0, :enabled => 1, :label => "ManiaDB: artist + song" },
                                     { :method => 1, :enabled => 1, :label => "ManiaDB: artist" },
                                     { :method => 2, :enabled => 1, :label => "Amazon: song" },
                                     { :method => 3, :enabled => 1, :label => "Amazon: artist" },
                                     { :method => 4, :enabled => 1, :label => "Cover ZzlZzl: artist"} ] }
    NSUserDefaults.standardUserDefaults.registerDefaults(def_values)
    NSUserDefaultsController.sharedUserDefaultsController.setInitialValues(def_values)
  end
  
  def iTunesNotification(notification)
    if notification.userInfo.valueForKey("Player State") == "Playing"
      findInfo
    end
  end
  
  def findInfo
    iTunes = SBApplication.applicationWithBundleIdentifier("com.apple.iTunes")
    @track = iTunes.currentTrack
    begin
      artist = @track.artist
    rescue
      return
    end
    album = @track.album
    song = @track.name
    return if song == @song and artist == @artist

    @thread.terminate if @thread
    @album = album
    @song = song
    @artist = artist
    
    showCurrent(@artist, @album, @song, @track)
    @window.orderFront(self)

    @listView.removeAll
    @ids = {}
    @page = 1
    # @thread = NSThread.detachNewThreadSelector_toTarget_withObject("search:", self, nil)
    @thread = Thread.new do
      begin
        searches = NSUserDefaultsController.sharedUserDefaultsController.values.valueForKey(:searchOrder)
        searches.each do |search|
          enabled = search[:enabled]
          case search[:method]
          when 0
            searchManiaDB true, @artist, @album, @song if enabled
          when 1
            searchManiaDB false, @artist, @album, @song if enabled
          when 2
            searchAmazon true, @artist, @album, @song, @page if enabled
          when 3
            searchAmazon false, @artist, @album, @song, @page if enabled
          when 4
            searchCoverZzlZzl @artist, @album, @song if enabled
          end
        end
      rescue => ex
        puts ex.message, ex.backtrace
      end
    end
  end
  
  # def search(x)
  #   ap = NSAutoreleasePool.alloc.init
  #   begin
  #     searchManiaDB true, @artist, @album, @song
  #     searchManiaDB false, @artist, @album, @song
  #     searchAmazon true, @artist, @album, @song, @page
  #     searchAmazon false, @artist, @album, @song, @page
  #   rescue => ex
  #     puts ex.message, ex.backtrace
  #   end
  #   ap.release
  # end
  
  def moreResults sender, search_song
    if @page < @total_page
      @listView.removeButton sender
      @page += 1
      searchAmazon search_song, @artist, @album, @song, @page
    end
  end
  
  def moreSongResults sender
    moreResults sender, true
  end
  
  def moreArtistResults sender
    moreResults sender, false
  end

  def showCurrent artist, album, song, track
    @curView.artist = artist
    @curView.trackNumber = track.trackNumber
    @curView.song = song
    @curView.album = album
    @curView.year = track.year
    begin
      @curView.image = track.artworks.objectAtIndex(0).data
    rescue
      @curView.image = nil
    end
  end
  
  def uniqItems items, song_search
    result = []
    items.each do |item|
      album_id = song_search ? album_id_from((item/"maniadb:album/link").text) :
                               item.get_attribute("id")
      if !@ids[album_id]
        @ids[album_id] = true
        result << item
      end
    end
    result
  end

  def searchManiaDB song_search, artist, album, song
    artist_esc = escape(artist)
    song_esc = escape(song)
    url = "http://www.maniadb.com/api/search.asp?key=d232a03189c58cab2868&target=music&display=10" + (song_search ?
          "&itemtype=song&option=song&query=#{song_esc}&option2=artist&query2=#{artist_esc}" :
          "&itemtype=album&option2=artist&query2=#{artist_esc}")

    doc = Hpricot.XML(open(url))
    # puts doc

    items = uniqItems(doc/"item", song_search)

    @listView.addSection(song_search ? "Mania DB: #{artist} - #{song}" : "Mania DB: #{artist}", items.size)
    # if items.size == 0
    #   puts "---------ManiaDB---------"
    #   puts doc
    # end
    items.each do |item|
      albumView = @listView.add
      album_id = song_search ? album_id_from((item/"maniadb:album/link").text) :
                               item.get_attribute("id")
      albumView.image = image_from(large_version((item/"image").text))

      url = "http://www.maniadb.com/api/album.asp?key=d232a03189c58cab2868&a=#{album_id}"
      album_doc = Hpricot.XML(open(url))
      # puts album_doc
      albumView.artist = (album_doc/"maniadb:artist/name").text
      albumView.album = (album_doc/"maniadb:shorttitle").text
      albumView.year = year_from((album_doc/"item/releasedate").text)

      discs = album_doc.search("disc")
      discs.each do |disc|
        disc_number = discs.size > 1 ? disc.get_attribute("no").chomp(" ") : nil
        disc.search("song").each do |s|
          track_number = s.get_attribute("track")
          name = (s/"title").text
          albumView.addTrack(disc_number, track_number, name, score(song, name))
        end
      end
      albumView.setNeedsDisplay true
    end
  end

  def searchAmazon search_song, artist, album, song, page
    artist_esc = escape(artist)
    song_esc = escape(song)
    if search_song
      url = "http://ecs.amazonaws.com/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=1GWA5J4TFTE4RDMAAR82&Operation=ItemSearch&SearchIndex=Music&Keywords=#{song_esc}&Version=2008-08-19&ResponseGroup=Images,Tracks,Medium&ItemPage=#{page}"
    else
      url = "http://ecs.amazonaws.com/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=1GWA5J4TFTE4RDMAAR82&Operation=ItemSearch&SearchIndex=Music&Artist=#{artist_esc}&Version=2008-08-19&ResponseGroup=Images,Tracks,Medium&ItemPage=#{page}"
    end
    doc = Hpricot.XML(open(url))
    @total_page = (doc/"TotalPages").text.to_i
    items = doc/"Item"
    p = @total_page > 0 ? page : 0
    section = "Amazon: " + (search_song ? "#{song}" : "#{artist}") + "  (#{p}/#{@total_page})"
    @listView.addSection(section, items.size)
    # if items.size == 0
    #   puts "------Amazon-------"
    #   puts doc
    # end
    items.each do |item|
      albumView = @listView.add
      albumView.image = image_from((item/"LargeImage/URL").text)
      albumView.album = unescape((item/"Title").text)
      albumView.artist = artist_list(item/"Artist")
      albumView.year = year_from((item/"OriginalReleaseDate").text)
      discs = item/"Disc"
      discs.each do |disc|
        disc_number = discs.size > 1 ? disc.get_attribute("Number") : nil
        (disc/"Track").each do |s|
          track_number = s.get_attribute("Number")
          name = unescape(s.html)
          albumView.addTrack(disc_number, track_number, name, score(song, name))
        end
      end
      albumView.setNeedsDisplay true
    end
    if page < @total_page
      @listView.addButton(search_song ? "moreSongResults:" : "moreArtistResults:")
    end
  end
  
  def searchCoverZzlZzl artist, album, song
    artist_esc = escape(NSString.stringWithCString_encoding(artist, CFStringConvertEncodingToNSStringEncoding(0x0640)))
    url = "http://cover.zzlzzl.net/?search_str=#{artist_esc}&mode=search&Submit=Submit"
    doc = Hpricot.XML(open(url))
    trs = doc/"body/table/tr"
    trs.each do |tr|
      puts tr/"td", "-------------"
    end
  end
end
