#require 'json'
require 'net/http'
require 'openssl'
#API-Key = 18af1bfdf08916a87f26da3dba389218
#API-call = api.openweathermap.org/data/2.5/forecast?id={city ID}&appid={API-Key}

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

    #
    def query_encode(hashes)
        output = ""
        hashes.each do |h|
            keys = h.keys
            keys.each do |k|
                output += "#{k}=#{h[k]}&"
            end
            output += "-"
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
        puts output.delete_suffix("-")
        return output.delete_suffix("-")
    end

    #
    def query_decode(str)
        output = []
        if str.include? "_"
            i = 0
            while i < str.length
                if str[i] == "_"
                    str[i] = " "
                end
                i += 1
            end
        end
        strings = str.split("-")
        strings.each do |s|
            hash = {}
            pairs = s.split("&")
            pairs.each do |ps|
                pair = ps.split("=")
                hash[pair[0]] = pair[1]
            end
            output << hash
        end
        return output
    end

    def api_call(cityId)
        # apiKey = "18af1bfdf08916a87f26da3dba389218"
        p cityId
        url = URI("https://community-open-weather-map.p.rapidapi.com/forecast?units=metric&id=#{cityId}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request["x-rapidapi-host"] = 'community-open-weather-map.p.rapidapi.com'
        request["x-rapidapi-key"] = '6c001e4c33msh4c6d40dd2443580p1d9665jsnc61acf4c2931'

        response = http.request(request)
        puts response.read_body
    end
end