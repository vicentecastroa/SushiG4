class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	@@api_key = "o5bQnMbk@:BxrE"

	#IDs Producción
	#@@id_recepcion = "5cc7b139a823b10004d8e6df"
	#@@id_despacho = "5cc7b139a823b10004d8e6e0"
	#@@id_pulmon = "5cc7b139a823b10004d8e6e3"
	#@@id_cocina = "5cc7b139a823b10004d8e6e4"
	#@@url = "https://integracion-2019-prod.herokuapp.com/bodega"

	#IDs Desarrollo
	@@id_recepcion = "5cbd3ce444f67600049431c5"
	@@id_despacho = "5cbd3ce444f67600049431c6"
	@@id_pulmon = "5cbd3ce444f67600049431c9"
	@@id_cocina = "5cbd3ce444f67600049431ca"
	@@url = "https://integracion-2019-dev.herokuapp.com/bodega"

	@@print_valores = false

	# Capacidades Bodegas
	@@tamaño_cocina = 1122
	@@tamaño_recepcion = 133
	@@tamaño_despacho = 80
	@@tamaño_pulmon = 99999999

	def print_start
		puts "\n\n--------------------------\n    Funciona el require y worker   \n--------------------------\n\n"
	end
	

	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
	end

  
	def print_start
		puts "\n\n--------------------------\n    Funciona el require y worker   \n--------------------------\n\n"
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

	def mover_a_almacen(api_key, almacen_id_origen, almacen_id_destino, skus_a_mover, cantidad_a_mover)

		puts "Vaciando Almacen " + almacen_id_origen.to_s + "a Almacen " + almacen_id_destino.to_s + "\n"
		cantidad = cantidad_a_mover

		# Obtenemos el espacio disponible en destino
		almacenes = (get_almacenes(api_key)).to_a
		for almacen in almacenes do
			if almacen["_id"] == almacen_id_destino
				puts "Almacen de destino usedSpace: " + almacen["usedSpace"].to_s + "\n"
				if almacen["usedSpace"] <= almacen["totalSpace"]
					espacio_disponible = almacen["totalSpace"] - almacen["usedSpace"]
					puts "Espacio disponible en destino: " + espacio_disponible.to_s + "\n"

					puts "Vaciando Origen\n"

					# Obtenemos los skus en el almacen de origen
					skus_origen = obtener_skus_con_stock(api_key, almacen_id_origen)

					# Para cada sku, obtenemos productos
					for sku_origen in skus_origen
						puts "SKU en Origen: " + sku_origen["_id"]
						sku_origen_num = sku_origen["_id"]
						
						# Verificamos que el sku se encuentre en la lista de skus a mover
						if skus_a_mover.include? sku_origen_num.to_i
							# Obtenemos los productos asociados a ese sku
							productos_origen = get_products_from_almacenes(api_key, almacen_id_origen, sku_origen_num)

							# Movemos cada producto de Origen a Destino
							for producto_origen in productos_origen
								if espacio_disponible <= 0
									puts "Destino lleno\n"
									return
								end
								mover_producto_entre_almacenes(producto_origen["_id"], almacen_id_destino)
								puts "Producto movido de Origen a Destino"

								# Disminuyo en 1 el espacio disponible
								espacio_disponible -=1

								# Si cantidad a mover es 0, se interpreta como mover todo los productos
								if cantidad != 0
									cantidad -= 1
									puts "Productos a mover restantes: " + cantidad.to_s + "\n"
									if cantidad == 0
										return
									end
								end
							end
						end						
					end
				end
			end
		end
	end

	def recepcion_a_cocina(api_key)

		# Vaciamos Pulmón
		mover_a_almacen(api_key, @@id_pulmon, @@id_cocina, @@materias_primas_propias, 5)

		# Vaciamos Recepción
		mover_a_almacen(api_key, @@id_recepcion, @@id_cocina, @@materias_primas_propias, 5)

	end

	def cocina_a_recepcion(api_key)

		# Vaciamos Cocina
		vaciar_almacen(api_key, @@id_cocina, @@id_recepcion, @@materias_primas_propias)
	
	end

	def getSkuOnStock
		response = []
		id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]

		for almacen in id_almacenes
			@request = (obtener_skus_con_stock(@@api_key, almacen)).to_a
			for element in @request do
				sku = element["_id"]
				@product = Producto.find(sku)
				product_name = @product.nombre
				quantity = element["total"]
				line = {"almacenId" => almacen, "sku" => sku, "cantidad" => quantity, "nombre" => product_name}
				response << line
			end
		end 

		return response

	end

	def getInventories
		response = []
		skus_quantity = {}
		sku_name = {}
		lista_skus = getSkuOnStock
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
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		render plain: res, :status => 200
		return response.to_json

	end 

	## NEW ENTREGA 2 ##

	def cocinar (sku_a_cocinar, cantidad_a_cocinar)

		inventario_total = getInventories()
		
		# Dejar ingredientes en almacen tipo cocina
		producto_a_cocinar = Producto.find(sku_a_cocinar)



		# LLamar a metodo "fabricar" de bodega, indicando sku y cantidad a producir
			# Se retiran (automaticamente) ingredientes de cocina
			# Se deja orden de fabricación pendiente
			# El metodo retorna fecha estimada de producción

		# Llegan productos fabricados a almacén cocina.
			# En caso de que la cocina está llena, llegarán a almacen pulmon
		
		# Se deben despachar utilizando el método "despacar producto", indicando el id de la orden de compra

	end

	## WORKER ##

	@@nuestros_productos = ["1004", "1005", "1006", "1009", "1014", "1015"]
	@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]
	

	def have_producto(sku, cantidad_minima, inventario_total)
		#inventario_total = getInventoriesCero()

		puts "have_producto(" + sku + ", " + cantidad_minima.to_s + ", " + ")\n"

		for producto in inventario_total
			#puts "Producto sku: " + producto["sku"]
			if producto["sku"].to_s == sku && producto["cantidad"].to_f < cantidad_minima.to_f
				return 0
			elsif producto["sku"].to_s == sku && producto["cantidad"].to_f >= cantidad_minima.to_f
				return 1
			end
		end
		return 2
	end

	def mover_ingrediente_a_despacho(sku, stock_minimo)
		inventario =  getSkuOnStock()
		stock_en_almacen = Hash.new
		for producto in inventario
			if producto["sku"] == sku
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
			end
		end
		unidades_por_mover = stock_minimo
		if stock_en_almacen[@@id_despacho]["cantidad"] >= stock_minimo
			return 1
		else 
			unidades_por_mover -= stock_en_almacen[@@id_despacho]["cantidad"]
		end

		if stock_en_almacen[@@id_recepcion]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_recepcion, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_recepcion, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_recepcion]["cantidad"]
		end

		if stock_en_almacen[@@id_pulmon]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_pulmon, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_pulmon, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_pulmon]["cantidad"]
		end

		if stock_en_almacen[@@id_cocina]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_cocina, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_cocina, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_cocina]["cantidad"]
		end
		
		return 1
	end

	def getInventoriesCero
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
			producto_name = prod.nombre
			quantity = 0
			if skus_quantity.key?(product_sku)
				skus_quantity[product_sku] += quantity
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		return response

	end 

	def perform
		
		puts "\n****************************\nInventory worker checkeando inventario\n****************************\n\n"

		pedidos = Hash.new
		
		#inventario = getSkuOnStock()
		#[{"almacenId" => almacen, "sku" => sku, "cantidad" => quantity, "nombre" => product_name}, {...}, {...},.....]
		inventario_total = getInventoriesCero()
		puts "Inventario Total: \n" + inventario_total.to_s
		# [{"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}, {}, {}]

		p_all = Producto.all
		p_minimos = Producto.where('stock_minimo != ? OR sku = ?', 0, '1101') # selecciono los que tienen stock minimo y el arroz cocido
		puts "Productos Minimos: \n" + p_minimos.to_s
		p_minimos.each do |p_referencia|

			if p_referencia.sku == '1101'
				p_referencia.stock_minimo = 300
			end

			stock_minimo = p_referencia.stock_minimo.to_i

			puts "\n****************************\nProducto Minimo: " + p_referencia.nombre + "\n"
			puts"\nStock Minimo: " + stock_minimo.to_s


			inventario_total.each do |producto_total| # reviso el inventario total 
				sku = producto_total["sku"]
				cantidad = producto_total["cantidad"].to_i
				
				cantidad_a_pedir = 0
				 # por cada producto del inventario minimo, comparo y veo si encuentro
				 # el producto en el invetario total
				if p_referencia.sku == sku && cantidad < stock_minimo

					puts "\nCantidad Actual: " + cantidad.to_s

					cantidad_faltante = stock_minimo - cantidad
					lotes_faltantes_p_referencia = (cantidad_faltante.to_f / p_referencia.lote_produccion).ceil

					puts "\nCantidad Faltante: " + cantidad_faltante.to_s + " -> Lotes Faltantes: " + lotes_faltantes_p_referencia.to_s
					puts "\n****************************\n\n"
					puts "Ingredientes: \n"

					#si es masago
					if sku.to_i == 1013
						#get_producto_grupo(1013, lotes_faltantes_p_referencia)
						break #cambio a revisar al siguiente producto de p_minimos
					else
					#si no es masago
						ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
						ingredientes.each do |ingrediente|

							puts "\t ID Ingrediente: " + ingrediente.ingrediente_id + "\n"

							cantidad_lote_ingrediente = ingrediente.unidades_bodega
							lote_produccion_ingrediente = Producto.find(ingrediente.ingrediente_id).lote_produccion
							un_a_pedir_ingrediente = (lotes_faltantes_p_referencia) * (cantidad_lote_ingrediente)
							# Revisar si tenemos stock del ingrediente en cualquier almacen
							
							lotes_a_pedir_ingrediente = (un_a_pedir_ingrediente.to_f / lote_produccion_ingrediente).ceil
							have_prod = have_producto(ingrediente.ingrediente_id, un_a_pedir_ingrediente, inventario_total)
							if have_prod == 1
								puts "\t ¡Tenemos el ingrediente! Enviando a despacho.\n"
								p = mover_ingrediente_a_despacho(ingrediente.ingrediente_id, un_a_pedir_ingrediente)
							elsif have_prod == 0
								puts "\t ¡No tenemos el ingrediente!\n"								
								if @@nuestros_productos.include? ingrediente.ingrediente_id 
									puts "\t El ingrediente es nuestro, fabricamos sin pago un lote de " + lotes_a_pedir_ingrediente.to_s + "\n"
									fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, lotes_a_pedir_ingrediente)
								else
									#get_producto_grupo(ingrediente.ingrediente_id, lotes_a_pedir_ingrediente)
								end
							else
								puts "no existe"
							end
						end

						fabricar_sin_pago(@@api_key, p_referencia.sku, lotes_faltantes_p_referencia)

					end
				end
			end
		end
	end








  protect_from_forgery with: :exception
  @@api_key = "o5bQnMbk@:BxrE"


end

