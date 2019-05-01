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
		@sku = params["sku"]
		@cantidad = params["cantidad"]
		@almacenId = params["almacenId"]
		
		puts "Request POST"
		puts "Grupo: " + @group
		puts "Solicita SKU: " + @sku
		puts "Por una cantidad de: " + @cantidad
		puts "Entregar en el almacen: " + @almacenId

		#Si alguna de los parametros necesarios no viene responder con error 400
		if @cantidad.blank? || @group.blank? || @sku.blank? || @almacenId.blank?
			res = "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"
			render plain: res, :status => 400
			return res

		elsif @sku == "1001" || @sku == "1005" || @sku == "1014"
			skus = (obtener_skus_con_stock(@@api_key, @@id_despacho)).to_a
			no_entrego_solucion = true
			for my_sku in skus
				if my_sku["_id"] == @sku
					if my_sku["total"].to_i > @cantidad.to_i
						productos_a_mover = (get_products_from_almacenes_limit_primeros(@@api_key, @@id_despacho, @sku, @cantidad)).to_a
						productos_a_mover.each do |prod|
							estado = mover_producto_entre_bodegas(@@api_key, prod["_id"], @almacenId, "estado", "10")
							if estado["despachado"] == true
								@despachado = true
							else
								@despachado = false
							end
						end
						no_entrego_solucion = false
						@aceptado = true
						
					else
						res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
						render plain: res, :status => 404
						no_entrego_solucion = false
						return res
					end
				else
					res = "Ha ocurrido un error, consulte nuevamente mas adelante"
					render plain: res, :status => 404
					no_entrego_solucion = false
					return res
				end
			end

			if no_entrego_solucion
				res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
				render plain: res, :status => 404
				return res
			end

			if @aceptado == true && @despachado == true
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

		else
			res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
			render plain: res, :status => 404
			return res
		
		end
	end

	def destroy
	end

	def update
	end


end
