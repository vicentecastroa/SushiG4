module ReviewHelper
    include ApplicationHelper
	include ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper

	def cocinar(sku_a_cocinar, cantidad_a_cocinar)

		if @@debug_mode; puts "\nCOCINAR\n" end
		if @@debug_mode; puts "SKU a cocinar: #{sku_a_cocinar}, Cantidad: #{cantidad_a_cocinar}\n" end

		ingredientes = IngredientesAssociation.where(producto_id: sku_a_cocinar)

		numero_ingredientes = ingredientes.length
		lista_ingredientes = []

		if @@debug_mode; puts "Este producto necesita #{numero_ingredientes} ingredientes\n" end

		contador_ingredientes = 0

		if @@debug_mode; puts "Checkeamos disponibilidad de ingredientes\n" end
		if @@debug_mode; puts ingredientes end
		ingredientes.each do |ingrediente|
			if @@debug_mode; puts ingrediente end
			cantidad_ingrediente = getInventoriesOne(ingrediente.ingrediente_id)
			cantidad_necesaria = cantidad_a_cocinar * ingrediente.unidades_bodega
			if @@debug_mode; puts "Necesitamos #{cantidad_necesaria} unidades del sku #{ingrediente.ingrediente_id}. Tenemos #{cantidad_ingrediente["cantidad"]} unidades\n" end
			if cantidad_ingrediente["cantidad"]  < cantidad_necesaria
				if @@debug_mode; puts "Ingrediente no disponible" end
				return false
			end
			if @@debug_mode; puts "Ingrediente disponible" end
		end

		ingredientes.each do |ingrediente|
			
			a_mover = cantidad_a_cocinar * ingrediente.unidades_bodega
			if @@debug_mode; puts "Moviendo #{a_mover} unidades del sku #{ingrediente.ingrediente_id} a la Cocina\n" end
			movidos = 0
			almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon, @@id_despacho]
			
			almacenes.each do |almacen|
				if a_mover > 0
					movidos = mover_a_almacen(almacen, @@id_cocina, [ingrediente.ingrediente_id], a_mover)
					a_mover = a_mover - movidos
					if movidos > 0
						if @@debug_mode; puts "Movimos #{movidos} unidades del sku #{ingrediente.ingrediente_id} a la Cocina. Faltan #{a_mover} por mover\n" end
					end
				end
			end

		end
		response = fabricar_sin_pago(sku_a_cocinar, cantidad_a_cocinar)

		respuesta = response["disponible"]
		if respuesta
			if @@debug_mode; puts response end
			return response["disponible"]
		end
		return nil

	end

	def revisar_cocina
		if @@debug_mode; puts "--------- ENTRO A REVISAR_COCINA --------" end
		@documents = Document.all
		@documents.each do |document|
			sku = document["sku"]
			cantidad = document["cantidad"]
			order_id = document["order_id"]

			# review                    
			values = obtener_skus_con_stock(@@id_cocina)
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