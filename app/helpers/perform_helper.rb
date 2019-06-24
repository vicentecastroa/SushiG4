module PerformHelper
    include ApplicationHelper
	include ApiOcHelper
	include VariablesHelper
	include ApiBodegaHelper
	include GruposHelper
	include ReviewHelper

    @@factor_multiplicador = 1

	def perform_inventory
		
		if @@debug_mode; puts "\n****************************\nInventory worker checkeando inventario\n****************************\n\n" end
  
		pedidos = Hash.new

		## Obtenemos el inventario total de cada producto ##
		inventario_total = getInventoriesAll()
		# puts "Inventario Total: \n" + inventario_total.to_s
		# [{"sku" => key, "nombre" => sku_name[key], "cantidad" => skus_quantity[key]}, {}, {}]
		if @@debug_mode; puts "Corrio getInventories" end

		p_all = Producto.all

		## Obtenemos los productos que deban mantener un stock minimo ##
		p_minimos = getProductosMinimos()
		# puts "Productos Minimos: \n" + p_minimos.to_s

		## Para cada producto que deba mantener stock minimo, revisamos su stock ##
		p_minimos.reverse_each do |p_minimo|

			## Obtenemos el stock minimo que debe mantener el producto ##
			stock_minimo = p_minimo.stock_minimo.to_i
			stock_minimo = (stock_minimo * @@factor_multiplicador).ceil

			if @@debug_mode; puts "\n****************************\nProducto Minimo: " + p_minimo.nombre + "\n" end
			if @@debug_mode; puts"\nStock Minimo: " + stock_minimo.to_s end

			## Obtenemos el producto dentro del inventario ##
			p_minimo_inventario = getInventoriesOne(p_minimo.sku)

			## Por cada producto que deba mantener stock minimo, comparo y encuentro el producto en el inventario
			sku = p_minimo_inventario["sku"]
			cantidad = p_minimo_inventario["cantidad"].to_i

			if @@debug_mode; puts "\nCantidad Actual: " + cantidad.to_s end

			if cantidad < stock_minimo # Si la cantidad es mayor o igual al stock minimo, no hago nada


				# Calculamos la cantidad faltante de producto como la diferencia entre el stock minimo y la cantidad actual en inventario
				cantidad_faltante = stock_minimo - cantidad

				# Obtenemos el tamaño de los lotes de producción del producto
				lote_produccion = p_minimo.lote_produccion

				# Los lotes faltantes a producir seran la cantidad faltante dividida en el lote de producción del producto
				lotes_faltantes = (cantidad_faltante.to_f / lote_produccion.to_f).ceil

				# Calculamos la cantidad a fabricar del producto
				cantidad_a_producir = lotes_faltantes * lote_produccion
				total_produccion = cantidad_a_producir
				if @@debug_mode; puts "\nCantidad Faltante: " + cantidad_faltante.to_s + " -> Lotes Faltantes: " + lotes_faltantes.to_s end
				if @@debug_mode; puts "\n****************************\n\n" end
				if @@debug_mode; puts "Ingredientes: \n" end

				# Si el producto es MASAGO, lo pido a los grupos productores correspondientes
				if sku.to_i == 1013
					while cantidad_a_producir > 0 do
						orden = [cantidad_a_producir, 20].min
						nos_entregan = pedir_producto_grupos("1013", orden)
						if @@debug_mode; puts "Nos entregan #{nos_entregan} unidades" end
						cantidad_a_producir -= nos_entregan
						if @@debug_mode; puts "Hemos producido #{total_produccion-cantidad_a_producir} de #{total_produccion}\n" end
						if nos_entregan == 0
							if @@debug_mode; puts "\nNINGUN grupo tienen mas MASAGO\n" end
							break
						end
					end
				# Si el producto NO es MASAGO, debo verificar el stock de sus ingredientes antes de fabricar
				else
						
					# Obtenemos los ingredientes del producto
					ingredientes = IngredientesAssociation.where(producto_id: p_minimo.sku)

					numero_ingredientes = ingredientes.length
					lista_ingredientes = []
					# Para cada ingrediente, calculamos el stock necesario para producir el producto y pedimos en caso de no tenerlo

					contador_ingredientes = 0
					ingredientes.each do |ingrediente|
						
						lista_ingredientes << [ingrediente.ingrediente_id, ingrediente.unidades_bodega.to_i]
						
						if @@debug_mode; puts "\t ID Ingrediente: " + ingrediente.ingrediente_id + "\n" end
						
						# Obtenemos el ingrediente desde Producto
						p_ingrediente = Producto.find(ingrediente.ingrediente_id)
						
						# Obtenemos el inventario del ingrediente
						p_ingrediente_inventario = getInventoriesOne(p_ingrediente.sku)
						
						# Obtenemos la cantidad de ingrediente requerido para producir un lote de producto
						unidades_bodega = ingrediente.unidades_bodega.to_i

						# Calculamos la cantidad de unidades requeridas multiplicando las unidades bodega por los lotes faltantes de producto
						cantidad_ingrediente = unidades_bodega * lotes_faltantes

						# Si el stock actual es mayor o igual a la cantidad de ingrediente requerido, enviamos ingrediente a despacho y reponemos la misma cantidad
							

						if p_ingrediente_inventario["cantidad"].to_i >= cantidad_ingrediente
							if @@debug_mode; puts "\t ¡Tenemos UN ingrediente! \n" end
							
							contador_ingredientes += 1
							if @@debug_mode; puts "contadores: #{contador_ingredientes} / #{numero_ingredientes}\n" end
							if contador_ingredientes == numero_ingredientes
								if @@debug_mode; puts "\t ¡Tenemos TODOS LOS ingredienteS! \n" end
								if @@debug_mode; puts "Comenzamos la produccion de #{cantidad_a_producir} productos" end

								while cantidad_a_producir > 0 do
									# Enviamos ingredientes a despacho

									lista_ingredientes.each do |item|
										mover_ingrediente_a_despacho(item[0], item[1])
									end
									# Fabricamos sin costo los ingredientes enviados
									if @@debug_mode
										puts fabricar_sin_pago(p_minimo.sku, lote_produccion)
									else
										fabricar_sin_pago(p_minimo.sku, lote_produccion)
									end
									cantidad_a_producir -= lote_produccion
									cantidad_a_producir = [cantidad_a_producir, 0].max
									if @@debug_mode; puts "Hemos producido #{total_produccion-cantidad_a_producir} de #{total_produccion}\n" end

								end

							end

						# Si el stock actual es menor a la cantidad de ingrediente requerido, calculamos la cantidad faltante de ingrediente
						else
							if @@debug_mode; puts "No tenemos el ingrediente! \n" end
							cantidad_faltante_ingrediente = cantidad_ingrediente - p_ingrediente_inventario["cantidad"]

							if @@materias_primas_propias.include? ingrediente.ingrediente_id.to_s
								if @@debug_mode; puts "El ingrediente es nuestro\n" end
								# Obtenemos el tamaño de lote de producción del ingrediente
								lote_produccion_ingrediente = p_ingrediente.lote_produccion.to_i

								# Calculamos los lotes faltantes de ingrediente
								lotes_faltantes_ingrediente = (cantidad_faltante_ingrediente / lote_produccion_ingrediente).ceil

								# Definimos factor de multiplicacion de stock minimo para ingredientes propios

								# factor_ingredientes = 2
								# Calculamos la cantidad a producir del ingrediente
								# cantidad_a_producir_ingrediente = factor_ingredientes * lotes_faltantes_ingrediente * lote_produccion_ingrediente
								cantidad_a_producir_ingrediente = (@@factor_multiplicador * lotes_faltantes_ingrediente * lote_produccion_ingrediente).ceil

								# Fabricamos sin costo la cantidad a producir del ingrediente
								if @@debug_mode
									puts fabricar_sin_pago(ingrediente.ingrediente_id, cantidad_a_producir_ingrediente)
								else
									fabricar_sin_pago(ingrediente.ingrediente_id, cantidad_a_producir_ingrediente)
								end
								
								if @@debug_mode; puts "Fabricamos SIN PAGO el ingrediente: " + p_minimo.sku + ", una cantidad de " + cantidad_a_producir.to_s + "\n" end

							# Si el producto no es nuestro, lo pedimos a otro grupo
							else
								if @@debug_mode; puts "El ingrediente NO es nuestro\n" end
								while cantidad_faltante_ingrediente > 0
									orden = [cantidad_faltante_ingrediente, 20].min
									nos_entregan = pedir_producto_grupos(ingrediente.ingrediente_id, orden)
									if @@debug_mode; puts "Nos entregan #{nos_entregan} unidades" end
									cantidad_faltante_ingrediente -= nos_entregan
									
									if nos_entregan == 0
										if @@debug_mode; puts "\nNINGUN grupo tienen mas Producto X\n" end
										break
									end
								end
							end
						end
					end
				end
			end			
		end
	end

	def perform_review

		revisar_oc()
		revisar_cocina()

	end

	def perform_delivery

		if @@debug_mode; puts "----- Entro a perform_delivery en perform_helper -----" end

		# Revisar OCs aceptadas
		oc_aceptadas = obtener_oc_aceptadas()

		# Revisar inventario
		inventario_total = getInventoriesAll()

		# Para cada OC aceptada
		oc_aceptadas.each do |oc|

			# Checkeamos que su fecha de entrega no sea menor que la actual
			if oc["fechaEntrega"] <= Time.now.utc
				if @@debug_mode; puts "La fecha de entrega #{oc["fechaEntrega"]} es menor que la fecha actual #{Time.now.utc} para el producto #{oc["sku"]}" end
			   	next
			end

			# Checkeamos que la cantidad ya despachada no sea mayor o igual que la cantidad que se pide
			if (oc["cantidadDespachada"].to_i >= oc["cantidad"].to_i)
				if @@debug_mode; puts "Ya se despacharon las #{oc["cantidad"]} unidades del producto #{oc["sku"]}" end
				next
			end

			# Checkeamos si hay inventario del producto
			inventario_total.each do |inventario|
				if inventario["sku"] == oc["sku"]
					if @@debug_mode; puts "Tenemos #{inventario["cantidad"]} de #{oc["cantidad"]} del sku #{inventario["sku"]}. Faltan por despachar #{(oc["cantidad"] - oc["cantidadDespachada"])}." end
					if inventario["cantidad"].to_i >= oc["cantidad"].to_i
						productos_cocina = get_products_from_almacenes(@@id_cocina, oc["sku"])
						producto_enviado = 0
						productos_cocina.each do |producto_cocina|
							despachar = despachar_producto(producto_cocina["_id"], oc["_id"], oc["cliente"], oc["precioUnitario"])
							if despachar["despachado"] == true
								if @@debug_mode; puts "Producto enviado" end
							end
							producto_enviado += 1
							# Enviamos solo la cantidad faltante del producto
							if producto_enviado == (oc["cantidad"] - oc["cantidadDespachada"])
								break
							end
						end
						break
					else
						if @@debug_mode; puts ("No tenemos suficiente producto") end
					end
				end
			end
		end
	end



	def perform_arroz
		sku = "1101"
		ingredientes = IngredientesAssociation.where(producto_id: sku)
		numero_ingredientes = ingredientes.length
		lista_ingredientes = []
		contador_ingredientes = 0
		stock_minimo_arroz = 300

		inventario_arroz = getInventoriesOne(sku)

		if inventario_arroz["cantidad"] <= stock_minimo_arroz
			cantidad_faltante =  stock_minimo_arroz - inventario_arroz["cantidad"]
			lote_produccion = 10
			lotes_faltantes = (cantidad_faltante.to_f / lote_produccion.to_f).ceil
			cantidad_a_producir = lotes_faltantes * lote_produccion
			total_produccion = cantidad_a_producir
			ingredientes.each do |ingrediente|
				lista_ingredientes << [ingrediente.ingrediente_id, ingrediente.unidades_bodega.to_i]
				p_ingrediente = Producto.find(ingrediente.ingrediente_id)
				p_ingrediente_inventario = getInventoriesOne(p_ingrediente.sku)
				unidades_bodega = ingrediente.unidades_bodega.to_i
				cantidad_ingrediente = unidades_bodega * lotes_faltantes
				
				if p_ingrediente_inventario["cantidad"].to_i >= cantidad_ingrediente
					if @@debug_mode; puts "\t ¡AROCERO: Encontre UNO de los ingredientes! \n" end
					contador_ingredientes += 1
					if @@debug_mode; puts "contadores: #{contador_ingredientes} / #{numero_ingredientes}\n" end
					if contador_ingredientes == numero_ingredientes
						if @@debug_mode; puts "\t ¡ARROCERO: Tengo TODOS LOS ingredienteS! \n" end
						if @@debug_mode; puts "ARROCERO: voy a cocinar #{cantidad_a_producir} arroces" end

						while cantidad_a_producir > 0 do
							# Enviamos ingredientes a despacho
							lista_ingredientes.each do |item|
								mover_ingrediente_a_despacho(item[0], item[1])
							end
							# Fabricamos sin costo los ingredientes enviados
							if @@debug_mode; puts fabricar_sin_pago(sku, lote_produccion) end
							cantidad_a_producir -= lote_produccion
							cantidad_a_producir = [cantidad_a_producir, 0].max
							if @@debug_mode; puts "ARROCERO: Hice #{total_produccion-cantidad_a_producir} de #{total_produccion}\n" end
						end
					end
				end
			end
		end
	end

	def perform_pulmon
		# Revisa todo lo que haya en el pulmon y lo mueve a la bodega secreta

		# @items = Producto.all
		# for item in @items
		# 	sku = item.sku
		# 	request = get_products_from_almacenes(@@api_key, @@id_pulmon, sku)
		# 	for prod in request
		# 		prod_id = prod['_id']
		# 		response = mover_producto_entre_almacenes(prod_id, @@id_multiuso_1)
		# 	end 
		# end


		productos_pulmon = obtener_skus_con_stock(@@id_pulmon)
		almacen_a_mover = @@id_multiuso_1
		for producto in productos_pulmon
			sku = producto["_id"]
			cantidad = producto["total"].to_i
			movidos = 0
			movidos_a_multiuso = 0
			if @@debug_mode; puts "Moviendo #{cantidad} unidades de #{sku} a #{nombre_almacen(almacen_a_mover)}" end
			while cantidad > movidos
				movidos = mover_a_almacen(@@id_pulmon, almacen_a_mover, [sku], cantidad)
				movidos_a_multiuso += movidos
				if movidos != 0
					if @@debug_mode; puts "Se mueven #{movidos} unidades de #{sku} a #{nombre_almacen(almacen_a_mover)}" end
				else
					if almacen_a_mover == @@id_multiuso_1
						almacen_a_mover = @@id_multiuso_2
						if @@debug_mode; puts "Multiuso 1 lleno, cambiando a Multiuso 2" end
					else
						if @@debug_mode; puts "Almacenes multiuso llenos" end
						break
					end
				end
			end
		end
	end

end
