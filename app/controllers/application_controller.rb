class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	@@api_key = "o5bQnMbk@:BxrE"

	#IDs Producción
	@@id_recepcion = "5cc7b139a823b10004d8e6df"
	@@id_despacho = "5cc7b139a823b10004d8e6e0"
	@@id_pulmon = "5cc7b139a823b10004d8e6e3"
	@@id_cocina = "5cc7b139a823b10004d8e6e4"
	@@url = "https://integracion-2019-prod.herokuapp.com/bodega"

	#IDs Desarrollo
	#@@id_recepcion = "5cbd3ce444f67600049431c5"
	#@@id_despacho = "5cbd3ce444f67600049431c6"
	#@@id_pulmon = "5cbd3ce444f67600049431c9"
	#@@id_cocina = "5cbd3ce444f67600049431ca"
	#@@url = "https://integracion-2019-dev.herokuapp.com/bodega"

	@@print_valores = false

	# Capacidades Bodegas
	@@tamaño_cocina = 1122
	@@tamaño_recepcion = 133
	@@tamaño_despacho = 80
	@@tamaño_pulmon = 99999999

	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
  end

  # Funcionando bien
  def get_almacenes(api_key)
		data = "GET"
		hash_value = hashing(data, api_key)
		almacenes = HTTParty.get("#{@@url}/almacenes", 
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nALMACENES\n"
			puts JSON.pretty_generate(almacenes)
		end
		return almacenes
	end

	# Funcionando bien
	def get_products_from_almacenes(api_key, almacenId, sku)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data, api_key)
		products = HTTParty.get("#{@@url}/stock?almacenId=#{almacenId}&sku=#{sku}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nPRODUCTOS DE ALMACENES\n"
			puts JSON.pretty_generate(products)
		end
		return products
	end

	# Funcionando bien
	def get_products_from_almacenes_limit_primeros(api_key, almacenId, sku, limit)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data, api_key)
		products = HTTParty.get("#{@@url}/stock?almacenId=#{almacenId}&sku=#{sku}&limit=#{limit}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nPRODUCTOS DE ALMACENES\n"
			puts JSON.pretty_generate(products)
		end
		return products
	end

	# Funcionando bien
	# Probado con la bodega del G14 5cbd3ce444f6760004943201
  	def mover_producto_entre_bodegas(api_key, productoId, almacenId, oc, precio)
		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data, api_key)
		producto_movido = HTTParty.post("#{@@url}/moveStockBodega",
		  body:{
		  	"productoId": productoId,
		  	"almacenId": almacenId,
		  	"oc": oc,
		  	"precio": precio,
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
			puts JSON.pretty_generate(producto_movido)
		end
		return producto_movido
	end

	# Funcionando bien
	def mover_producto_entre_almacenes(producto_json, id_destino)
		#productoId = producto_json["_id"]
		productoId = producto_json
		almacenId = id_destino

		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data, @@api_key)
		req = HTTParty.post("#{@@url}/moveStock",
		  body:{
				"productoId": productoId,
				"almacenId": almacenId,

		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })

		if @@print_valores
			puts "\nMOVER PRODUCTO ENTRE ALMACENES\n"
			puts JSON.pretty_generate(req)
		end
		return req
	end

	# Funcionando bien
	def obtener_skus_con_stock(api_key, almacenId)
		data = "GET#{almacenId}"
		hash_value = hashing(data, api_key)
		skus = HTTParty.get("#{@@url}/skusWithStock?almacenId=#{almacenId}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nSKUS\n"
			puts JSON.pretty_generate(skus)
		end
		return skus
	end

	# Funcionando bien
	def fabricar_sin_pago(api_key, sku, cantidad)
		data = "PUT#{sku}#{cantidad}"
		hash_value = hashing(data, api_key)
		products_produced = HTTParty.put("#{@@url}/fabrica/fabricarSinPago",
		  body:{
		  	"sku": sku,
		  	"cantidad": cantidad
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nFABRICAR SIN PAGO\n"
			puts JSON.pretty_generate(products_produced)
		end
		return products_produced
	end

	def fabricar_todo(api_key, lista_productos)
		almacenes = (get_almacenes(api_key)).to_a
		puts "..................."
		for almacen in almacenes do
			almacenId = almacen["_id"]
			for producto in lista_productos
				get_products_from_almacenes(api_key, almacenId, producto)
			end
		end
		puts "..................."
	end

	## NEW ##

	def checkear_recepcion(api_key)
		
		puts "Comienzo función checkear_recepcion\n"

		# Obtenemos espacio en Cocina
		almacenes = (get_almacenes(api_key)).to_a
		for almacen in almacenes do
			if almacen["cocina"] == true
				puts "Almacen usedSpace: " + almacen["usedSpace"].to_s
				if almacen["usedSpace"] <= almacen["totalSpace"]
					@espacio_disponible = almacen["totalSpace"] - almacen["usedSpace"]
					puts "Espacio disponible en cocina: " + @espacio_disponible.to_s + "\n"

					puts "Vaciando Pulmón"

					# Obtenemos los skus en Pulmon
					skus_pulmon = obtener_skus_con_stock(api_key, @@id_pulmon)

					# Para cada sku, obtenemos productos
					for sku_pulmon in skus_pulmon
						puts "SKU en Pulmón: " + sku_pulmon["_id"]
						sku_pulmon_num = sku_pulmon["_id"]

						# Obtenemos los productos asociados a ese sku
						productos_sku_pulmon_num = get_products_from_almacenes(api_key, @@id_pulmon, sku_pulmon_num)

						# Movemos cada producto de Pulmon a Cocina hasta que:
						# 1. No haya mas productos de ese sku
						# 2. Se llene la cocina
						for prod in productos_sku_pulmon_num
							if @espacio_disponible == 0
								puts "Cocina Llena\n"
								return
							end			
							mover_producto_entre_almacenes(prod["_id"], @@id_cocina)
							puts "Producto movido de Pulmón a Cocina"

							# Disminuyo en 1 el espacio disponible
							@espacio_disponible -= 1
						end
					end

					puts "Pulmón Vaciado"

					puts "Vaciando Recepción"

					# Obtenemos los skus en Recepción
					skus_recepcion = obtener_skus_con_stock(api_key, @@id_recepcion)

					# Para cada sku, obtenemos productos
					for sku_recepcion in skus_recepcion
						puts "SKU en Recepcion: " + sku_recepcion["_id"]
						sku_recepcion_num = sku_recepcion["_id"]

						# Obtenemos los productos asociados a ese sku
						productos_sku_recepcion_num = get_products_from_almacenes(api_key, @@id_recepcion, sku_recepcion_num)

						# Movemos cada producto de Pulmon a Cocina hasta que:
						# 1. No haya mas productos de ese sku
						# 2. Se llene la cocina
						for prod in productos_sku_recepcion_num
							if @espacio_disponible == 0
								puts "Cocina Llena\n"
								return
							end
							
							mover_producto_entre_almacenes(prod["_id"], @@id_cocina)
							puts "Producto movido de Recepción a Cocina"

							# Disminuyo en 1 el espacio disponible
							@espacio_disponible -= 1
						end
					end

					puts "Recepción Vaciada"

				end
			end
		end		
	end

  protect_from_forgery with: :exception
  @@api_key = "o5bQnMbk@:BxrE"


end

