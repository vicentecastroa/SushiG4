require 'httparty'
require 'json'
require 'groups_module'
# require "#{Rails.root}/app/controllers/concerns/app_controller_module"


class InventoryWorker < ApplicationJob

	# include AppController
	include GroupsModule
	# include Sidekiq::Worker
	# sidekiq_options retry: false

	queue_as :default

	@@nuestros_productos = ["1004", "1005", "1006", "1009", "1014", "1015"]
	@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]
	

	def have_producto(sku, cantidad_minima)
		inventario_total = getInventories()

		for producto in inventario_total
			if producto["sku"] == sku && producto["cantidad"].to_i < cantidad_minima
				return 0
			elsif producto["sku"] == sku && producto["cantidad"].to_i >= cantidad_minima
				return 1
			else
				return 2
			end
		end
	end

	def mover_ingrediente_a_despacho(sku, stock_minimo)
		inventario =  getSkuOnStock()
		stock_en_almacen = Hash.new
		for producto in inventario
			if producto["sku"] == sku
				almacen = producto["almacenId"]
				cantidad = producto["cantidad"]
				stock_en_almacen[almacen] = producto
			end
		end
		unidades_por_mover = stock_minimo
		if stock_en_almacen[@@id_despacho]["cantidad"] >= stock_minimo
			return 1
		else 
			unidades_por_mover -= stock_en_almacen[@@id_despacho]["cantidad"]
		end

		if stock_en_almacen[@@id_recepcion]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_recepcion, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_recepcion, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_recepcion]["cantidad"]
		end

		if stock_en_almacen[@@id_pulmon]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_pulmon, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_pulmon, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_pulmon]["cantidad"]
		end

		if stock_en_almacen[@@id_cocina]["cantidad"] >= unidades_por_mover
			mover_a_almacen(@@api_key, @@id_cocina, @@id_despacho, [sku], unidades_por_mover)
		else 
			mover_a_almacen(@@api_key, @@id_cocina, @@id_despacho, [sku], 0)
			unidades_por_mover -= stock_en_almacen[@@id_cocina]["cantidad"]
		end
		
		return 1
	end

	def perform
		
		puts "\nInventory worker checkeando inventario\n"

		pedidos = Hash.new
		

		inventario = getSkuOnStock()
		#[{"almacenId" => almacen, "sku" => sku, "cantidad" => quantity, "nombre" => product_name}, {...}, {...},.....]
		inventario_total = getInventories()
		# [{"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}, {}, {}]

		p_minimos = Producto.where.not(stock_minimo: 0) # selecciono los que tienen stock minimo
		p_minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo.to_i

			inventario_total.each do |producto_total| # reviso el inventario total 
				sku = producto_total["sku"]
				cantidad = producto_total["cantidad"].to_i
				
				cantidad_a_pedir = 0
				 # por cada producto del inventario minimo, comparo y veo si encuentro
				 # el producto en el invetario total
				if p_referencia.sku == sku && cantidad < stock_minimo
					cantidad_faltante = stock_minimo - cantidad

					lotes_faltantes_p_referencia = (cantidad_faltante.to_f / p_referencia.lote_produccion).ceil
					
					#si es masago
					if sku.to_i == 1013
						get_producto_grupo(1013, lotes_faltantes_p_referencia)
						break #cambio a revisar al siguiente producto de p_minimos
					else
					#si no es masago
						ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
						ingredientes.each do |ingrediente|

							cantidad_lote_ingrediente = ingrediente.cantidad_lote
							lote_produccion_ingrediente = Produto.find(ingrediente.ingrediente_id).lote_produccion
							un_a_pedir_ingrediente = (lotes_faltantes_p_referencia) * (cantidad_lote_ingrediente)
							# Revisar si tenemos stock del ingrediente en cualquier almacen
							
							lotes_a_pedir_ingrediente = (un_a_pedir_ingrediente.to_f / lote_produccion_ingrediente).ceil
							if have_producto(ingrediente.ingrediente_id, un_a_pedir_ingrediente) == 1
								p = mover_ingrediente_a_despacho(ingrediente.ingrediente_id, un_a_pedir_ingrediente)
								
								
							elsif 	have_producto(ingrediente.ingrediente_id, un_a_pedir_ingrediente) == 0								
								if @@nuestros_productos.include? ingrediente.ingrediente_id 
									fabricar_sin_pago(@@api_key, ingrediente.ingrediente_id, lotes_a_pedir_ingrediente)
								else
									get_producto_grupo(ingrediente.ingrediente_id, lotes_a_pedir_ingrediente)
								end
							else
								puts "no existe"
							end
						end

						fabricar_sin_pago(@@api_key, p_referencia.sku, lotes_faltantes_p_referencia)

					end
				end
			end
		end
	end
end