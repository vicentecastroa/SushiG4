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
			puts "\nALMACENES\n"
			puts JSON.pretty_generate(almacenes)
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
			puts "\nPRODUCTOS DE ALMACENES\n"
			puts JSON.pretty_generate(products)
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
		puts "\nPRODUCTOS DE ALMACENES\n"
		puts JSON.pretty_generate(products)
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
			puts "\nMOVER PRODUCTO ENTRE BODEGAS\n"
			puts JSON.pretty_generate(producto_movido)
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
			puts "\nMOVER PRODUCTO ENTRE ALMACENES\n"
			puts JSON.pretty_generate(req)
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
			puts "\nSKUS\n"
			puts JSON.pretty_generate(skus)
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
			puts "\nFABRICAR SIN PAGO\n"
			puts JSON.pretty_generate(products_produced)
		end
		return products_produced
  end
  
  def pedir_todo_materias_primas
    if @@debug_mode; puts "Pedir todas las materias primas propias" end
    @@materias_primas_propias.each do |sku|
      fabricar_sin_pago(sku, 100)
    end
		if @@estado == "dev"
			if @@debug_mode; puts "DEV: Pedir materias primas ajenas" end
      @@materias_primas_ajenas.each do |sku|
        fabricar_sin_pago(sku, 100)
      end
    end
  end

  
end
