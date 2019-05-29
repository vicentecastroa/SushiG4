require 'net/ftp'
require 'ftp_helper'
require 'application_helper'
require 'active_support/core_ext/hash'
require 'date'

class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	
	include ApplicationHelper
	include FtpHelper
	include OcHelper

	@@api_key = "o5bQnMbk@:BxrE"

	#IDs Producción
	@@id_recepcion = '5cc7b139a823b10004d8e6df'
	@@id_despacho = "5cc7b139a823b10004d8e6e0"
	@@id_pulmon = "5cc7b139a823b10004d8e6e3"
	@@id_cocina = "5cc7b139a823b10004d8e6e4"
	@@url = "http://integracion-2019-prod.herokuapp.com/bodega"

	@@id_produccion = "5cc66e378820160004a4c3bf"
	@@id_produccion_1 = "5cc66e378820160004a4c3bc"
	@@id_produccion_2 = "5cc66e378820160004a4c3bd"
	@@id_produccion_3 = "5cc66e378820160004a4c3be"
	@@id_produccion_4 = "5cc66e378820160004a4c3bf"
	@@id_produccion_5 = "5cc66e378820160004a4c3c0"
	@@id_produccion_6 = "5cc66e378820160004a4c3c1"
	@@id_produccion_7 = "5cc66e378820160004a4c3c2"
	@@id_produccion_8 = "5cc66e378820160004a4c3c3"
	@@id_produccion_9 = "5cc66e378820160004a4c3c4"
	@@id_produccion_10 = "5cc66e378820160004a4c3c5"
	@@id_produccion_11 = "5cc66e378820160004a4c3c6"
	@@id_produccion_12 = "5cc66e378820160004a4c3c7"
	@@id_produccion_13 = "5cc66e378820160004a4c3c8"
	@@id_produccion_14 = "5cc66e378820160004a4c3c9"

	@@print_valores = false

	# Capacidades Bodegas
	@@tamaño_cocina = 1122
	@@tamaño_recepcion = 133
	@@tamaño_despacho = 80
	@@tamaño_pulmon = 99999999

	@@nuestros_productos = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]

	# Materia primas producidas por nosotros
	@@materias_primas_propias = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	# Materias primas prodcidas por otros grupos
	@@materias_primas_ajenas = ["1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]
	# Productos procesados
	@@productos_procesados = ["1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1114", "1115", "1116", "1201", "1207", "1209", "1210", "1211", "1215", "1216", "1301", "1307", "1309", "1310", "1407"]

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

	# #IDs Grupos Desarrollo
	# @@IDs_Grupos = {"1"=>"5cbd31b7c445af0004739be3",
	# 				"2"=>"5cbd31b7c445af0004739be4",
	# 				"3"=>"5cbd31b7c445af0004739be5",
	# 				"4"=>"5cbd31b7c445af0004739be6",
	# 				"5"=>"5cbd31b7c445af0004739be7",
	# 				"6"=>"5cbd31b7c445af0004739be8",
	# 				"7"=>"5cbd31b7c445af0004739be9",
	# 				"8"=>"5cbd31b7c445af0004739bea",
	# 				"9"=>"5cbd31b7c445af0004739beb",
	# 				"10"=>"5cbd31b7c445af0004739bec",
	# 				"11"=>"5cbd31b7c445af0004739bed",
	# 				"12"=>"5cbd31b7c445af0004739bee",
	# 				"13"=>"5cbd31b7c445af0004739bef",
	# 				"14"=>"5cbd31b7c445af0004739bf0"}
	
	#desarrollo es true y produccion es false
	@@status_of_work = false

	CONTENT_SERVER_DOMAIN_NAME = 'fierro.ing.puc.cl'
	CONTENT_SERVER_FTP_LOGIN = 'grupo4'
	CONTENT_SERVER_FTP_PASSWORD = 'p6FByxRf5QYbrDC80'
	CONTENT_SERVER_FTP_PORT = 22

	def start

	end

	def solicitar_inventario(grupo_id)

		# Para ver e inventario de un grupo, debes indicar el id del grupo
		# Ejemplo: solicitar_inventario(13)

		inventario_grupo = HTTParty.get("http://tuerca#{grupo_id}.ing.puc.cl/inventories")
		if @@print_valores
			puts "\nInventario de Grupo " + grupo_id.to_s + ": \n" + inventario_grupo.to_s + "\n"
		end
		return inventario_grupo
	end

	def solicitar_orden(sku, cantidad, grupo_id, order_id)
		pedido_producto = HTTParty.post("http://tuerca#{grupo_id}.ing.puc.cl/orders",
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

		case pedido_producto.code
			when 201
		    	return pedido_producto
		    when 500
		    	puts 'timeoooooout'
		    	return nil
		end
		return pedido_producto
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

	def despacho_a_recepcion

		# D Cocina
		mover_a_almacen(@@api_key, @@id_despacho, @@id_recepcion, @@materias_primas_propias, 200)
		mover_a_almacen(@@api_key, @@id_despacho, @@id_pulmon, @@materias_primas_propias, 200)
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
		puts "get inventories 1"
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
		puts "get inventories 2"

		skus_quantity.each_key do |key|
			line = {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}
			response << line
		end

		res = response.to_json
		# render plain: res, :status => 200
		return response.to_json
	end


	def cocinar(sku_a_cocinar, cantidad_a_cocinar)
		ingredientes = IngredientesAssociation.where(producto_id: sku_a_cocinar)
		puts "\nIngredientes: " + ingredientes.to_s + "\n"
		ingredientes.each do |ingrediente|
			a_mover = cantidad_a_cocinar * ingrediente.unidades_bodega
			if a_mover > 0
				movidos = mover_a_almacen_cocinar(@@api_key, @@id_recepcion, @@id_cocina, [ingrediente.ingrediente_id], a_mover)
				a_mover = a_mover - movidos
			end

			if a_mover > 0
				movidos = mover_a_almacen_cocinar(@@api_key, @@id_pulmon, @@id_cocina, [ingrediente.ingrediente_id], a_mover)
				a_mover = a_mover - movidos
			end
		
			if a_mover > 0
				movidos = mover_a_almacen_cocinar(@@api_key, @@id_despacho, @@id_cocina, [ingrediente.ingrediente_id], a_mover)
				a_mover = a_mover - movidos
			end
				
			if a_mover > 0
				return nil
			end
		end
		response = fabricar_sin_pago(@@api_key, sku_a_cocinar, cantidad_a_cocinar)
		return response
	end

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
		puts "getSkuOnStock: \n" + inventario.to_s + "\n"
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

	def pedir_producto_grupos(sku_a_pedir, cantidad_a_pedir)

		puts "\nPEDIR PRODUCTO A GRUPOS\npedir_producto_grupos(" + sku_a_pedir.to_s + ", " + cantidad_a_pedir.to_s + ")\n"

		cantidad_faltante = cantidad_a_pedir

		# Obtenemos el producto en Producto
		producto = Producto.find(sku_a_pedir)

		# Obtenemos sus grupos productores
		grupos_productores = producto.grupos

		# Para cada grupo productor, revisamos su inventario
		grupos_productores.each do |grupo|
			if cantidad_faltante == 0
				return 1
			end
			if grupo.group_id == 4
				next
			end
			puts "Grupo: " + grupo.group_id.to_s + ", URL: " + grupo.url.to_s + "\n"
			inventario_grupo = solicitar_inventario(grupo.group_id)
			inventario_grupo.each do |p_inventario|
				#puts "sku_a_pedir: " + sku_a_pedir + "\n"
				#puts "p_inventario[sku]: " + p_inventario['sku'] + "\n"
				# Si el grupo productor tiene inventario, lo pedimos
				if sku_a_pedir == p_inventario["sku"]
					puts p_inventario.to_s
					cantidad_inventario = p_inventario["total"]
					puts "Inventario: " + cantidad_inventario.to_s + "\n"

					# Si el inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante
					if cantidad_inventario >= cantidad_faltante
						puts "El inventario es mayor a la cantidad faltante, pedimos toda la cantidad faltante"
						solicitar_orden_OC(sku_a_pedir, cantidad_faltante, grupo.group_id)
						cantidad_faltante = 0

					# Si el inventario es menor a la cantidad faltante, pedimos todo el inventario
					else
						puts "El inventario es menor a la cantidad faltante, pedimos todo el inventario"
						solicitar_orden_OC(sku_a_pedir, cantidad_inventario, grupo.group_id)
						cantidad_faltante -= cantidad_inventario
					end

				end
			end
		end
		return 0
	end

	def revisar_oc
		time = Time.now
		counter = 0
		@host = "fierro.ing.puc.cl"
		@user = "grupo4"
		@password = "p6FByxRf5QYbrDC80"
		Net::SFTP.start(@host, @user, :password => @password) do |sftp|
			entries = sftp.dir.entries("/pedidos")
			entries.each do |entry|
				file_name = entry.name.to_s
				if file_name.length >= 10
					time_file = DateTime.strptime(entry.attributes.mtime.to_s,'%s')
					if time_file > (time - 5.hours)
						data_xml = sftp.download!("pedidos/#{entry.name}")
	  					data_json = Hash.from_xml(data_xml).to_json
	  					data_json = JSON.parse data_json
	  					order_id = data_json["order"]['id']
	  					orden_compra = obtener_oc(order_id)
	  					if orden_compra[0]["estado"] == "creada"
	  						if orden_compra[0]["canal"] == "ftp"
	  							aceptar_o_rechazar_oc_producto_final(orden_compra[0])
	  						end
	  					end
					end
					
  			end
			 end
		end
	end

	def nueva_oc(cliente, proveedor, sku, fechaEntrega, cantidad, materia_prima, nro_grupo)
		time = Time.now.tomorrow.to_date
		precio = Producto.find(sku).precio_venta
		if materia_prima
			orden_creada = crear_oc(cliente, proveedor, sku, 1568039052000, cantidad, "10", 'b2b', "http://tuerca4.ing.puc.cl/documents/{_id}/notification")
		else
			orden_creada = crear_oc(cliente, proveedor, sku, 1568039052000, cantidad, "10", 'b2b', "http://tuerca4.ing.puc.cl/documents/{_id}/notification")
		end
		respuesta = solicitar_orden(orden_creada['sku'], orden_creada['cantidad'], nro_grupo, orden_creada['_id'])
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
				if @fecha_entrega > respuesta_cocina
					crear_documento_oc(orden_compra)
					aceptar_oc(@order_id)
					return ["aceptada", 0]
				else
					rechazar_oc(@order_id, "No podemos complir con los plazos entregados")
					return ["rechazada","No podemos complir con los plazos entregados"]
				end
			else
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

