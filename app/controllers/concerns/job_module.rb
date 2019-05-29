module AppController

	@@api_key = "o5bQnMbk@:BxrE"
	@@estado = 'prod'

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

	#IDs Grupos Producción
	@@IDs_Grupos = {"1"=>"5cc66e378820160004a4c3bc",
					"2"=>"5cc66e378820160004a4c3bd",
					"3"=>"5cc66e378820160004a4c3be",
					"4"=>"5cc66e378820160004a4c3bf",
					"5"=>"5cc66e378820160004a4c3c0",
					"6"=>"5cc66e378820160004a4c3c1",
					"7"=>"5cc66e378820160004a4c3c2",
					"8"=>"5cc66e378820160004a4c3c3",
					"9"=>"5cc66e378820160004a4c3c4",
					"10"=>"5cc66e378820160004a4c3c5",
					"11"=>"5cc66e378820160004a4c3c6",
					"12"=>"5cc66e378820160004a4c3c7",
					"13"=>"5cc66e378820160004a4c3c8",
					"14"=>"5cc66e378820160004a4c3c9"}

	#IDs Grupos Desarrollo
	#@@IDs_Grupos = {"1"=>"5cbd31b7c445af0004739be3",
	# 				"2"=>"5cbd31b7c445af0004739be4",
	# 				"3"=>"5cbd31b7c445af0004739be5",
	#				"4"=>"5cbd31b7c445af0004739be6",
	#				"5"=>"5cbd31b7c445af0004739be7",
	#				"6"=>"5cbd31b7c445af0004739be8",
	#				"7"=>"5cbd31b7c445af0004739be9",
	#				"8"=>"5cbd31b7c445af0004739bea",
	#				"9"=>"5cbd31b7c445af0004739beb",
	#				"10"=>"5cbd31b7c445af0004739bec",
	#				"11"=>"5cbd31b7c445af0004739bed",
	#				"12"=>"5cbd31b7c445af0004739bee",
	#				"13"=>"5cbd31b7c445af0004739bef",
	#				"14"=>"5cbd31b7c445af0004739bf0"}

	@@print_valores = false
	#@@print_valores = true

	# Materia primas producidas por nosotros
	@@materias_primas_propias = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	
	# Materias primas prodcidas por otros grupos
	@@materias_primas_ajenas = ["1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]

	# Productos procesados
	@@productos_procesados = ["1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1114", "1115", "1116", "1201", "1207", "1209", "1210", "1211", "1215", "1216", "1301", "1307", "1309", "1310", "1407"]

	@@nuestros_productos = ["1004", "1005", "1006", "1009", "1014", "1015"]
	@@productos_finales = ["10001", "10002", "10003", "10004", "10005", "10006", "10007", "10008", "10009", "10010", "10011", "10012", "10013", "10014", "10015", "10016", "10017", "10018", "10019", "10020", "10021", "10022", "10023", "10024", "10025", "20001", "20002", "20003", "20004", "20005", "30001", "30002", "30003", "30004", "30005", "30006", "30007", "30008"]
	@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]


	def hashing(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
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
	

	def job_start
		puts "\n**********************************************"
		puts "\n************** INICIO DEL JOB ****************"
		puts "\n**********************************************\n\n"
	end


	def job_end
		puts "\n**********************************************"
		puts "\n************** FIN DEL JOB *******************"
		puts "\n**********************************************\n\n"
	end


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

	## NEW ##

	def solicitar_inventario(grupo_id)

		# Para ver e inventario de un grupo, debes indicar el id del grupo
		# Ejemplo: solicitar_inventario(13)
		
		inventario_grupo = HTTParty.get("http://tuerca#{grupo_id}.ing.puc.cl/inventories")

		if @@print_valores
			puts "\nInventario de Grupo " + grupo_id.to_s + ": \n" + inventario_grupo.to_s + "\n"
		end

		return inventario_grupo
	end


	def mover_a_almacen(api_key, almacen_id_origen, almacen_id_destino, skus_a_mover, cantidad_a_mover)

		# puts "Vaciando Almacen " + almacen_id_origen.to_s + "a Almacen " + almacen_id_destino.to_s + "\n"
		cantidad = cantidad_a_mover

		# Obtenemos el espacio disponible en destino
		almacenes = (get_almacenes(api_key)).to_a
		origen_inicial = nombre_almacen(almacen_id_origen)
		destino_final = nombre_almacen(almacen_id_destino)
		
		for almacen in almacenes do
			if almacen["_id"] == almacen_id_destino
				# puts "Almacen de destino usedSpace: " + almacen["usedSpace"].to_s + "\n"
				if almacen["usedSpace"] <= almacen["totalSpace"]
					espacio_disponible = almacen["totalSpace"] - almacen["usedSpace"]
					puts "Espacio disponible en #{destino_final}: " + espacio_disponible.to_s + "\n"

					# Obtenemos los skus en el almacen de origen
					skus_origen = obtener_skus_con_stock(api_key, almacen_id_origen)

					# Para cada sku, obtenemos productos
					for sku_origen in skus_origen
						# puts "SKU en Origen: " + sku_origen["_id"]
						sku_origen_num = sku_origen["_id"]
						
						# Verificamos que el sku se encuentre en la lista de skus a mover
						if skus_a_mover.include? sku_origen_num
							# Obtenemos los productos asociados a ese sku
							productos_origen = get_products_from_almacenes(api_key, almacen_id_origen, sku_origen_num)
							#puts "Productos_origen: " + productos_origen.to_s + "\n"

							# Movemos cada producto de Origen a Destino
							for producto_origen in productos_origen
								if espacio_disponible <= 0
									puts "Destino lleno\n"
									return cantidad_a_mover - cantidad
								end
								mover_producto_entre_almacenes(producto_origen["_id"], almacen_id_destino)
								puts "Producto movido de #{origen_inicial} a #{destino_final}\n"


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

	def mover_ingrediente_a_despacho(sku, cantidad_ingrediente)
		inventario =  getSkuOnStock()
		# puts "getSkuUnStock: \n" + inventario.to_s + "\n"
		stock_en_almacen = Hash.new

		# Partimos almacenes en 0
		id_almacenes = [@@id_despacho, @@id_recepcion, @@id_pulmon, @@id_cocina]
		for almacen in id_almacenes
			stock_en_almacen[almacen] = {"cantidad" => 0}
		end

		# Agregamos los almacenes que tienen stock del producto
		for producto in inventario
			# puts "producto[sku]: " + producto["sku"] + "\n"
			if producto["sku"] == sku
				puts "Encontramos el producto en esta bodega"
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
				# puts "stock_en_almacen[almacen]: " + stock_en_almacen[almacen].to_s + "\n"
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
					puts "Comenzando a mover a despacho"
					if stock_en_almacen[almacen]["cantidad"].to_i >= unidades_por_mover
						puts "unidades por mover #{unidades_por_mover}"
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku], unidades_por_mover)
						return 1
					else 
						mover_a_almacen(@@api_key, almacen, @@id_despacho, [sku], 0)
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
		# p_minimos = Producto.where('sku = ?', '1101')
		# p_minimos = Producto.where('stock_minimo != ?', 0)
		p_minimos.each do |p_referencia|
			if p_referencia.sku == '1101'
				p_referencia.stock_minimo = 300
			end
		end
		return p_minimos
	end

	def solicitar_OC(sku, cantidad, grupo_id)

		# Primero debemos crear la OC

		# crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		cliente = @@IDs_Grupos["4"]
		proveedor = @@IDs_Grupos[grupo_id.to_s] 
		sku = sku.to_s
		fechaEntrega = "1607742000000" #12/12/2020
		cantidad = cantidad.to_s
		precioUnitario = "1"
		canal = "b2b"
		url = "https://tuerca4.ing.puc.cl/documents/{_id}/notification"

		oc_creada = crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)

		# Luego debemos solicitar el producto al grupo, incluyendo el id de la OC

		oc_id = oc_creada["_id"]

		puts "\nSe creo la ordern id: " + oc_creada["_id"] + "\n" 

		# Para solicitar producto a un grupo, debes indicar el sku a pedir, la cantidad a pedir y el id del grupo
		# Ejemplo: solicitar_orden("1001", 10, 13)

		pedido_producto = HTTParty.post("http://tuerca#{grupo_id}.ing.puc.cl/orders",
			body:{
				"sku": sku,
				"cantidad": cantidad,
				"almacenId": @@id_recepcion,
				"oc": oc_id
			}.to_json,
			headers:{
				"group": "4",
				"Content-Type": "application/json"
			})
			#,timeout: 2)

		if @@print_valores
			puts "\nSolicitar Orden a Otro Grupo\n"
			#puts JSON.pretty_generate(pedido_producto)
			puts pedido_producto.to_s
		end
		if pedido_producto["aceptado"]
			response = true	
		else
			response = false
		end
		puts "Respuesta del grupo: #{response}"
		return response
	end

	def pedir_producto_grupos(sku_a_pedir, cantidad_a_pedir)

		puts "\nPEDIR PRODUCTO A GRUPOS\n"

		cantidad_faltante = cantidad_a_pedir

		# Obtenemos el producto en Producto
		producto = Producto.find(sku_a_pedir)

		# Obtenemos sus grupos productores
		grupos_productores = producto.grupos

		
		lista_de_grupos = []
		grupos_productores.each do |g|
			lista_de_grupos << g
		end
		lista_de_grupos.shuffle
		# Para cada grupo productor, revisamos su inventario
		cantidad_entregada = 0

		lista_de_grupos.each do |grupo|
			if cantidad_faltante == 0
				return 1
			end
			# blacklist black list
			if grupo.group_id == 4 || grupo.group_id == 12 || grupo.group_id == 14 || grupo.group_id == 2 || grupo.group_id == 5
				next
			end

			puts "Revisando grupo: " + grupo.group_id.to_s + ", URL: " + grupo.url.to_s + "\n"
			inventario_grupo = solicitar_inventario(grupo.group_id)
			
			if inventario_grupo
				inventario_grupo.each do |p_inventario|
					#puts "sku_a_pedir: " + sku_a_pedir + "\n"
					#puts "p_inventario[sku]: " + p_inventario['sku'] + "\n"
					# Si el grupo productor tiene inventario, lo pedimos
					if sku_a_pedir == p_inventario["sku"]
						puts p_inventario.to_s
						cantidad_inventario = p_inventario["total"]

						# Si el inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante
						if cantidad_inventario >= cantidad_faltante
							puts "El inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante"
							# solicitar_orden_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
							if solicitar_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
								return cantidad_faltante
							else
								return 0
							end
							# cantidad_faltante = 0

						# Si el inventario del otro grupo es menor a la cantidad faltante, pedimos todo el inventario
						else
							puts "El inventario es menor a la cantidad faltante, pedimos todo el inventario"
							if solicitar_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								# solicitar_orden_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								cantidad_faltante -= cantidad_inventario
								cantidad_entregada += cantidad_inventario
							end
						end
					end
				end
			end
		end
		return cantidad_entregada
	end


	def solicitar_orden_OC(sku, cantidad, nro_grupo)
		puts "SOLICITAR ORDEN OC"
		# crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		cliente = @@IDs_Grupos["4"]
		proveedor = @@IDs_Grupos[nro_grupo.to_s]
		sku = sku.to_s
		fechaEntrega = 1607742000000 #12/12/2020
		cantidad = cantidad.to_s
		precioUnitario = "1"
		canal = "b2b"
		url = "https://tuerca4.ing.puc.cl/documents/{_id}/notification"
		materia_prima = true
		oc_creada = nueva_oc(cliente, proveedor, sku, fechaEntrega, cantidad, materia_prima, nro_grupo)
		return oc_creada
	end

	def solicitar_orden(sku, cantidad, grupo_id, order_id)
		puts "SOLICITAR ORDEN"
		puts "sku: #{sku}, tipo #{sku.class}"
		puts "cantidad: #{cantidad}, tipo #{cantidad.class}"
		puts "grupo_id: #{grupo_id}, tipo #{grupo_id.class}"
		puts "order_id: #{order_id}, tipo #{order_id.class}"

		
		pedido_producto = HTTParty.post("https://tuerca#{grupo_id}.ing.puc.cl/orders",
			body:{
				"sku": sku,
				"cantidad": cantidad,
				"almacenId": @@id_recepcion,
				"oc": order_id
			}.to_json,
			headers:{
				"group": "4",
				"Content-Type": "application/json"
			})

		puts pedido_producto
		# case pedido_producto.code
		# 	when 201
		#     	return pedido_producto
		#     when 500
		#     	return nil
		# end
		return pedido_producto
	end

	def crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		puts "CREANDO OC"

		data = "PUT"
		order_creada = HTTParty.put("https://integracion-2019-#{@@estado}.herokuapp.com/oc/crear",
		   body:{
		  	"cliente": cliente,
		  	"proveedor": proveedor,
		  	"sku": sku,
		  	"fechaEntrega": fechaEntrega,
		  	"cantidad": cantidad,
		  	"precioUnitario": precioUnitario,
		  	"canal": canal,
		  	"urlNotificacion": url
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA CREADA"
			puts JSON.pretty_generate(order_creada)
		end
		return order_creada
	end

	def nueva_oc(cliente, proveedor, sku, fechaEntrega, cantidad, materia_prima, nro_grupo)
		puts "NUEVA OC"

		time = Time.now.tomorrow.to_date
		precio = Producto.find(sku).precio_venta
		if materia_prima
			orden_creada = crear_oc(cliente, proveedor, sku, 1607742000000, cantidad, "10", 'b2b', "https://tuerca4.ing.puc.cl/documents/{_id}/notification")
		else
			orden_creada = crear_oc(cliente, proveedor, sku, 1607742000000, cantidad, "10", 'b2b', "https://tuerca4.ing.puc.cl/documents/{_id}/notification")
		end
		puts orden_creada
		puts "\n ORDEN CREADA: #{orden_creada["_id"]}\n"

		respuesta = solicitar_orden(orden_creada['sku'], orden_creada['cantidad'], nro_grupo, orden_creada['_id'])
		puts "NUEVA OC - respuesta: \n#{respuesta}"
		puts "NUEVA OC - tipo respuesta: \n#{respuesta.class}"

		if respuesta["sku"]
			if respuesta["aceptado"] == true
				return 'oc_aceptada'
			else
				return 'oc_rechazada'
			end
		else
			return 'oc_rechazada'
		end
	end

	def revisar_oc
		time = Time.now
		counter = 0
		@host = "fierro.ing.puc.cl"
		@user = "grupo4_dev"
		@password = "1ccWcVkAmJyrOfA"
		Net::SFTP.start(@host, @user, :password => @password) do |sftp|
			entries = sftp.dir.entries("/pedidos")
			entries.each do |entry|
				#break if counter == 4
				counter +=1
				if counter > 2
					time_file = DateTime.strptime(entry.attributes.mtime.to_s,'%s')
					if time_file > (time - 5.hours)
						data_xml = sftp.download!("pedidos/#{entry.name}")
	  					data_json = Hash.from_xml(data_xml).to_json
	  					data_json = JSON.parse data_json
	  					order_id = data_json["order"]['id']
	  					orden_compra = obtener_oc(order_id)
	  					if orden_compra[0]["estado"] == "creada"
	  						aceptar_o_rechazar_oc_producto_final(orden_compra[0])
	  					end
					end
					
  				end
			end
		end
	end

	def notificar(url, status)
		data = "POST"
		notificacion = HTTParty.post(url,
		   body:{
		  	"status": status
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA CREADA"
			puts JSON.pretty_generate(notificacion)
		end
		return notificacion
	end

	def aceptar_o_rechazar_oc_producto_final(orden_compra)
		@order_id = orden_compra["_id"]
		@sku = orden_compra["sku"]
		@cantidad = orden_compra["cantidad"]
		@proveedor = orden_compra["proveedor"]
		@fecha_entrega = orden_compra["fechaEntrega"]
		@estado = orden_compra["estado"]

		if (@sku.length == 5)
			respuesta_cocina = cocinar(@sku, @cantidad)
			if respuesta_cocina
				puts "hay en cocina"
				if @fecha_entrega > respuesta_cocina
					crear_documento_oc(orden_compra)
					aceptar_oc(@order_id)
					return ["aceptada", 0]
				else
					rechazar_oc(@order_id, "No podemos complir con los plazos entregados")
					return ["rechazada","No podemos complir con los plazos entregados"]
				end
			else
				puts "no hay en cocina"
				rechazar_oc(@order_id, "No hay inventario para realizar pedido")
				return ["rechazada","No hay inventario para realizar pedido"]
			end
		end
		return nil
	end

	def crear_documento_oc(orden_compra)
		Document.create! do |document|
			document.all = orden_compra['_id'],
			document.cliente = orden_compra['cliente'],
			document.proveedor = orden_compra['proveedor'],
			document.sku = orden_compra['sku'],
			document.fechaEntrega = orden_compra['fechaEntrega'],
			document.cantidad = orden_compra['cantidad'],
			document.cantidadDespachada = orden_compra['cantidadDespachada'],
			document.precioUnitario = orden_compra['precioUnitario'],
			document.canal = orden_compra['canal'],
			document.estado = orden_compra['estado'],
			document.notas = orden_compra['notas'],
			document.rechazo = orden_compra['rechazo'], 
			document.anulacion = orden_compra['anulacion'],
			document.order_id = orden_compra['_id'],
			document.urlNotificacion = orden_compra['urlNotificacion']
		end
	end

	def borrar_todos_documentos_compra
		@documents = Document.all
		@documents.each do |document|
		   document.destroy
		end
	end

end
