class NoPhone < Sinatra::Base
  get "/" do
    erb :index
  end

  post "/" do
    validate
    halt 404 unless params["To"].is_a?(String)

    case params["CallStatus"]
    when "completed"
      empty_response
    when "ringing"
      if match = params["To"].match(/sip:(.+)@#{Regexp.escape(ENV["TWILIO_SIP_ENDPOINT"])}/)
        builder do |xml|
          xml.Response do |r|
            r.Dial match[1], callerId: ENV["TWILIO_NUMBER"]
          end
        end
      elsif params["To"] == ENV["TWILIO_NUMBER"]
        message
      else
        hangup
      end
    else
      hangup
    end
  end

  def message
    builder do |xml|
      xml.Response do |r|
        r.Say "Welcome to Collective Idea. For more information, please email us at info@collectiveidea.com", voice: "alice"
      end
    end
  end

  def hangup
    builder do |xml|
      xml.Response do |r|
        r.Hangup
      end
    end
  end

  def empty_response
    builder do |xml|
      xml.Response
    end
  end

  private

  def validate
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    # the callback URL you provided to Twilio
    url = ENV["TWILIO_CALLBACK_URL"]
    # X-Twilio-Signature header value, rewritten by Rack
    signature = request.env["HTTP_X_TWILIO_SIGNATURE"]
    validator = Twilio::Util::RequestValidator.new(auth_token)
    halt 401 unless validator.validate(url, params, signature)
  end
end