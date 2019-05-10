require 'httparty'
require 'json'

class InventoryWorker < InventoriesController
	include getInventories
	include Sidekiq::Worker
	sidekiq_options retry: false

	def check_producers(producto)

		n_grupos = producto.grupos.length
		indices = (0...n_grupos).to_a
		indices.shuffle()
		sku = producto.sku
		
		for i in indices
			request = pedir(producto.grupos[i])
			if request == true
				break
			end
		end
	end

	def mandar_a_cocinar(lista_ingredientes, producto_final)
	end


	def perform
		
		puts "\nInventory worker checkeando inventario\n"

		request = get_inventories()
		p_minimos = Producto.where.not(stock_minimo: 0) # selecciono los que tienen stock minimo
		p_minimos.each do |p_referencia|
			stock_minimo = p_referencia.stock_minimo
			
			request.each do |bodega|
			
				bodega.each do |producto|
			
					if producto["sku"] == p_referencia.sku and producto["cantidad"] < stock_minimo
			
						if producto["sku"].to_i == 1013
							pedir_producto(1013, 1)
						else
							ingredientes = IngredientesAssociation.where(producto_id: p_referencia.sku)
							ingredientes.each do |ingrediente|
								pedir_producto(ingrediente.sku, 1)
							end
						end

					end
			
				end
			end
		end
	end
end