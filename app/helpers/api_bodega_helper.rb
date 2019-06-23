# Este helper contiene todas las funciones que interactuan con la Api Bodega del profesor
module ApiBodegaHelper
  include VariablesHelper

  def hashing(data)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), @@api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
  end
  
  def get_almacenes
		data = "GET"
		hash_value = hashing(data)
		almacenes = HTTParty.get("#{@@url}/almacenes", 
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })

		if @@debug_mode
			# puts "\nALMACENES\n"
			# puts JSON.pretty_generate(almacenes)
		end
		return almacenes
  end
  
  def get_products_from_almacenes(almacenId, sku)
		data = "GET#{almacenId}#{sku}"
		hash_value = hashing(data)
		products = HTTParty.get("#{@@url}/stock?almacenId=#{almacenId}&sku=#{sku}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })

		if @@debug_mode
			# puts "\nPRODUCTOS DE ALMACENES\n"
			# puts JSON.pretty_generate(products)
		end
		return products
  end

  def get_products_from_almacenes_limit_primeros(almacenId, sku, limit)
	data = "GET#{almacenId}#{sku}"
	hash_value = hashing(data)
	products = HTTParty.get("#{@@url}/stock?almacenId=#{almacenId}&sku=#{sku}&limit=#{limit}",
		headers:{
		"Authorization": "INTEGRACION grupo4:#{hash_value}",
		"Content-Type": "application/json"
		})

	if @@debug_mode
		# puts "\nPRODUCTOS DE ALMACENES\n"
		# puts JSON.pretty_generate(products)
	end
	return products
  end

  def mover_producto_entre_bodegas(productoId, almacenId, oc, precio)
		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data)
		producto_movido = HTTParty.post("#{@@url}/moveStockBodega",
		  body:{
		  	"productoId": productoId,
		  	"almacenId": almacenId,
		  	"oc": oc,
		  	"precio": precio,
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })

		if @@debug_mode
			# puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
			# puts JSON.pretty_generate(producto_movido)
		end
		return producto_movido
  end

	def mover_producto_entre_almacenes(producto_json, id_destino)
		productoId = producto_json
		almacenId = id_destino

		data = "POST#{productoId}#{almacenId}"
		hash_value = hashing(data)
		req = HTTParty.post("#{@@url}/moveStock",
		  body:{
				"productoId": productoId,
				"almacenId": almacenId,

		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })


		if @@debug_mode
			# puts "\nMOVER PRODUCTO ENTRE ALMACENES\n"
			# puts JSON.pretty_generate(req)
		end
		return req
	end

	def obtener_skus_con_stock(almacenId)
		data = "GET#{almacenId}"
		hash_value = hashing(data)
		skus = HTTParty.get("#{@@url}/skusWithStock?almacenId=#{almacenId}",
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@debug_mode
			# puts "\nSKUS\n"
			# puts JSON.pretty_generate(skus)
		end
		return skus
	end

  def fabricar_sin_pago(sku, cantidad)
		data = "PUT#{sku}#{cantidad}"

		if @@debug_mode; puts data end
		hash_value = hashing(data)
		products_produced = HTTParty.put("#{@@url}/fabrica/fabricarSinPago",
		  body:{
		  	"sku": sku,
		  	"cantidad": cantidad
		  }.to_json,
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_value}",
		    "Content-Type": "application/json"
		  })
		if @@debug_mode
			# puts "\nFABRICAR SIN PAGO\n"
			# puts JSON.pretty_generate(products_produced)
		end
		return products_produced
  end
  
	def pedir_todo_materias_primas
		factor_orden = 1
		factor_maximo = 2
		
		@@materias_primas_propias.each do |sku|
		#@@materias_primas_totales.each do |sku|
			stock_actual = getInventoriesOne(sku)
			maximo_sku = @@minimos[sku][1]*factor_maximo
			producto = Producto.find(sku)
			lote_produccion = producto.lote_produccion

			if @@minimos[sku][1] < 65
				maximo_sku = 250
			end

			if @@debug_mode; puts "Tenemos #{stock_actual["cantidad"]} de #{maximo_sku} del sku #{sku}" end

			if maximo_sku > stock_actual["cantidad"]

				cantidad_faltante = (maximo_sku - stock_actual["cantidad"])
				lotes_a_producir = (cantidad_faltante/lote_produccion).ceil
				cantidad_a_producir = lotes_a_producir * lote_produccion

				if @@debug_mode
					puts fabricar_sin_pago(sku, cantidad_a_producir * factor_orden)
					puts "Fabricamos SIN PAGO el ingrediente: " + sku + ", una cantidad de " + (cantidad_a_producir * factor_orden).to_s + "\n"
				else
					fabricar_sin_pago(sku, cantidad_a_producir * factor_orden)
				end
			end
		end
		
		@@materias_primas_ajenas.each do |sku|
			#break
			stock_actual = getInventoriesOne(sku)
			maximo_sku = @@minimos[sku][1]*factor_maximo
			producto = Producto.find(sku)
			lote_produccion = producto.lote_produccion

			if @@debug_mode; puts "Tenemos #{stock_actual["cantidad"]} de #{maximo_sku} del sku #{sku}" end

			if maximo_sku > stock_actual["cantidad"]
				
				cantidad_faltante = (maximo_sku - stock_actual["cantidad"])
				lotes_a_producir = (cantidad_faltante/lote_produccion).ceil
				cantidad_a_producir = lotes_a_producir * lote_produccion
				cantidad_faltante_ingrediente = cantidad_a_producir

				while cantidad_faltante_ingrediente > 0
					orden = [cantidad_faltante_ingrediente, 20].min
					nos_entregan = pedir_producto_grupos(sku, orden)
					if @@debug_mode; puts "Nos entregan #{nos_entregan} unidades" end
					cantidad_faltante_ingrediente -= nos_entregan
					
					if nos_entregan == 0
						if @@debug_mode; puts "\nNINGUN grupo tienen mas Producto X\n" end
						break
					end
				end
				#nos_entregan = pedir_producto_grupos(sku, cantidad_a_producir * factor_orden)
			end

		end
	
  end

end
