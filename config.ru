require "rubygems"
require "bundler"

Bundler.require

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

Honeybadger.configure do |config|
  config.before_notify do |notice|
    if notice.exception.class < Sinatra::NotFound
      notice.halt!
    end
  end
end

require "./no_phone"
configure { set :server, :puma }
run NoPhone
