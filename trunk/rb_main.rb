#
#  rb_main.rb
#  ManiaDB
#
#  Created by Appledelhi on 11/16/08.
#  Copyright (c) 2008 Appledelhi. All rights reserved.
#

require 'osx/cocoa'

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  $: << path + "/hpricot"
  $: << path + "/hpricot/universal-java1.6"

  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
