xml.Gather timeout: 5, action: "/menu", numDigits: "1" do |g|
  g.Play sound_url("welcome")
end
xml.Hangup
