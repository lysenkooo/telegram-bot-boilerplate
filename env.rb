$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'yaml'
require 'active_record'
require 'telegram/bot'
require 'lib/conversation'
require 'lib/bot'

Dir['models/*.rb'].each do |file|
  require file
end

db_config = YAML::load(File.open('database.yml'))

ActiveRecord::Base.establish_connection(db_config)
