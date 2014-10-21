class NoPhone < Sinatra::Base
  post "/" do
    halt 404 unless params["To"].is_a?(String)

    if match = params["To"].match(/sip:(\+?\d+)@collectiveidea.sip.twilio.com/)
      builder do |xml|
        xml.Response do |r|
          r.Dial match[1]
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