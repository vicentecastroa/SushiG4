
module ApplicationHelper	
	include VariablesHelper
	include ApiBodegaHelper
	include ApiOcHelper
	include GruposHelper

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
		elsif id_almacen == @@id_multiuso_1
			return "Multiuso 1"
		elsif id_almacen == @@id_multiuso_2
			return "Multiuso 2"
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
		if @@debug_mode
			puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
			puts JSON.pretty_generate(producto_despachado)
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
						if diferencia > 30
							skus_quantity_final[product_sku] = 30
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

	def getSkuOnStock
		response = []
		#id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]

		for almacen in @@id_almacenes
			@request = (obtener_skus_con_stock(almacen)).to_a
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

		if @@debug_mode; puts "get inventories 1" end
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
		if @@debug_mode; puts "get inventories 2" end
		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		# render plain: res, :status => 200
		return response.to_json
	end

	def have_producto(sku, cantidad_minima, inventario_total)
		if @@debug_mode; puts "have_producto(" + sku + ", " + cantidad_minima.to_s + ", " + ")\n" end
		for producto in inventario_total
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
		#if @@debug_mode; puts "getSkuOnStock: \n" + inventario.to_s + "\n" end
		stock_en_almacen = Hash.new

		# Partimos almacenes en 0
		# id_almacenes = [@@id_despacho, @@id_recepcion, @@id_pulmon, @@id_cocina]
		id_almacenes = @@id_almacenes
		for almacen in id_almacenes
			stock_en_almacen[almacen] = {"cantidad" => 0}
		end

		# Agregamos los almacenes que tienen stock del producto
		for producto in inventario
			#if @@debug_mode; puts "producto[sku]: " + producto["sku"] + "\n" end
			if producto["sku"] == sku
				#if @@debug_mode; puts "Encontramos el producto en esta bodega" end
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
				#if @@debug_mode; puts "stock_en_almacen[almacen]: " + stock_en_almacen[almacen].to_s + "\n" end
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
						mover_a_almacen(almacen, @@id_despacho, [sku], unidades_por_mover)
						return 1
					else 
						mover_a_almacen(almacen, @@id_despacho, [sku], 0)
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

	def pedir_producto_grupos(sku_a_pedir, cantidad_a_pedir)

		if @@debug_mode; puts "\nPEDIR PRODUCTO A GRUPOS\n" end
		cantidad_faltante = cantidad_a_pedir
		# Obtenemos el producto en Producto
		producto = Producto.find(sku_a_pedir)
		# Obtenemos sus grupos productores
		grupos_productores = producto.grupos

		
		lista_de_grupos = []
		grupos_productores.each do |g|
			lista_de_grupos << g
		end
		
		# REVIEW blacklist black list lista negra
		lista_negra = [4] # 8, 10, 12
		
		lista_negra.each do |l|
			lista_de_grupos.each do |gr|
				if gr.group_id == l
					lista_de_grupos.delete(gr)
				end
			end
		end
		
		lista_de_grupos = lista_de_grupos.shuffle

		# Para cada grupo productor, revisamos su inventario
		cantidad_entregada = 0

		lista_de_grupos.each do |grupo|
			if cantidad_faltante == 0
				return 1
			end

			if @@debug_mode; puts "Revisando grupo: " + grupo.group_id.to_s + ", URL: " + grupo.url.to_s + "\n" end
			inventario_grupo = solicitar_inventario(grupo.group_id)
			
			if inventario_grupo
				inventario_grupo.each do |p_inventario|
					# Si el grupo productor tiene inventario, lo pedimos
					if sku_a_pedir == p_inventario["sku"]
						if @@debug_mode; puts p_inventario.to_s end
						cantidad_inventario = p_inventario["total"]

						if !cantidad_inventario; next end

						# Si el inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante
						if cantidad_inventario >= cantidad_faltante

							if @@debug_mode; puts "El inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante" end
							# solicitar_orden_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
							if solicitar_OC(sku_a_pedir, cantidad_faltante.to_i, grupo.group_id)
								return cantidad_faltante
							else
								next
							end
							# cantidad_faltante = 0

						# Si el inventario del otro grupo es menor a la cantidad faltante, pedimos todo el inventario
						else

							if @@debug_mode; puts "El inventario es menor a la cantidad faltante, pedimos todo el inventario" end
							if solicitar_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								# solicitar_orden_OC(sku_a_pedir, cantidad_inventario.to_i, grupo.group_id)
								cantidad_faltante -= cantidad_inventario
								cantidad_entregada += cantidad_inventario
							end
						end
					end
				end
				# return cantidad_faltante
			end
		end
		return cantidad_entregada
	end


	def getProductosMinimos
		p_minimos = Producto.where('stock_minimo != ? OR sku = ? OR sku = ?', 0, '1101', '1111')
		# p_minimos = Producto.where('sku = ?', '1111')
		# p_minimos = Producto.where('stock_minimo != ?', 0)
		p_minimos.each do |p_referencia|
			if p_referencia.sku == "1101"
				p_referencia.stock_minimo = 300
			end
			if p_referencia.sku == "1111"
				p_referencia.stock_minimo = 10
			end
		end
		return p_minimos
	end

	def getPrintStock
		@capacidad_almacenes = [100000399,533,180,1322,5315,1012]
		@cantidad_almacenes = [0,0,0,0,0,0]
		@stock = []
		response = Hash.new()
		#id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]
		id_almacenes = @@id_almacenes
		for prod in Producto.all
			if prod.sku.length == 4
				response[prod.sku] = Hash.new()
				response[prod.sku] = {
					"nombre" => prod.nombre,
					"cantidadPulmon" => 0,
					"cantidadRecepcion" => 0,
					"cantidadCocina" => 0,
					"cantidadDespacho" => 0,
					"cantidadMultihuso_1" => 0,
					"cantidadMultihuso_2" => 0,
					"sku" => prod.sku,
					"cantidad" => 0,
					"faltante" => 0,
				}
			end
		end

		for almacen in id_almacenes
			@request = (obtener_skus_con_stock(almacen)).to_a
			for element in @request do
				sku = element["_id"]
				if sku.length == 4
					if almacen == @@id_despacho
						response[sku]["cantidadDespacho"] = element["total"]
						@cantidad_almacenes[2] += element["total"]
					elsif almacen == @@id_pulmon
						response[sku]["cantidadPulmon"] = element["total"]
						@cantidad_almacenes[0] += element["total"]
					elsif almacen == @@id_recepcion
						response[sku]["cantidadRecepcion"] = element["total"]
						@cantidad_almacenes[1] += element["total"]
					elsif almacen == @@id_cocina
						response[sku]["cantidadCocina"] = element["total"]
						@cantidad_almacenes[3] += element["total"]
					elsif almacen == @@id_multiuso_1
						response[sku]["cantidadMultihuso_1"] = element["total"]
						@cantidad_almacenes[4] += element["total"]
					elsif almacen == @@id_multiuso_2
						response[sku]["cantidadMultihuso_2"] = element["total"]
						@cantidad_almacenes[5] += element["total"]
					end
					response[sku]["cantidad"] += element["total"]
				end
			end
		end

		for prod in Producto.all
			if prod.sku.length == 4
				response[prod.sku]["stock_minimo"] = @@minimos[prod.sku][1]
				if (response[prod.sku]["stock_minimo"] - response[prod.sku]["cantidad"]) > 0
					response[prod.sku]["faltante"] =  response[prod.sku]["stock_minimo"] - response[prod.sku]["cantidad"]
				end
				@stock << response[prod.sku]
			end
		end
		return @stock, @cantidad_almacenes, @capacidad_almacenes
	end

	def getCocinaStock
		@cocina = []
		response = Hash.new()
		#id_almacenes = [@@id_cocina, @@id_pulmon, @@id_recepcion, @@id_despacho]
		id_almacenes = @@id_almacenes
		for prod in Producto.all
			if prod.sku.length == 5
				response[prod.sku] = Hash.new()
				response[prod.sku] = {
					"nombre" => prod.nombre,
					"sku" => prod.sku,
					"cantidad" => 0,
				}
			end
		end

		@request = (obtener_skus_con_stock(@@id_cocina)).to_a
		for element in @request do
			sku = element["_id"]
			response[sku]["cantidad"] = element["total"]
		end

		for prod in Producto.all
			if prod.sku.length == 5
				@cocina << response[prod.sku]
			end
		end
		return @cocina
	end
end
