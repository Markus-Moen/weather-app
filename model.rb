require 'json'

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
end