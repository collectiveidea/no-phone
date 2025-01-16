if ENV["FORWARD_PHONE_TO"].present?
  # Number must include area code and not have any other special characters.
  xml.Dial ENV["FORWARD_PHONE_TO"]
else
  xml.Gather timeout: 5, action: "/menu", numDigits: "1" do |g|
    g.Play sound_url("welcome")
  end
  xml.Hangup
end
