module EDDN
  class ConsolePresenter
    class << self
      # "                   "
      def log(msg)
        puts "-- SchemaRef:      | #{msg["$schemaRef"]}"
        puts "-- HEADER:         |"


        # msg["header"].each do |k,v|
        #   puts "                   | #{k}: #{v}"
        # end

        puts "-- MARKET INFO:    |"
        puts "                   | marketId: #{msg["message"]["marketId"]}"
        puts "                   | stationName: #{msg["message"]["stationName"]}"
        puts "                   | systemName: #{msg["message"]["systemName"]}"
        puts "                   | timestamp: #{msg["message"]["timestamp"]}"

        #commodities = msg.try(:[], "message").try(:[], "commodities")
        #self.parse_commodities(commodities) if commodities

        #separator = "-" * 100
        puts "-------------------||"
      end

      def parse_commodities(commodities)
        puts "-- COMMODITIES:    |"
        commodities.each do |commodity|
          name = commodity.delete("name")
          puts "                   | - #{name.upcase}"
          commodity.each do |k,v|
            puts "                   | -- #{k}: #{v}"
          end
          puts "                   | "
        end
      end
    end
  end
end
