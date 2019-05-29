require 'httparty'
require 'hmac-sha1'
require 'json'


class OrdersController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:create]

	def show
	end

	def index
		#create
	end

	def create
		@group = request.headers['group']
		@order_id = params["oc"]
		@orden_compra = obtener_oc(@order_id)
		@urlNotificacion = @orden_compra[0]["urlNotificacion"]
		@sku = params["sku"]
		@cantidad = params["cantidad"]
		@almacenId = params["almacenId"]

		#Si alguno de los parametros necesarios no viene responder con error 400
		if @cantidad.blank? || @group.blank? || @sku.blank? || @almacenId.blank? || @order_id.blank? || @cantidad > 80
			res = {"error": "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"}
			render json: res, :status => 400
			#return res
		end

		# ACEPTAR O RECHAZAR MANDAR MATERIAS PRIMAS A OTRO GRUPO
		
		# Materia prima
		if (@sku.length == 4)

			skus_to_sell = JSON.parse(StockAvailableToSellAll())
			skus_on_stock = getSkuOnStock()
			#puts skus_on_stock.class

			# Si el Sku nos corresponde
			if (@@nuestros_productos.include? @sku)
				skus_to_sell.each do |producto|

					if producto["sku"] == @sku
						#si el sku esta bajo nuestro stock minimo o nos piden mas de lo que podemos dar: RECHAZAR
						if producto["total"] <= 0 || @cantidad >= producto["total"]
							
							#rechazar la OC con la API del profesor
							rechazar_oc(@order_id,"rechazada por frescos")
							#notificar rechazo al endpoint del grupo
							if @urlNotificacion.length > 5
								notificar(@urlNotificacion,"reject")
							end
							#responder la request al grupo con status 404
							res = {"error": "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"}
							render json: res, :status => 404
							#return res

						#si tenemos suficiente stock como para entregar y quedar con stock minimo: ACEPTAR
						elsif producto["total"] > 0 && producto["total"] > @cantidad
							#NOTIFICAR
							aceptar_oc(@order_id)
							if @urlNotificacion.length > 5
								notificar(@urlNotificacion,"accept")
							end

							#GESTIONAR ENVIO
							# Mover la cantidad del sku a nuestro almacen despacho
							count = @cantidad
							moved = 0
							skus_on_stock.each do |sku_stock|
								if sku_stock["sku"] == @sku && count > 0
									if sku_stock["cantidad"] < count
										moved = mover_a_almacen(@@api_key, sku_stock["almacenId"], @@id_despacho, [@sku], sku_stock["cantidad"])
										count -= moved
									else
										moved = mover_a_almacen(@@api_key, sku_stock["almacenId"], @@id_despacho, [@sku], count)
										count -= moved
									end
								end
							end

							# Si pude mover todo a despacho
							if count == 0
								puts "moviendo a bodega del grupo"
								# Mover desde despacho a la bodega del otro grupo
								lista_id_productos = get_products_from_almacenes(@@api_key, @@id_despacho, @sku)
								contador = 0
								for item in lista_id_productos
									productoId = item["_id"]
									despachado = despachar_producto(@@api_key, productoId, @order_id, "frescos", 1)
									contador += 1
									break if contador == @cantidad
								end
								
								res = {
										"sku": @sku,
										"cantidad": @cantidad,
										"almacenId": @almacenId,
										"grupoProveedor": 4,
										"aceptado": true,
										"despachado": true
									}.to_json
								render json: res, :status => 201
							else
								res = {"error": "No se pudo realizar el envio por problemas internos."}
								render json: res, :status => 404
							end
						end 
					end
				end

			# Si no lo producimos nosotros
			else
				res = {"error": "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"}
				#rechazar la OC con la API del profesor
				rechazar_oc(@order_id,"rechazada por frescos")
				#notificar rechazo al endpoint del grupo
				if @urlNotificacion.length > 5
					notificar(@urlNotificacion,"reject")
				end
				render json: res, :status => 404
				#return res
			end
		
		# PRODUCTO FINAL
		elsif (@sku.length == 5)
			orden_compra = obtener_oc(@order_id)
			if orden_compra[0]["estado"] == "creada"
				respuesta_oc = aceptar_o_rechazar_oc_producto_final(orden_compra[0])
				if respuesta_oc[0] == "aceptada"
					res = {
						"sku": @sku,
						"cantidad": @cantidad,
						"almacenId": @almacenId,
						"grupoProveedor": 4,
						"aceptado": true,
						"despachado": false
					}.to_json
					render json: res, :status => 201
					return res
				elsif respuesta_oc[0] == "rechazada"
					notificar(@urlNotificacion,"reject")
					res = {"error": respuesta_oc[1]}
					render json: res, :status => 404
				else
					notificar(@urlNotificacion,"reject")
					res = {"error": "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"}
					render json: res, :status => 404
				end
			end
		end
	end
end
