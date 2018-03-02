xml.Dial do |d|
  d.Number ENV["EXTENSION_#{@digits}"]
end
