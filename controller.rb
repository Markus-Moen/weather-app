#require 'json'
require "sinatra"
require "slim"
require 'byebug'
require_relative "model.rb"

include Model

# Displays the landing page
#
get('/') do
    slim(:index)
end

get('/error/:query') do
    data = params["query"].split('-')
    slim(:index, locals:{vars:data})
end

get('/results/:query') do
    data = query_decode(params["query"])
    slim(:results, locals:{vars:data})
end

get('/weather') do

    slim(:weather)
end

# Manages searches. Either sends to search results, to a selection page if there were many results, 
# or back to '/' if search was too unclear
#
# @param [string] City, The search entered by a user
#
# @see Model#city_search
post('/search') do
    max_search_results = 15
    search = params["City"]
    cities = city_search(search)
    len = cities.length
    if len == 1
        #search results directly
    elsif 0 < len && len <= max_search_results
        #redirect to a selection of results
        query = query_encode([cities])
        redirect("/results/#{query}")
    else
        #return to search with error saying if it's too much or too little.
        query = "#{max_search_results}-"
        if len == 0
            query += "noResult"
        elsif len > max_search_results
            query += "overflow"
        else
        end
        redirect("/error/#{query}")
    end
    redirect("/")
end