require 'httparty'
require 'json'

class InventoryWorker < InventoriesController
	include getInventories
	include Sidekiq::Worker
	# sidekiq_options retry: false


	def perform
		
		puts "\nInventory worker checkeando inventario\n"

		pedidos = Hash.new

		inventario = getSkuOnStock()
		#[{"almacenId" => almacen, "sku" => sku, "cantidad" => quantity, "nombre" => product_name}, {...}, {...},.....]
		inventario_total = getInventories()
		# {"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}

		p_minimos = Producto.where.not(stock_minimo: 0) # selecciono los que tienen stock minimo
		p_minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo.to_i
			
			producto_encontrado = false

			inventario_total.each do |producto_total|
				bodega = producto_total["almacenId"]
				sku = producto_total["sku"]
				quantity = producto_total["quantity"].to_i
				
				cantidad_a_pedir = 0

				if p_referencia.sku == sku && quantity < stock_minimo
					producto_encontrado = true
					cantidad_a_pedir = stock_minimo - quantity

					#si es masago
					if sku.to_i == 1013
						pedir(1013, cantidad_a_pedir)
						break #cambio a revisar al siguiente producto de p_minimos
					end
					
					#si no es masago
					ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
					ingredientes.each do |ingrediente|
						
						# Buscar que los ingredientes esten en bodega. ahora si uso inventario
						# si el ingrediente esta en bodega, mover a despacho, sleep(10) y mandar a cocinar.
						# mover_producto_entre_almacenes(sku, @@id_despacho)
						# ver si puedo agregar el pedido a cocinar al hash pedidos.
						# else pedir ingrediente
					
					end


				end
			end
		end
	end
end