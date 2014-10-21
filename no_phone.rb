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
      if match = params["To"].match(/sip:(.+)@collectiveidea.sip.twilio.com/)
        builder do |xml|
          xml.Response do |r|
            r.Dial match[1], callerId: "+1-616-499-2122"
          end
        end
      elsif params["To"] == "+16164992122"
        message
      else
        hangup
      end
    else
      hangup
    end
  end

  post "/extension" do
    # validate

    case params["Digits"].to_i
    when 123
      builder do |xml|
        xml.Response do |r|
          r.Dial do |d|
            d.Sip "sip:701@phone.collectiveidea.com" #, username: ENV["PBX_USERNAME"], password: ENV["PBX_PASSWORD"]
          end
        end
      end
    else
      hangup
    end
  end

  def message
    builder do |xml|
      xml.Response do |r|
        r.Gather timeout: 10, action: "/extension" do |g|
          g.Say "Welcome to Collective Idea. If you know your party's extension, enter it followed by the pound sign. For more information, please email us at info@collectiveidea.com.", voice: "alice"
        end
        r.Hangup
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