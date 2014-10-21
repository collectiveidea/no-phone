require 'rubygems'
require 'bundler'

Bundler.require

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

Honeybadger.configure do |config|
  config.api_key = ENV["HONEYBADGER_API_KEY"]
  config.ignore << "Sinatra::NotFound"
end

use Honeybadger::Rack::ErrorNotifier

require './no_phone'
configure { set :server, :puma }
run NoPhone