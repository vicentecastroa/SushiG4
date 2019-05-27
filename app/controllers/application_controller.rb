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

	# Materia primas producidas por nosotros
	@@materias_primas_propias = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	
	# Materias primas prodcidas por otros grupos
	@@materias_primas_ajenas = ["1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]

	# Productos procesados
	@@productos_procesados = ["1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1114", "1115", "1116", "1201", "1207", "1209", "1210", "1211", "1215", "1216", "1301", "1307", "1309", "1310", "1407"]

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
						if skus_a_mover.include? sku_origen_num
							# Obtenemos los productos asociados a ese sku
							productos_origen = get_products_from_almacenes(api_key, almacen_id_origen, sku_origen_num)
							puts "Productos_origen: " + productos_origen.to_s + "\n"

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

	def mover_ingrediente_a_despacho(sku, cantidad_ingrediente)
		inventario =  getSkuOnStock()
		puts "getSkuUnStock: \n" + inventario.to_s + "\n"
		stock_en_almacen = Hash.new

		# Partimos almacenes en 0
		id_almacenes = [@@id_despacho, @@id_recepcion, @@id_pulmon, @@id_cocina]
		for almacen in id_almacenes
			stock_en_almacen[almacen] = {"cantidad" => 0}
		end

		# Agregamos los almacenes que tienen stock del producto
		for producto in inventario
			puts "producto[sku]: " + producto["sku"] + "\n"
			if producto["sku"] == sku
				puts "Encontramos el producto en esta bodega"
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
				puts "stock_en_almacen[almacen]: " + stock_en_almacen[almacen].to_s + "\n"
			end
		end
		unidades_por_mover = cantidad_ingrediente

		# Para cada almacen, movemos las unidades
		for almacen in id_almacenes
			# Checkeamos si tenemos unidades en DESPACHO
			if almacen == @@id_despacho
				if stock_en_almacen[almacen]["cantidad"]
					if stock_en_almacen[almacen]["cantidad"] >= unidades_por_mover
						return 1
					else 
						unidades_por_mover -= stock_en_almacen[almacen]["cantidad"]
					end
				end
			else
			# Movemos las unidades en RECEPCIÓN, PULMÓN y COCINA a DESPACHO
				if stock_en_almacen[almacen]["cantidad"]
					if stock_en_almacen[almacen]["cantidad"] >= unidades_por_mover
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku.to_i], unidades_por_mover)
						return 1
					else 
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku.to_i], 0)
						unidades_por_mover -= stock_en_almacen[almacen]["cantidad"]
					end
				end
			end
		end 
		
		return 1
	end

	def getInventoriesAll # Mismo retorno que getInventories pero incluyendo todos los productos, incluso los con stock 0
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
			quantity = 0
			if skus_quantity.key?(product_sku)
				#skus_quantity[product_sku] += quantity
				#sku_name[product_sku] = product_name
			else
				sku_name[product_sku] = product_name
				skus_quantity[product_sku] = quantity
			end
		end
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		#res = response.to_json
		#render plain: res, :status => 200
		#return response.to_json

		return response

	end

	def getInventoriesOne(sku) # Retorna stock de un solo producto
		inventario_total = getInventoriesAll
		inventario_total.each do |inventario|
			sku_inventario = inventario["sku"]
			if sku == sku_inventario
				return inventario
			end
		end
	end
 

	def getProductosMinimos
		p_minimos = Producto.where('stock_minimo != ? OR sku = ?', 0, '1101')
		p_minimos.each do |p_referencia|
			if p_referencia.sku == '1101'
				p_referencia.stock_minimo = 300
			end
		end
		return p_minimos
	end



	def perform
		
		puts "\n****************************\nInventory worker checkeando inventario\n****************************\n\n"

		pedidos = Hash.new

		## Obtenemos el inventario total de cada producto ##
		inventario_total = getInventoriesAll()
		puts "Inventario Total: \n" + inventario_total.to_s
		# [{"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}, {}, {}]

		p_all = Producto.all

		## Obtenemos los productos que deban mantener un stock minimo ##
		p_minimos = getProductosMinimos()
		# puts "Productos Minimos: \n" + p_minimos.to_s

		## Para cada producto que deba mantener stock minimo, revisamos su stock ##
		p_minimos.each do |p_minimo|

			## Obtenemos el stock minimo que debe mantener el producto ##
			stock_minimo = p_minimo.stock_minimo.to_i

			puts "\n****************************\nProducto Minimo: " + p_minimo.nombre + "\n"
			puts"\nStock Minimo: " + stock_minimo.to_s

			## Obtenemos el producto dentro del inventario ##
			p_minimo_inventario = getInventoriesOne(p_minimo.sku)

			## Por cada producto que deba mantener stock minimo, comparo y encuentro el producto en el inventario
			sku = p_minimo_inventario["sku"]
			cantidad = p_minimo_inventario["cantidad"].to_i
			if cantidad < stock_minimo # Si la cantidad es mayor o igual al stock minimo, no hago nada

				puts "\nCantidad Actual: " + cantidad.to_s

				# Calculamos la cantidad faltante de producto como la diferencia entre el stock minimo y la cantidad actual en inventario
				cantidad_faltante = stock_minimo - cantidad

				# Obtenemos el tamaño de los lotes de producción del producto
				lote_produccion = p_minimo.lote_produccion

				# Los lotes faltantes a producir seran la cantidad faltante dividida en el lote de producción del producto
				lotes_faltantes = (cantidad_faltante.to_f / lote_produccion.to_f).ceil

				# Calculamos la cantidad a fabricar del producto
				cantidad_a_producir = lotes_faltantes * lote_produccion

				puts "\nCantidad Faltante: " + cantidad_faltante.to_s + " -> Lotes Faltantes: " + lotes_faltantes.to_s
				puts "\n****************************\n\n"
				puts "Ingredientes: \n"

				# Si el producto es MASAGO, lo pido a los grupos productores correspondientes
				if sku.to_i == 1013
					#get_producto_grupo(1013, cantidad_faltante)
					#break #cambio a revisar al siguiente producto de p_minimos

				# Si el producto NO es MASAGO, debo verificar el stock de sus ingredientes antes de fabricar
				else
						
					# Obtenemos los ingredientes del producto
					ingredientes = IngredientesAssociation.where(producto_id: p_minimo.sku)

					# Para cada ingrediente, calculamos el stock necesario para producir el producto y pedimos en caso de no tenerlo
					ingredientes.each do |ingrediente|

						puts "\t ID Ingrediente: " + ingrediente.ingrediente_id + "\n"

						# Obtenemos el ingrediente desde Producto
						p_ingrediente = Producto.find(ingrediente.ingrediente_id)

						# Obtenemos el inventario del ingrediente
						p_ingrediente_inventario = getInventoriesOne(p_ingrediente.sku)

						# Obtenemos la cantidad de ingrediente requerido para producir un lote de producto
						unidades_bodega = ingrediente.unidades_bodega

						# Calculamos la cantidad de unidades requeridas multiplicando las unidades bodega por los lotes faltantes de producto
						cantidad_ingrediente = unidades_bodega * lotes_faltantes

						# Si el stock actual es mayor o igual a la cantidad de ingrediente requerido, enviamos ingrediente a despacho y reponemos la misma cantidad
						if p_ingrediente_inventario["cantidad"] >= cantidad_ingrediente
							puts "\t ¡Tenemos el ingrediente! Enviamos a despacho " + cantidad_ingrediente.to_s + " unidades.\n"

							# Enviamos ingredientes a despacho
							mover_ingrediente_a_despacho(ingrediente.ingrediente_id, cantidad_ingrediente)

							# Fabricamos sin costo los ingredientes enviados
							#fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, cantidad_ingrediente)

						
						# Si el stock actual es menor a la cantidad de ingrediente requerido, calculamos la cantidad faltante de ingrediente
						else
							cantidad_faltante_ingrediente = cantidad_ingrediente - p_ingrediente_inventario["cantidad"]

							if @@materias_primas_propias.include? ingrediente.ingrediente_id 

								# Obtenemos el tamaño de lote de producción del ingrediente
								lote_produccion_ingrediente = p_ingrediente.lote_produccion

								# Calculamos los lotes faltantes de ingrediente
								lotes_faltantes_ingrediente = (cantidad_faltante_ingrediente / lote_produccion_ingrediente).ceil

								# Definimos factor de multiplicacion de stock minimo para ingredientes propios
								factor_ingredientes = 2

								# Calculamos la cantidad a producir del ingrediente
								cantidad_a_producir_ingrediente = factor_ingredientes * lotes_faltantes_ingrediente * lote_produccion_ingrediente

								# Fabricamos sin costo la cantidad a producir del ingrediente
								puts fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, (cantidad_a_producir_ingrediente).ceil)

							# Si el producto no es nuestro, lo pedimos a otro grupo
							else

								#get_producto_grupo(p_ingrediente.sku, cantidad_faltante_ingrediente)

							end
						end



						#lote_produccion_ingrediente = p_ingrediente.lote_produccion
						## un_a_pedir_ingrediente = (lotes_faltantes_p_referencia) * (cantidad_lote_ingrediente)
						#un_a_pedir_ingrediente = (lotes_faltantes_p_referencia * cantidad_lote_ingrediente * lote_produccion_ingrediente).ceil
						#puts "un_a_pedir_ingrediente = (" + lotes_faltantes_p_referencia.to_s + " * " + cantidad_lote_ingrediente.to_s + " * " + lote_produccion_ingrediente.to_s + ").ceil\n"
						## Revisar si tenemos stock del ingrediente en cualquier almacen
						#	
						#lotes_a_pedir_ingrediente = (un_a_pedir_ingrediente.to_f / lote_produccion_ingrediente).ceil
						#have_prod = have_producto(ingrediente.ingrediente_id, un_a_pedir_ingrediente, inventario_total)
						#if have_prod == 1
						#	puts "\t ¡Tenemos el ingrediente! Enviamos a despacho " + un_a_pedir_ingrediente.to_s + " unidades.\n"
						#	p = mover_ingrediente_a_despacho(ingrediente.ingrediente_id, un_a_pedir_ingrediente)
						#	###### FALTA MANDAR A FABRICAR PRODUCTO PROCESADO ####
						#elsif have_prod == 0
						#	puts "\t ¡No tenemos el ingrediente!\n"					
						#	if @@nuestros_productos.include? ingrediente.ingrediente_id 
						#		puts "\t El ingrediente es nuestro, fabricamos sin pago " + lotes_a_pedir_ingrediente.to_s + " lotes.\n"
						#		#puts fabricar_sin_pago(@@api_key, ingrecantidad_lote_p_referenciaiente.ingrediente_id, lotes_a_pedir_ingrediente)
						#		puts fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, 2*un_a_pedir_ingrediente.ceil)
						#	else
						#		#get_producto_grupo(ingrediente.ingrediente_id, lotes_a_pedir_ingrediente)
						#	end
						#else
						#	puts "no existe"
						#end
					end

					#fabricar_sin_pago(@@api_key, p_referencia.sku, lotes_faltantes_p_referencia)
					puts "Fabricamos sin pago el sku " + p_minimo.sku + ", una cantidad de " + cantidad_a_producir.to_s + "\n"
					puts fabricar_sin_pago(@@api_key, p_minimo.sku, cantidad_a_producir)
					puts "\nFabricado"
				end
			end			
		end
	end








  protect_from_forgery with: :exception
  @@api_key = "o5bQnMbk@:BxrE"


end

