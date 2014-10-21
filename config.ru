require 'rubygems'
require 'bundler'

Bundler.require

use Rack::SslEnforcer if ENV["RACK_ENV"] == "production"

require './no_phone'
configure { set :server, :puma }
run NoPhone