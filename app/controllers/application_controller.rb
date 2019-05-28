require 'net/ftp'
require 'ftp_helper'
require 'application_helper'
require 'active_support/core_ext/hash'
require 'date'

class ApplicationController < ActionController::Base
	include ApplicationHelper
	include FtpHelper
	include OcHelper
	
	@@api_key = 'o5bQnMbk@:BxrE'
	@@id_recepcion = '5cc7b139a823b10004d8e6df'
	@@id_despacho = '5cc7b139a823b10004d8e6e0'
	@@id_pulmon = '5cc7b139a823b10004d8e6e3'
	@@id_cocina = '5cc7b139a823b10004d8e6e4'

	@@id_desarrollo = '5cbd31b7c445af0004739be6'
	@@id_desarrollo_14 = '5cbd31b7c445af0004739bf0'
	@@id_produccion = '5cc66e378820160004a4c3bf'

	
	#desarrollo es true y produccion es false
	@@status_of_work = false

	CONTENT_SERVER_DOMAIN_NAME = 'fierro.ing.puc.cl'
	CONTENT_SERVER_FTP_LOGIN = 'grupo4'
	CONTENT_SERVER_FTP_PASSWORD = 'p6FByxRf5QYbrDC80'
	CONTENT_SERVER_FTP_PORT = 22

	def start
		revisar_oc
		#orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1568039052000, "10", "10", "b2b", "https://tuerca4.ing.puc.cl/document/{_id}/notification")
		#nueva_oc
		#orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1558039052000, "10", "10", "b2b")
		#obtener_oc(orden_creada['_id'])
		#aceptar_oc('1557965482159')
		#rechazar_oc(orden_creada["_id"], "RECHAZADO POR X RAZON")
		#anular_oc(orden_creada["_id"], "MUCHOS PRODUCTOS")
		#verificar_conexion(CONTENT_SERVER_DOMAIN_NAME, CONTENT_SERVER_FTP_LOGIN, CONTENT_SERVER_FTP_PASSWORD, CONTENT_SERVER_FTP_PORT)
	end

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
					if time_file > (time - 10.hours)
						data_xml = sftp.download!("pedidos/#{entry.name}")
	  					data_json = Hash.from_xml(data_xml).to_json
	  					data_json = JSON.parse data_json
	  					order_id = data_json["order"]['id']
	  					orden_compra = obtener_oc(order_id)
	  					aceptar_o_rechazar(orden_compra[0])
					end
					
  				end
			end
		end
	end

	def nueva_oc
		orden_creada = crear_oc(@@id_desarrollo, @@id_desarrollo_14, "30001", 1568039052000, "10", "10", "b2b", "https://tuerca4.ing.puc.cl/documents/{_id}/notification")
		order_id = orden_creada['_id']
		puts order_id
		Document.create! do |document|
			document.all = order_id,
			document.cliente = orden_creada['cliente'],
			document.proveedor = orden_creada['proveedor'],
			document.sku = orden_creada['sku'],
			document.fechaEntrega = orden_creada['fechaEntrega'],
			document.cantidad = orden_creada['cantidad'],
			document.cantidadDespachada = orden_creada['cantidadDespachada'],
			document.precioUnitario = orden_creada['precioUnitario'],
			document.canal = orden_creada['canal'],
			document.estado = orden_creada['estado'],
			document.notas = orden_creada['notas'],
			document.rechazo = orden_creada['rechazo'], 
			document.anulacion = orden_creada['anulacion'],
			document.order_id = order_id,
			document.urlNotificacion = orden_creada['urlNotificacion']
		end
		#anular_oc(orden_creada["_id"], "MUCHOS PRODUCTOS")
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

	def aceptar_o_rechazar(orden_compra)
		@sku = orden_compra["sku"]
		@cantidad = orden_compra["cantidad"]
		@proveedor = orden_compra["proveedor"]
		@fecha_entrega = orden_compra["fechaEntrega"]
		@estado = orden_compra["estado"]
	# 	elsif (@sku.length == 4)
	# 		@skus_to_sell = StockAvailableToSell
	# 		@skus_on_stock = getSkuOnStock
	# 		#si el sku es de los asignados a nosotros
	# 		if (@@nuestros_productos.include? @sku)

	# 		#si el sku es de largo 4 pero no es de los asignados a nosotros RECHAZAR
	# 		unless (@@nuestros_productos.include? @sku)
	# 			#rechazar la OC con la API del profesor
	# 			rechazar_oc(@order_id,"rechazada por frescos")
	# 			#notificar rechazo al endpoint del grupo
	# 			notificar(@urlNotificacion,"reject")
	# 			#responder la request al grupo con status 404
	# 			res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
	# 			render plain: res, :status => 404
	# 			return res
	# 		end
		
	# 	#ACEPTAR O RECHAZAR MANDAR A PRODUCIR PRODUCTOS FINALES
	# 	#si el sku es de largo 5 significa que es un producto final
	# 	#elsif (@sku.length == 5)
	# 		#if #ver si tenemos los ingredientes para hacerlo
	# 			#FALTA HACER EL FLUJO
	# 		#else #rechazar
	# 			#rechazar_oc(@order_id,"rechazado porque no tenemos los ingredientes")
	# 			#notificar(@urlNotificacion,"reject")
	# 		#end
	# 	end
	end

end

