require 'httparty'
require 'hmac-sha1'
require 'json'


class OrdersController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:create]

	def show
	end

	def index
		create
	end

	def create

		@group = request.headers['group']
		@order_id = params["oc"]
		@orden_compra = obtener_oc(@order_id)
		@urlNotificacion = @orden_compra[0]["urlNotificacion"]
		@sku = params["sku"]
		@cantidad = params["cantidad"]
		@almacenId = params["almacenId"]

		
		puts "Request POST"
		puts "Grupo: " + @group.to_s
		puts "Solicita SKU: " + @sku
		puts "Por una cantidad de: " + @cantidad.to_s
		puts "Entregar en el almacen: " + @almacenId
		puts "ID Orden de Compra: " + @order_id
		puts "URL Notificacion: " + @urlNotificacion


		#Si alguno de los parametros necesarios no viene responder con error 400
		 if @cantidad.blank? || @group.blank? || @sku.blank? || @almacenId.blank? || @order_id.blank?
		 	res = "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"
		 	render plain: res, :status => 400
		 	return res
		

		# ACEPTAR O RECHAZAR MANDAR MATERIAS PRIMAS A OTRO GRUPO
		#Si el sku es de largo 4
		 elsif (@sku.length == 4)
			@skus_to_sell = StockAvailableToSell
			@skus_on_stock = getSkuOnStock
			#si el sku es de los asignados a nosotros
			if (@@nuestros_productos.include? @sku)

				for product in @skus_to_sell
					#si el sku esta bajo nuestro stock minimo: RECHAZAR
					if product["sku"] == @sku && product["cantidad"] == 0
						#rechazar la OC con la API del profesor
						rechazar_oc(@order_id,"rechazada por frescos")
						#notificar rechazo al endpoint del grupo
						notificar(@urlNotificacion,"reject")
						#responder la request al grupo con status 404
						res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
						render plain: res, :status => 404
						return res
					
					#si tenemos sobre el stock minimo pero no suficiente para entregar lo que piden: RECHAZAR
					elsif product["sku"] == @sku && product["cantidad"] > 0 && product["cantidad"] < @cantidad 
						#rechazar la OC con la API del profesor
						rechazar_oc(@order_id,"rechazada por frescos")
						#notificar rechazo al endpoint del grupo
						notificar(@urlNotificacion,"reject")
						#responder la request al grupo con status 404
						res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
						render plain: res, :status => 404
						return res

					#si tenemos suficiente stock como para entregar y quedar con stock minimo: ACEPTAR
					elsif product["sku"] == @sku && product["cantidad"] > 0 && product["cantidad"] > @cantidad
						#aceptar la OC en la API del profesor
						aceptar_oc(@order_id)
						#notificar al endpoint del grupo oc aceptada
						notificar(@urlNotificacion,"accept")

						#GESTIONAR ENVIO
						#primero: mover la cantidad del sku a nuestro almacen despacho
						@count = @cantidad
						for skuOnStock in @skus_on_stock
							if skuOnStock["sku"] == @sku
								if skuOnStock["cantidad"] < @count
									@count = @count - skuOnStock["cantidad"]
									mover_a_almacen(@@api_key, skuOnStock["almacenId"], @@id_despacho, [@sku], skuOnStock["cantidad"])
								else
									mover_a_almacen(@@api_key, skuOnStock["almacenId"], @@id_despacho, [@sku], @count)
									@count = 0
						#segundo: mover desde despacho a la bodega del otro grupo
						lista_id_productos = get_products_from_almacenes(@@api_key, @id_despacho, @sku)
						for item in lista_id_productos
							productoId = item["_id"]
							mover_producto_entre_bodegas(@@api_key, productoId, @almacenId, @order_id, 1)
							
						#responder la request al grupo con status 201
						res = {
							"sku": @sku,
							"cantidad": @cantidad,
							"almacenId": @almacenId,
							"grupoProveedor": 4,
							"aceptado": true,
							"despachado": true
						}.to_json
						render json: res, :status => 201
						return res

					end
				end

			#si el sku es de largo 4 pero no es de los asignados a nosotros RECHAZAR
			unless (@@nuestros_productos.include? @sku)
				#rechazar la OC con la API del profesor
				rechazar_oc(@order_id,"rechazada por frescos")
				#notificar rechazo al endpoint del grupo
				notificar(@urlNotificacion,"reject")
				#responder la request al grupo con status 404
				res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
				render plain: res, :status => 404
				return res
			end
		
		#ACEPTAR O RECHAZAR MANDAR A PRODUCIR PRODUCTOS FINALES
		#si el sku es de largo 5 significa que es un producto final
		#elsif (@sku.length == 5)
			#if #ver si tenemos los ingredientes para hacerlo
				#FALTA HACER EL FLUJO
			#else #rechazar
				#rechazar_oc(@order_id,"rechazado porque no tenemos los ingredientes")
				#notificar(@urlNotificacion,"reject")
			#end
		end


	end

	def destroy
	end

	def update
	end


end
