require 'json'
require 'net/http'
require 'openssl'

module Model
    # Searches for all cities matching a search word
    #
    # @param [String] search is the searchword entered to look for a city
    #
    # @return [Hash]
    #   * IDs [String] The IDs act as keys for their respective cities
    def city_search(search)
        if search == ""
            return {}
        end
        names = []
        ids = []
        prevLine = ""
        File.foreach("json/city.list.json") do |line|
            if line.downcase.force_encoding(::Encoding::UTF_8).include? search.downcase.force_encoding(::Encoding::UTF_8)
                names << line
                ids << prevLine
            end
            prevLine = line
        end
        return id_list(names, ids)
    end

    # Creates a dictionary of cities using their IDs as keys
    #
    # @param [Array] h1 is an array containing the lines displaying the city names in Openweathermaps list of city IDs
    # @param [Array] h2 is an array containing the lines displaying the city IDs in Openweathermaps list of city IDs
    #
    # @return [Hash]
    #   * IDs [String] The IDs act as keys for their respective cities
    def id_list(h1, h2)
        output = {}
        names = []
        ids = []
        h1.each do |line|
            arr = line.delete_suffix(",\n").split('"')
            names << arr[-1]
        end
        h2.each do |line|
            arr = line.delete_suffix(",\n").split(' ')
            ids << arr[-1].to_i
        end
        for i in 0..(names.length-1) do
            output[ids[i]] = names[i]
        end
        return output
    end

    # Returns true if all elements in an array only contains ASCII-characters
    #
    # @param [Array] arr is an array of strings that will be checked for characters
    #
    # @return [Bool] output is true if no non-ascii characters are found, and false otherwise
    def ascii_check(arr)
        output = true
        arr.each do |str|
            output = output && str.ascii_only?
        end
        return output
    end

    # Turns a hash into a string in a reversible format
    #
    # @param [Hash] hash is the hash to be converted into a string
    #
    # @return [String] output is the input hash converted into a string
    def query_encode(hash)
        output = ""
        keys = hash.keys
        keys.each do |k|
            output += "#{k}=#{hash[k]}&"
        end
        if output.include? " "
            i = 0
            while i < output.length
                if output[i] == " "
                    output[i] = "_"
                end
                i += 1
            end
        end
        return output
    end

    # Turns a string into a hash based on the format in query_encode
    #
    # @param [String] str is the string that will be converted into a hash
    #
    # @return [Hash] output is the input string converted into a hash
    def query_decode(str)
        if str.include? "_"
            i = 0
            while i < str.length
                if str[i] == "_"
                    str[i] = " "
                end
                i += 1
            end
        end
        hash = {}
        pairs = str.split("&")
        pairs.each do |ps|
            pair = ps.split("=")
            hash[pair[0]] = pair[1]
        end
        return hash
    end

    # Calls the Openweathermap API to ask for current weather
    #
    # @param [String] cityId cointains the ID for the city to be searched for, as listed in city.list.json
    #
    # @return [Hash] weather
    #   * "name" [String] the name of the chosen city
    #   * "main" [String] the current weather of the chosen city
    #   * "description" [String] a description of the chosen weather
    # @return [Hash] response
    #   * "cod" [String] the error code
    #   * "error" [String] the error message
    #   * "message" [String] the error message
    def api_call(cityId)
        url = URI("https://community-open-weather-map.p.rapidapi.com/weather?id=#{cityId}&lang=en&units=metric")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request["x-rapidapi-host"] = 'community-open-weather-map.p.rapidapi.com'
        request["x-rapidapi-key"] = '6c001e4c33msh4c6d40dd2443580p1d9665jsnc61acf4c2931'

        response = JSON.parse(http.request(request).read_body)
        if response["cod"] == 200
            weather = {}
            weather["name"] = response["name"]
            weather["main"] = response["weather"][0]["main"]
            weather["description"] = response["weather"][0]["description"]
            return weather
        else
            response["error"] = response["message"]
            return response
        end
    end
end