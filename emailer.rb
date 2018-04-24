class Emailer
  def initialize
    @sendgrid = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
  end

  def voicemail_notification(url, duration, phone_number)
    body = "A new voicemail has arrived from #{phone_number}!\n\nListen to it here: #{url}\n#{duration} seconds long."
    message = SendGrid::Mail.new
    message.from = SendGrid::Email.new(email: ENV["EMAIL_FROM"])
    message.subject = "New Voicemail from #{phone_number}"
    personalization = SendGrid::Personalization.new
    personalization.add_to(SendGrid::Email.new(email: ENV["EMAIL_TO"]))
    message.add_personalization(personalization)

    message.add_content(SendGrid::Content.new(type: 'text/plain', value: body))
    message.add_content(SendGrid::Content.new(type: 'text/html', value: body.gsub(/\n/, '<br>')))

    response = @sendgrid.client.mail._('send').post(request_body: message.to_json)
    raise "#{response.status_code}: #{response.body}" if response.status_code != "202"
  end
end
