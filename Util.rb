$levenshtein = Levenshtein.alloc.init

# def score a, b
#   200 - $levenshtein.distance_to(a, b)
# end

def score a, b
  case
  when a == b then 100
  else
    as = a.downcase
    bs = b.downcase
    case
    when as == bs then 99
    when bs.include?(as) then 98
    when as.include?(bs) then 97
    else
      am = as.gsub(/[- .,!\?\(\)]/, "")
      bm = bs.gsub(/[- .,!\?\(\)]/, "")
      case
      when am == bm then 96
      when bm.include?(am) then 95
      when am.include?(bm) then 94
      else
        0
      end
    end
  end
end

def unescape(str)
  str.gsub("&gt;", ">").gsub("&amp;", "&")
end

def escape(str)
  URI.escape(str, /[ &"\x7f-\xff]/)
end

def year_from(str)
  str =~ /[0-9]+/
  $&
end

def large_version(url)
  url.gsub(/www\./, "image.")
end

def image_from(url)
  image = NSImage.alloc.initByReferencingURL_(NSURL.URLWithString_(url))
  rep = image.representations[0]
  if rep
    image.setSize([rep.pixelsWide, rep.pixelsHigh])
  end
  image
end

def album_id_from(str)
  str.gsub(/.*a=([0-9]+)/, '\1')
end

def artist_list(nodes)
  if nodes
    unescape(nodes.map { |x| x.html}.join(", "))
  else
    nil
  end
end
