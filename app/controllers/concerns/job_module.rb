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
		puts "\n******** INICIO DE #{self.class} ********"
		puts "\n**********************************************\n\n"
	end
	
	def job_end
		puts "\n**********************************************"
		puts "\n******* FIN DE #{self.class} *********"
		puts "\n**********************************************\n\n"
	end

	## NEW ##

	def solicitar_inventario(grupo_id)

		# Para ver e inventario de un grupo, debes indicar el id del grupo
		# Ejemplo: solicitar_inventario(13)
		
		begin
			inventario_grupo = HTTParty.get("http://tuerca#{grupo_id}.ing.puc.cl/inventories", timeout: 90)
		rescue Net::OpenTimeout
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		rescue Timeout::Error
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		rescue Net::ReadTimeout
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		else	
			return inventario_grupo
		end
		
		if @@print_valores
			puts "\nInventario de Grupo " + grupo_id.to_s + ": \n" + inventario_grupo.to_s + "\n"
		end
		
		return false
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

	# Negro
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

end