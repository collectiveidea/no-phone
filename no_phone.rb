require_relative "emailer"
require "twilio-ruby"

class NoPhone < Sinatra::Base
  helpers do
    def sound_url(sound)
      ENV["TWILIO_CALLBACK_URL"].to_s + "/#{sound}.mp3"
    end
  end

  before do
    validate unless request.env["REQUEST_METHOD"] == "GET"
    @digits = params["Digits"].to_i if params["Digits"]
  end

  get "/" do
    erb :index
  end

  # Incoming Call
  post "/" do
    halt 404 unless params["To"].is_a?(String)

    case params["CallStatus"]
    when "completed"
      builder :empty_response
    when "ringing"
      builder :welcome
    else
      builder :hangup
    end
  end

  # Incoming SMS
  post "/sms" do
    content_type "text/xml"

    Emailer.new.tap do |email|
      email.sms_notification(params["From"], params["Body"])
    end

    Twilio::TwiML::MessagingResponse.new.to_s
  end

  # Caller selected a menu item
  post "/menu" do
    case @digits
    when 1
      # Harmony or DMS
      builder :leave_a_message
    when 2
      # All other
      builder :menu
    else
      if ENV["EXTENSION_#{@digits}"]
        builder :extension
      else
        builder :hangup
      end
    end
  end

  post "/extension" do
    if ENV["EXTENSION_#{@digits}"]
      builder :extension
    else
      builder :hangup
    end
  end

  post "/voicemail" do
    puts "YOU'VE GOT MAIL! #{params["RecordingUrl"]} #{params["RecordingDuration"]} seconds"
    Emailer.new.voicemail_notification(params["RecordingUrl"], params["RecordingDuration"], params["From"])
    builder :empty_response
  end

  private

  def validate
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    # the callback URL you provided to Twilio
    url = ENV["TWILIO_CALLBACK_URL"] + request.fullpath
    # X-Twilio-Signature header value, rewritten by Rack
    signature = request.env["HTTP_X_TWILIO_SIGNATURE"]
    validator = Twilio::Security::RequestValidator.new(auth_token)
    # "captures" key gets added to the params. we need to remove it for validation
    twilio_params = params.clone
    twilio_params.delete("captures")
    halt 401 unless validator.validate(url, twilio_params, signature)
  end
end
