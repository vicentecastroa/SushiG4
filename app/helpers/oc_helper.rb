require 'variables_helper'

module OcHelper
	include VariablesHelper

	def obtener_oc(id)
		orden_compra = HTTParty.get("https://integracion-2019-#{@@estado}.herokuapp.com/oc/obtener/#{id}", 
		  params:{
		  	"id": id,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA OBTENIDA"
			puts JSON.pretty_generate(orden_compra)
		end
		return orden_compra
	end

	def crear_oc(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, url)
		data = "PUT"
		order_creada = HTTParty.put("https://integracion-2019-#{@@estado}.herokuapp.com/oc/crear",
		   body:{
		  	"cliente": cliente,
		  	"proveedor": proveedor,
		  	"sku": sku,
		  	"fechaEntrega": fechaEntrega,
		  	"cantidad": cantidad,
		  	"precioUnitario": precioUnitario,
		  	"canal": canal,
		  	"urlNotificacion": url
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA CREADA"
			puts JSON.pretty_generate(order_creada)
		end
		return order_creada
	end

	def anular_oc(id, anulacion)
		orden_compra_anulada = HTTParty.delete("https://integracion-2019-#{@@estado}.herokuapp.com/oc/anular/#{id}", 
		  body:{
		  	"id": id,
		  	"anulacion": anulacion,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA ANULADA"
			puts JSON.pretty_generate(orden_compra_anulada)
		end
		return orden_compra_anulada
	end

	def aceptar_oc(id)
		orden_compra_recepcionada = HTTParty.post("https://integracion-2019-#{@@estado}.herokuapp.com/oc/recepcionar/#{id}", 
		  body:{
		  	"id": id,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA ACEPTADA"
			puts JSON.pretty_generate(orden_compra_recepcionada)
		end
		return orden_compra_recepcionada
	end

	def rechazar_oc(id, rechazo)
		orden_compra_rechazada = HTTParty.post("https://integracion-2019-#{@@estado}.herokuapp.com/oc/rechazar/#{id}", 
		  body:{
		  	"id": id,
		  	"rechazo": rechazo,
		  }.to_json,
		  headers:{
		    "Content-Type": "application/json"
		  })
		if @@print_valores
			puts "ORDEN DE COMPRA RECHAZADA"
			puts JSON.pretty_generate(orden_compra_rechazada)
		end
		return orden_compra_rechazada
	end

end