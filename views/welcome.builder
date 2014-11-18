xml.Response do |r|
  r.Gather timeout: 5, action: "/menu", numDigits: "1" do |g|
    g.Play sound_url("welcome")
  end
  r.Hangup
end
