module ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper
	# Requests directas a la API OC del profesor
	def obtener_oc(id)
		puts "----- Entro a obtener_oc en api_oc_helper -----"
		orden_compra = HTTParty.get("https://integracion-2019-#{@@estado}.herokuapp.com/oc/obtener/#{id}", 
		  params:{
		  	"id": id,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA OBTENIDA"
			puts JSON.pretty_generate(orden_compra)
		end
		return orden_compra
	end

	def crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		puts "----- Entro a crear_oc en api_oc_helper -----"
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

	def anular_oc(id, anulacion)
		puts "----- Entro a anular_oc en api_oc_helper -----"
		orden_compra_anulada = HTTParty.delete("https://integracion-2019-#{@@estado}.herokuapp.com/oc/anular/#{id}", 
		  body:{
		  	"id": id,
		  	"anulacion": anulacion,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA ANULADA"
			puts JSON.pretty_generate(orden_compra_anulada)
		end
		return orden_compra_anulada
	end

	def aceptar_oc(id)
		puts "----- Entro a aceptar_oc en api_oc_helper -----"
		orden_compra_recepcionada = HTTParty.post("https://integracion-2019-#{@@estado}.herokuapp.com/oc/recepcionar/#{id}", 
		  body:{
		  	"id": id,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA ACEPTADA"
			puts JSON.pretty_generate(orden_compra_recepcionada)
		end
		return orden_compra_recepcionada
	end

	def rechazar_oc(id, rechazo)
		puts "----- Entro a rechazar_oc en api_oc_helper -----"
		orden_compra_rechazada = HTTParty.post("https://integracion-2019-#{@@estado}.herokuapp.com/oc/rechazar/#{id}", 
		  body:{
		  	"id": id,
		  	"rechazo": rechazo,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA RECHAZADA"
			puts JSON.pretty_generate(orden_compra_rechazada)
		end
		return orden_compra_rechazada
	end

	# Funciones que trabajan con OCs
	def revisar_oc
		puts "----- Entro a revisar_oc en api_oc_helper -----"
		ordenes = getOCfromServer(3)
		ordenes.each do |orden_compra|
			if orden_compra[0]["estado"] == "creada"
				if orden_compra[0]["canal"] == "ftp"
					aceptar_o_rechazar_oc_producto_final(orden_compra[0])
				end
			end
		end
	end

	def obtener_oc_aceptadas
		puts "----- Entro a robtener_oc_aceptada en api_oc_helper -----"
		ordenes = getOCfromServer(10)
		aceptadas = []
		ordenes.each do |orden_compra|
			if orden_compra[0]["estado"] == "aceptada"
				if orden_compra[0]["canal"] == "ftp"
					aceptadas << orden_compra[0]
				end
			end
		end
		return aceptadas
	end

	def getOCfromServer(horas)
		puts "----- Entro a getOCfromServer en api_oc_helper -----"
		time = Time.now
		counter = 0
		ordenes = []
		Net::SFTP.start(@@host, @@user, :password => @@password) do |sftp|
			entries = sftp.dir.entries("/pedidos")
			entries.each do |entry|
				file_name = entry.name.to_s
				if file_name.length >= 10
					time_file = DateTime.strptime(entry.attributes.mtime.to_s,'%s')
					if time_file > (time - horas.hours)
						data_xml = sftp.download!("pedidos/#{entry.name}")
	  					data_json = Hash.from_xml(data_xml).to_json
	  					data_json = JSON.parse data_json
						order_id = data_json["order"]['id']
						orden_compra = obtener_oc(order_id)
						ordenes << orden_compra
					end
				end
			end
		end
		return ordenes
	end

	def nueva_oc(cliente, proveedor, sku, fechaEntrega, cantidad, materia_prima, nro_grupo)
		puts "----- Entro a nueva_oc en api_oc_helper -----"
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
		puts "----- Entro a notificar en api_oc_helper -----"
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
		puts "----- Entro a aceptar_o_rechazar_oc_producto_final en api_oc_helper -----"
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
					# rechazar_oc(@order_id, "No podemos complir con los plazos entregados")
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
		puts "----- Entro a crear_documento_oc en api_oc_helper -----"
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
		puts "----- Entro a borrar_todos_documentos_compra en api_oc_helper -----"
		@documents = Document.all
		@documents.each do |document|
		   document.destroy
		end
	end

	def solicitar_orden(sku, cantidad, grupo_id, order_id)
		puts "----- Entro a solicitar_orden en api_oc_helper -----"
		puts "SOLICITAR ORDEN"
		puts "sku: #{sku}, tipo #{sku.class}"
		puts "cantidad: #{cantidad}, tipo #{cantidad.class}"
		puts "grupo_id: #{grupo_id}, tipo #{grupo_id.class}"
		puts "order_id: #{order_id}, tipo #{order_id.class}"
		
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

	def solicitar_OC(sku, cantidad, grupo_id)
		puts "----- Entro a solicitar_OC en api_oc_helper -----"
		# Primero debemos crear la OC
		# crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		cliente = @@IDs_Grupos["4"]
		proveedor = @@IDs_Grupos[grupo_id.to_s] 
		sku = sku.to_s
		fechaEntrega = "1607742000000" #12/12/2020
		cantidad = cantidad.to_i
		precioUnitario = "1"
		canal = "b2b"
		url = "https://tuerca4.ing.puc.cl/documents/{_id}/notification"
		oc_creada = crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)

		# Luego debemos solicitar el producto al grupo, incluyendo el id de la OC
		oc_id = oc_creada["_id"]
		puts "\nSe creo la ordern id: " + oc_creada["_id"] + "\n"
		puts "Para el producto sku: #{sku}\n"

		# Para solicitar producto a un grupo, debes indicar el sku a pedir, la cantidad a pedir y el id del grupo
		# Ejemplo: solicitar_orden("1001", 10, 13)

		codigo = 0
		begin
			pedido_producto = HTTParty.post("http://tuerca#{grupo_id}.ing.puc.cl/orders",
				headers:{
					"group": "4",
					"Content-Type": "application/json"
				},
				body:{
					"sku": sku,
					"cantidad": cantidad.to_i,
					"almacenId": @@id_recepcion,
					"oc": oc_id
				}.to_json,
				timeout: 60)
		rescue Net::OpenTimeout
			codigo = 601
		rescue Timeout::Error
			codigo = 602
		rescue Net::ReadTimeout
			codigo = 603
		else	
			codigo = pedido_producto.code
		end
		puts "Codigo respuesta request: #{codigo}\n"
		# if true
		# 	puts "\nSolicitar Orden\n"
		# puts JSON.pretty_generate(pedido_producto)
		# 	# puts pedido_producto.to_s
		# end
		
		if codigo >= 200 && codigo < 300
			response = true	
			if pedido_producto["aceptado"]
				puts "Nos han aceptado el pedido! #{pedido_producto["aceptado"]}\n"
			else
				puts "Nos han aceptado el pedido\n"
			end
		elsif codigo > 600
			response = false
			puts "Rechazado por Timeout\n"
		else
			response = false
			puts "Nos han rechazado el pedido\n"
		end

		return response
		# if pedido_producto["aceptado"]
		# 	return true
		# end
		# return false
	end

end
