require 'variables_helper'

module ApplicationHelper	
	include VariablesHelper

	def hashing(data)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), @@api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
	end

  	def get_almacenes
		data = "GET"
		hash_value = hashing(data, @@api_key)
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

	def get_products_from_almacenes(almacenId, sku)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data)
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

	def get_products_from_almacenes_limit_primeros(almacenId, sku, limit)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data)
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

  	def mover_producto_entre_bodegas(productoId, almacenId, oc, precio)
		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data)
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

	def mover_producto_entre_almacenes(producto_json, id_destino)
		#productoId = producto_json["_id"]
		productoId = producto_json
		almacenId = id_destino

		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data)
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

	def obtener_skus_con_stock(almacenId)
		data = "GET#{almacenId}"
		hash_value = hashing(data)
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

	def fabricar_sin_pago(sku, cantidad)
		data = "PUT#{sku}#{cantidad}"
		hash_value = hashing(data)
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

	def fabricar_todo(lista_productos)
		almacenes = (get_almacenes.to_a
		puts "..................."
		for almacen in almacenes do
			almacenId = almacen["_id"]
			for producto in lista_productos
				get_products_from_almacenes(almacenId, producto)
			end
		end
		puts "..................."
	end

	def StockAvailableToSellAll
		response = []
		skus_quantity = {}
		sku_name = {}
		lista_skus = getSkuOnStock
		productos_all = Producto.all
		for sku in lista_skus
			product_sku = sku["sku"]
			product_name = sku["nombre"]
			quantity = sku["cantidad"]
			if skus_quantity.key?(product_sku)
				skus_quantity[product_sku] += quantity
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		for prod in productos_all
			product_sku = prod.sku
			product_name = prod.nombre

			if skus_quantity.key?(product_sku)
				if prod.stock_minimo
					if skus_quantity[product_sku] > prod.stock_minimo
						skus_quantity[product_sku] = skus_quantity[product_sku] - prod.stock_minimo
					else
						skus_quantity[product_sku] = 0
					end
				end	
			end
		end
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "total" => skus_quantity[key]}
			response << line
		end

		return response.to_json
	end

	def nombre_almacen(id_almacen)
		if id_almacen == @@id_despacho
			return "Despacho"
		elsif id_almacen == @@id_pulmon
			return "Pulmon"
		elsif id_almacen == @@id_recepcion
			return "Recepcion"
		elsif id_almacen == @@id_cocina
			return "Cocina"
		else
			return "Destino"
		end
		return "Destino"
	end

	def mover_a_almacen(almacen_id_origen, almacen_id_destino, skus_a_mover, cantidad_a_mover)

		# puts "Vaciando Almacen " + almacen_id_origen.to_s + "a Almacen " + almacen_id_destino.to_s + "\n"
		cantidad = cantidad_a_mover

		# Obtenemos el espacio disponible en destino
		almacenes = (get_almacenes).to_a
		origen_inicial = nombre_almacen(almacen_id_origen)
		destino_final = nombre_almacen(almacen_id_destino)
		
		for almacen in almacenes do
			if almacen["_id"] == almacen_id_destino
				# puts "Almacen de destino usedSpace: " + almacen["usedSpace"].to_s + "\n"
				if almacen["usedSpace"] <= almacen["totalSpace"]
					espacio_disponible = almacen["totalSpace"] - almacen["usedSpace"]
					#puts "Espacio disponible en #{destino_final}: " + espacio_disponible.to_s + "\n"

					# Obtenemos los skus en el almacen de origen
					skus_origen = obtener_skus_con_stock(almacen_id_origen)

					# Para cada sku, obtenemos productos
					for sku_origen in skus_origen
						#puts "SKU en Origen: " + sku_origen["_id"]
						sku_origen_num = sku_origen["_id"]
						
						# Verificamos que el sku se encuentre en la lista de skus a mover
						if skus_a_mover.include? sku_origen_num
							# Obtenemos los productos asociados a ese sku
							productos_origen = get_products_from_almacenes(almacen_id_origen, sku_origen_num)
							#puts "Productos_origen: " + productos_origen.to_s + "\n"

							# Movemos cada producto de Origen a Destino
							for producto_origen in productos_origen
								if espacio_disponible <= 0
									puts "Destino lleno\n"
									return cantidad_a_mover - cantidad
								end
								#puts "Voy a mover el producto\n"
								mover_producto_entre_almacenes(producto_origen["_id"], almacen_id_destino)
								#puts "Producto movido de #{origen_inicial} a #{destino_final}\n"


								# Disminuyo en 1 el espacio disponible
								espacio_disponible -=1

								# Si cantidad a mover es 0, se interpreta como mover todo los productos
								if cantidad != 0
									cantidad -= 1
									# puts "Productos a mover restantes: " + cantidad.to_s + "\n"
									if cantidad == 0
										return cantidad_a_mover - cantidad
									end
								end
							end

							cantidad_movida = cantidad_a_mover - cantidad
							return cantidad_movida

						end						
					end
					return 0
				end
			end
		end
	end
	
	def mover_a_almacen_cocinar(almacen_id_origen, almacen_id_destino, skus_a_mover, cantidad_a_mover)
		cantidad = cantidad_a_mover
		almacenes = (get_almacenes).to_a
		for almacen in almacenes do
			if almacen["_id"] == almacen_id_destino
				if almacen["usedSpace"] <= almacen["totalSpace"]
					espacio_disponible = almacen["totalSpace"] - almacen["usedSpace"]
					skus_origen = obtener_skus_con_stock(almacen_id_origen)
					for sku_origen in skus_origen
						sku_origen_num = sku_origen["_id"]
						if skus_a_mover.include? sku_origen_num
							productos_origen = get_products_from_almacenes(almacen_id_origen, sku_origen_num)
							for producto_origen in productos_origen
								if espacio_disponible <= 0
									return cantidad_a_mover - cantidad
								end
								mover_producto_entre_almacenes(producto_origen["_id"], almacen_id_destino)
								espacio_disponible -=1
								if cantidad != 0
									cantidad -= 1
									if cantidad == 0
										return cantidad_a_mover - cantidad
									end
								end
							end
							cantidad_movida = cantidad_a_mover - cantidad
							return cantidad_movida
						end						
					end
				end
			end
		end
		return 0
	end

	def despachar_producto(productoId, oc, direccion, precio)
		data = "DELETE#{productoId}#{direccion}#{precio}#{oc}"
		hash_value = hashing(data)
		producto_despachado = HTTParty.delete("#{@@url}/stock",
		  body:{
		  	"productoId": productoId,
				"oc": oc,
				"direccion": direccion,
		  	"precio": precio
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
			puts JSON.pretty_generate(producto_movido)
		end
		return producto_despachado
	end

	def despacho_todos(id_bodega, sku, cantidad, order_id)
		lista_id_productos = get_products_from_almacenes(id_bodega, sku)
		contador = 0
		for item in lista_id_productos
			productoId = item["_id"]
			despachado = despachar_producto(productoId, order_id, "frescos", 1)
			contador += 1
			break if contador == cantidad
		end
	end

	def StockAvailableToSell
		response = []
		skus_quantity = {}
		sku_name = {}
		lista_skus = getSkuOnStock
		productos_all = Producto.all
		skus_quantity_final ={}
		for sku in lista_skus
			product_sku = sku["sku"]
			product_name = sku["nombre"]
			quantity = sku["cantidad"]
			if skus_quantity.key?(product_sku)
				skus_quantity[product_sku] += quantity
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		for prod in productos_all
			product_sku = prod.sku
			product_name = prod.nombre

			if skus_quantity.key?(product_sku)
				if @@nuestros_productos.include? product_sku
					
					if skus_quantity[product_sku] > 50
						diferencia = skus_quantity[product_sku] - 50
						if diferencia > 80
							skus_quantity_final[product_sku] = 80
						else
							skus_quantity_final[product_sku] = diferencia
						end
					end
				end
			end
		end
		skus_quantity_final.each_key do |key|
				line = {"sku" => key, "nombre" => sku_name[key], "total" => skus_quantity_final[key]}
				response << line
		end

		res = response.to_json
		render json: res, :status => 200
		return response.to_json
	end

end
