#require 'json'
require "sinatra"
require "slim"
require 'byebug'
require_relative "model.rb"

include Model

# Displays the landing page
#
get('/') do
    city_search()
    slim(:home)
end