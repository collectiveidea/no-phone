ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'

Bundler.require

require './no_phone'
require 'test/unit'
require 'rack/test'

ENV["TWILIO_AUTH_TOKEN"] = "test-token"
ENV["TWILIO_CALLBACK_URL"] = ""

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    NoPhone
  end

  # Build the proper signature from the url & params
  def params_and_signature(url, params)
    validator = Twilio::Security::RequestValidator.new(ENV["TWILIO_AUTH_TOKEN"])
    signature = validator.build_signature_for(url, params)
    [url, params, "HTTP_X_TWILIO_SIGNATURE" => signature]
  end

  def test_homepage
    get '/'
    assert last_response.ok?
  end

  def test_phone_call
    post *params_and_signature("/", To: "+15555555555", CallStatus: "ringing")
    assert last_response.ok?
    assert_match "<Play>/welcome.mp3</Play>", last_response.body
  end

  def test_menu
    post *params_and_signature('/menu', To: "+15555555555", Digits: "1")
    assert last_response.ok?
    assert_match "<Play>/unavailable.mp3</Play>", last_response.body
  end

  def test_extensions
    ENV["EXTENSION_4"] = "123-4567"
    post *params_and_signature('/menu', To: "+15555555555", Digits: "4")
    assert last_response.ok?
    assert_match "<Number>123-4567</Number>", last_response.body
  end

end