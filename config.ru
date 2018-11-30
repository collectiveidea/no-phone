require "rubygems"
require "bundler"

Bundler.require

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

Honeybadger.exception_filter do |notice|
  notice[:exception].class < Sinatra::NotFound
end

require "./no_phone"
configure { set :server, :puma }
run NoPhone
