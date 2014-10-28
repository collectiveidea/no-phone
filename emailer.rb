class Emailer
  def initialize
    @mandrill = Mandrill::API.new(ENV["MANDRILL_API_KEY"])
  end

  def voicemail_notification(url, duration)
    message = {
      "html" => "A new voicemail has arrived!\n\nListen to it here: #{url}\n#{duration} seconds long.",
      "subject" => "New Voicemail",
      "from_email" => ENV["EMAIL_FROM"],
      "from_name" => "No Phone",
      "to" => [{"email" => ENV["EMAIL_TO"],
        "name" => "Collective Idea",
        "type" => "to"}],
      "auto_html" => true,
    }
    @mandrill.messages.send(message)
  end
end
