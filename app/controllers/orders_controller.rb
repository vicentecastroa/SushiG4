require 'httparty'
require 'hmac-sha1'
require 'json'


class OrdersController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:create]

	def show
	end

	def index
	end

	def create
		
		@group = request.headers['group']
		@sku = params["order"]["sku"]
		@cantidad = params["order"]["cantidad"]
		@almacenId = params["order"]["almacenId"]

		#Puts para ver en consola los datos de la request
		puts "Request POST"
		puts "Grupo: ",@group
		puts "Solicita SKU: ",@sku
		puts "Por una cantidad de: ", @cantidad
		puts "Entregar en el almacen: ", @almacenId

		#Si alguna de los parametros necesarios no viene responder con error 400
		if @cantidad.blank? || @group.blank? || @sku.blank? || @almacenId.blank?
			res = "No se creó el pedido por un error del cliente en la solicitud. Por ejemplo, falta un parámetro obligatorio"
			render plain: res, :status => 400
		end

		#Faltaria ahora enviar una request al profesor segun esas variables de arriba

		@aceptado = false #para testear
		@despachado = true #para testear

		#Aca hay que controlar la respuesta al grupo solicitante segun la request que se le envio al profesor 
		if @aceptado == true && @despachado == true
			res = {
				"sku": @sku,
				"cantidad": @cantidad,
				"almacenId": @almacenId,
				"grupoProveedor": 4,
	
				#Esto depende del profesor
				"aceptado": true,
				"despachado": true
			}
	
			render json: res, :status => 201

		else
			res = "Producto no se encuentra (el grupo no ofrece productos de este sku) o no tiene stock"
			render plain: res, :status => 404
		end
	end

	def destroy
	end

	def update
	end


end
