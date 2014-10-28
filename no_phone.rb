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

  post "/sms" do
    # validate

    builder do |xml|
      xml.Response do |r|
        r.Message "Thanks for contacting [i] Collective Idea. Please visit http://collectiveidea.com"
      end
    end
  end

  post "/extension" do
    # validate

    extension = params["Digits"].to_i
    case extension
    when 7
      builder do |xml|
        xml.Response do |r|
          r.Gather timeout: 10, action: "/extension" do |g|
            g.Say "Bienvenido a", voice: "alice", language: "es-ES"
            g.Say "Collective Idea.", voice: "alice", language: "en-US"
            g.Say "Si conoce la extensión de su partido, entrar en él seguido por el signo de número. Para obtener más información, por favor envíenos un email a info@collectiveidea.com.", voice: "alice", language: "es-ES"
          end
          r.Hangup
        end
      end
    when (1..1000)
      builder do |xml|
        xml.Response do |r|
          r.Dial do |d|
            d.Sip "sip:#{extension}@#{ENV["PBX_HOST"]}", username: ENV["PBX_USERNAME"], password: ENV["PBX_PASSWORD"]
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
          g.Say "Para español marque siete y la tecla numeral por favor.", voice: "alice", language: "es-ES"
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