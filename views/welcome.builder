if ENV.fetch("FORWARD_PHONE_TO", false)
  # Number must include area code and not have any other special characters.
  xml.Dial Integer(ENV["FORWARD_PHONE_TO"]).to_s
else
  xml.Gather timeout: 5, action: "/menu", numDigits: "1" do |g|
    g.Play sound_url("welcome")
  end
  xml.Hangup
end
