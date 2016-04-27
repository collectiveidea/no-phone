class Emailer
  def initialize
    @client = SendGrid::Client.new(api_key: ENV["SENDGRID_API_KEY"])
  end

  def voicemail_notification(url, duration)
    body = "A new voicemail has arrived!\n\nListen to it here: #{url}\n#{duration} seconds long."
    message = SendGrid::Mail.new(
      to: ENV["EMAIL_TO"],
      from: ENV["EMAIL_FROM"],
      subject: "New Voicemail",
      text: body,
      html: body.gsub(/\n/, '<br>')
    )
    response = @client.send(message)
    raise "#{response.code}: #{response.body}" if response.code != 200
  end
end
