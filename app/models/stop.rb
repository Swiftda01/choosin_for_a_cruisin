class Stop < ApplicationRecord
  belongs_to :cruise
  belongs_to :port

  def self.seed_data
    Cruise.all.each_with_index do |cruise, i|
      sleep 2

      response = Typhoeus.get(
        "https://www.msccruisesusa.com/en-us/Plan-Book/Itinerary-detail-b2c.aspx?cruiseid=#{cruise.code}",
        headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36" }
      )
      
      parsed_body = Nokogiri::HTML(response.body)
      
      departure_datetime = nil
      arrival_datetime = nil
      departure_port = nil
      arrival_port = nil
      
      parsed_body.xpath('(//tr)')[1..-1].each do |row|
        cells = row.children.map(&:text).map(&:strip).reject { |x| x == '' }
        
        if departure_datetime.nil?
          departure_datetime = cells[1]
          departure_port = cells[2]
          next
        elsif arrival_datetime.nil?
          if cells[3] == '-'
            next
          else
            arrival_datetime = cells[1]
            arrival_port = cells[2]
          end
        end

        from_time, to_time = cells[3..4].map do |time|
          time.present? && time != '-' ? time : ''
        end

        d_from = (cells[1] + ' ' + from_time).strip
        d_to   = (cells[1] + ' ' + to_time).strip

        port_and_country_name = cells[2].strip
        port_name = port_and_country_name.split(',').first
        port = Port.find_by("name ILIKE '#{port_name}%'")
        port ||= Port.create(name: port_and_country_name)

        Stop.create(
          cruise_id: cruise.id,
          port_id: port.id,
          d_from: d_from,
          d_to: d_to
        )

        departure_datetime = nil
        arrival_datetime = nil
        departure_port = nil
        arrival_port = nil

        if cells[4] != '-'
          departure_datetime = cells[1]
          departure_port = cells[2]
        end
      end
    rescue => e
      puts "Failed to import cruise #{cruise.code}"
      puts "Error: #{e.message}"
      next
    end
  end
end
