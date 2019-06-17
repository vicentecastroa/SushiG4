class FtpOrdenesController < ApplicationController
  	def index
  		@ordenes = []
		time = Time.now
		counter = 0
		Net::SFTP.start(@@host, @@user, :password => @@password) do |sftp|
			entries = sftp.dir.entries("/pedidos")
			entries.each do |entry|
				file_name = entry.name.to_s
				if file_name.length >= 10
					time_file = DateTime.strptime(entry.attributes.mtime.to_s,'%s')
					if time_file > (time - 3.hours)
						data_xml = sftp.download!("pedidos/#{entry.name}")
	  					data_json = Hash.from_xml(data_xml).to_json
	  					data_json = JSON.parse data_json
	  					order_id = data_json["order"]['id']
	  					orden_compra = obtener_oc(order_id)
	  					@ordenes << orden_compra[0]
					end
				end
			end
		end
  	end
end
