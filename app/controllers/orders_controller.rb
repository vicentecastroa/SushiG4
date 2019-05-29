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
		#@orden_compra = obtener_oc(@order_id)
		#@urlNotificacion = @orden_compra[0]["urlNotificacion"]
		@sku = params["sku"]
		@cantidad = params["cantidad"]
		@almacenId = params["almacenId"]
		
		# puts "Request POST"
		# puts "Grupo: " + @group.to_s
		# puts "Solicita SKU: " + @sku
		# puts "Por una cantidad de: " + @cantidad.to_s
		# puts "Entregar en el almacen: " + @almacenId
		# puts "ID Orden de Compra: " + @order_id
		#puts "URL Notificacion: " + @urlNotificacion

		#Si alguno de los parametros necesarios no viene responder con error 400
		if @cantidad.blank? || @group.blank? || @sku.blank? || @almacenId.blank? || @order_id.blank?
			res = "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"
			render plain: res, :status => 400
			return res
		end

		# ACEPTAR O RECHAZAR MANDAR MATERIAS PRIMAS A OTRO GRUPO
		
		# Materia prima
		if (@sku.length == 4)

			skus_to_sell = JSON.parse(StockAvailableToSell())
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
							notificar(@urlNotificacion,"reject")
							#responder la request al grupo con status 404
							res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
							render plain: res, :status => 404
							#return res

						#si tenemos suficiente stock como para entregar y quedar con stock minimo: ACEPTAR
						elsif producto["total"] > 0 && producto["total"] > @cantidad

							#GESTIONAR ENVIO
							# Mover la cantidad del sku a nuestro almacen despacho
							count = @cantidad
							moved = 0
							skus_on_stock.each do |sku_stock|
								if sku_stock["sku"] == @sku && count > 0
									puts sku_stock
									if sku_stock["cantidad"] < count
										moved = mover_a_almacen(@@api_key, sku_stock["almacenId"], @@id_despacho, @sku, sku_stock["cantidad"])
										count -= moved
									else
										moved = mover_a_almacen(@@api_key, sku_stock["almacenId"], @@id_despacho, @sku, to_move)
										count -= moved
									end
								end
							end

							# Si pude mover todo a despacho
							if count = 0
								# Mover desde despacho a la bodega del otro grupo
								lista_id_productos = get_products_from_almacenes(@@api_key, @id_despacho, @sku)
								for item in lista_id_productos
									productoId = item["_id"]
									mover_producto_entre_bodegas(@@api_key, productoId, @almacenId, @order_id, 1)
								
								# Notificar
								#aceptar la OC en la API del profesor
								aceptar_oc(@order_id)
								#notificar al endpoint del grupo oc aceptada
								notificar(@urlNotificacion,"accept")

								# Response
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
								res = "No se pudo realizar el envio por problemas internos."
								render plain: res, :status => 404
							end
						end 
					end
				end

			# Si no lo producimos nosotros
			else
				res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
				puts res
				render plain: res, :status => 404
				#return res
			end		
		# Producto final		
		elsif (@sku.length == 5)
			puts "producto final"
		end
	end

	def destroy
	end

	def update
	end


end
