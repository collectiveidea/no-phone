class NoPhone < Sinatra::Base
  post "/" do
    halt 404 unless params["To"].is_a?(String)

    if params["CallStatus"] == "ringing" && match = params["To"].match(/sip:(\+?\d+)@#{Regexp.escape(ENV["TWILIO_SIP_ENDPOINT"])}/)
      builder do |xml|
        xml.Response do |r|
          r.Dial match[1], callerId: ENV["TWILIO_NUMBER"]
        end
      end
    else
      hangup
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