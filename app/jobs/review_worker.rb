require 'httparty'
require 'json'
require 'net/ftp'
require 'date'
require 'active_support/core_ext/hash'
require 'oc_helper'
require 'application_helper'
require 'orders_helper'

class ReviewWorker < ApplicationJob
	include OcHelper
	queue_as :default

	def perform
		revisar_oc
		revisar_cocina_worker
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
					if time_file > (time - 1.hours)
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

	def cocinar(sku_a_cocinar, cantidad_a_cocinar)
		ingredientes = IngredientesAssociation.where(producto_id: sku_a_cocinar)
		ingredientes.each do |ingrediente|
			a_mover = cantidad_a_cocinar * ingrediente.unidades_bodega
			puts 'a mover'
			puts a_mover
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
		return response["disponible"]
	end

	def revisar_cocina
		@documents = Document.all
		@documents.each do |document|
			sku = document["sku"]
			cantidad = document["cantidad"]
			order_id = document["order_id"]
			values = obtener_skus_con_stock(@@api_key ,@@id_cocina)
			values.each do |value|
				if value["_id"].to_s == sku.to_s
					if value["total"] >= cantidad 
						despacho_todos(@@id_cocina, sku, cantidad, order_id)
						document.destroy
					end
				end
			end
		end
	end
end