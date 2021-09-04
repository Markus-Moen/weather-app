#require 'json'
require "sinatra"
require "slim"
require 'byebug'
require_relative "model.rb"

include Model

# Displays the landing page
#
get('/') do
    slim(:index, locals:{error:nil})
end

get('/error/:query') do
    data = query_decode(params["query"])
    slim(:index, locals:{error:data})
end

get('/results/:query') do
    data = query_decode(params["query"])
    slim(:results, locals:{vars:data})
end

get('/weather/:id') do
    data = api_call(params["id"])
    if data["error"] != nil
        data = query_encode(data)
        redirect("/error/#{data}")
    end
    slim(:weather, locals:{weather:data})
end

# Manages searches. Either sends to search results, to a selection page if there were many results, 
# or back to '/' if search was too unclear
#
# @param [string] City, The search entered by a user
#
# @see Model#city_search
post('/search') do
    max_search_results = 20
    search = params["City"]
    if not search.ascii_only?
        query = {"error" => "ascii"}
        redirect("/error/#{query_encode(query)}")
    end
    cities = city_search(search)
    len = cities.length
    if len == 1
        #search results directly
        # query = query_encode([cities])
        redirect("/weather/#{cities.keys[0]}")
    elsif 0 < len && len <= max_search_results
        #redirect to a selection of results
        query = query_encode(cities)
        redirect("/results/#{query}")
    else
        #return to search with error saying if it's too much or too little.
        query = {"max" => max_search_results}
        # query["max"] = max_search_results
        if len == 0
            query["error"] = "noResult"
        elsif len > max_search_results
            query["error"] = "overflow"
        end
        redirect("/error/#{query_encode(query)}")
    end
    redirect("/")
end