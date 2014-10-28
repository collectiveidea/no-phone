require './emailer'

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
        welcome
      else
        hangup
      end
    else
      hangup
    end
  end

  post "/sms" do
    validate

    builder do |xml|
      xml.Response do |r|
        r.Message "Thanks for contacting [i] Collective Idea. Please visit http://collectiveidea.com"
      end
    end
  end

  post "/menu" do
    validate

    extension = params["Digits"].to_i
    case extension
    when 1
      # Harmony or DMS
      builder do |xml|
        xml.Response do |r|
          leave_a_message(r)
          r.Hangup
        end
      end
    when 2
      # All other
      builder do |xml|
        xml.Response do |r|
          r.Gather timeout: 10, numDigits: 3, action: "/extension" do |g|
            g.Play sound_url("extension")
          end
          leave_a_message(r)
          r.Hangup
        end
      end
    else
      hangup
    end
  end

  post "/extension" do
    validate

    extension = params["Digits"].to_i
    case extension
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

  post "/voicemail" do
    validate

    puts "YOU'VE GOT MAIL! #{params["RecordingUrl"]} #{params["RecordingDuration"]} seconds"
    Emailer.new.voicemail_notification(params["RecordingUrl"], params["RecordingDuration"])
    empty_response
  end

  private

  def leave_a_message(xml)
    xml.Play sound_url("unavailable")
    xml.Record maxLength: 300, action: "/voicemail"
    nil
  end

  def welcome
    builder do |xml|
      xml.Response do |r|
        r.Gather timeout: 5, action: "/menu", numDigits: "1" do |g|
          g.Play sound_url("welcome")
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

  def sound_url(sound)
    ENV["TWILIO_CALLBACK_URL"] + "/#{sound}.mp3"
  end

  def validate
    auth_token = ENV["TWILIO_AUTH_TOKEN"]
    # the callback URL you provided to Twilio
    url = ENV["TWILIO_CALLBACK_URL"] + request.fullpath
    # X-Twilio-Signature header value, rewritten by Rack
    signature = request.env["HTTP_X_TWILIO_SIGNATURE"]
    validator = Twilio::Util::RequestValidator.new(auth_token)
    halt 401 unless validator.validate(url, params, signature)
  end
end