class Stop < ApplicationRecord
  belongs_to :cruise
  belongs_to :port

  def self.generate_seed_data
    require 'csv'

    CSV.open("stops_data.csv", "wb") do |csv|
      csv << ["cruise_id", "port_id", "d_from", "d_to"]

      Cruise.all.each_with_index do |cruise, i|
        return unless i < 10
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
        from_time = nil
        to_time = nil

        rows = parsed_body.xpath('(//tr)')[1..-1]
        rows.each_with_index do |row, i|
          cells = row.children.map(&:text).map(&:strip).reject { |x| x == '' }

          current_date = cells[1]
          current_arrival_time = cells[3] != '-' ? cells[3] : nil
          current_departure_time = cells[4] != '-' ? cells[4] : nil

          current_port_and_country_name = cells[2].strip
          current_port_name = current_port_and_country_name.split(',').first
          current_port = Port.find_by("name ILIKE '#{current_port_name}%'")
          current_port ||= Port.create(name: current_port_and_country_name)

          next if current_arrival_time.nil? && current_departure_time.nil?

          if i.zero?
            csv << [
              cruise.id,
              current_port.id,
              current_date,
              current_date + ' ' + current_departure_time
            ]
            next
          end

          if i == rows.length - 1
            csv << [
              cruise.id,
              current_port.id,
              current_date + ' ' + current_arrival_time,
              current_date
            ]
            next
          end

          if current_arrival_time && current_departure_time
            csv << [
              cruise.id,
              current_port.id,
              current_date + ' ' + current_arrival_time,
              current_date + ' ' + current_departure_time
            ]
          elsif current_arrival_time
            @multi_day_arrival_date = current_date
            @multi_day_arrival_time = current_arrival_time
          else
            csv << [
              cruise.id,
              current_port.id,
              @multi_day_arrival_date + ' ' + @multi_day_arrival_time,
              current_date + ' ' + current_departure_time
            ]
          end
        end
      rescue => e
        puts "Failed to import cruise #{cruise.code}"
        puts "Error: #{e.message}"
        next
      end
    end
  end
end
