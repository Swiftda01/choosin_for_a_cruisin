# Script to pull down Geolocation stuff
Port.all.each do |port|
  next unless port.lat.nil? || port.lng.nil?

  port_name = port.name
  # Magdalenefjord, Svalbard starts with "Cruising " for some reason
  port_name = port_name.gsub('Cruising ', '') if port_name.start_with?('Cruising ')
  # Kaloi Limenes for some reason is entered as "Kalilimenes"
  port_name = 'Kaloi Limenes, Greece' if port_name == 'Kalilimenes'
  data = Net::HTTP.get(URI("https://api.tomtom.com/search/2/geocode/#{CGI.escape(port_name)}.json?limit=3&key=#{ENV['TOMTOM_API_KEY']}"))
  position = JSON.parse(data)['results'].first['position']
  port.update(lat: position['lat'].to_f, lng: position['lon'].to_f)
end

# Show a list of all ports set up properly to be pasted into the seeds file
# Port.order(:code).map {|p| "  '#{p.code}' => [#{p.name.include?("'") ? "\"#{p.name}\"" : "'#{p.name}'"}, #{p.lat}, #{p.lng}],"}.join("\n")
