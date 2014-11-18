xml.Dial do |d|
  d.Sip "sip:#{@digits}@#{ENV["PBX_HOST"]}" #, username: ENV["PBX_USERNAME"], password: ENV["PBX_PASSWORD"]
end
