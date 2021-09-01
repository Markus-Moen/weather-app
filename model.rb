require 'json'

module Model
    def city_search()
        # cityFile = ""
        prevLine = ""
        names = []
        ids = []
        File.foreach("json/city.list.json") do |line|
            #cityFile += line
            if line.downcase.include? "gerton"
                names << line
                ids << prevLine
            end
            prevLine = line
        end
        puts id_list(names, ids)
    end
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
            ids << arr[-1]
        end
        for i in 0..(names.length-1) do
            output[ids[i]] = names[i]
        end
        return output
    end
end