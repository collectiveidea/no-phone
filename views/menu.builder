xml.Gather timeout: 10, numDigits: 3, action: "/extension" do |g|
  g.Play sound_url("extension")
end
builder :leave_a_message, locals: {xml: xml}
xml.Hangup
