class NoPhone < Sinatra::Base
  post "/" do
    halt 404 unless params["To"].is_a?(String)

    if params["CallStatus"] == "ringing" && match = params["To"].match(/sip:(\+?\d+)@collectiveidea.sip.twilio.com/)
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
end