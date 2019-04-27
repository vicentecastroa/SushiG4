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

		#Faltaria ahora enviar una request al profesor segun esas variables de arriba


		#Aca hay que controlar esta respuesta segun la request que se le envia al profesor 
		res = {
			"sku": @sku,
			"cantidad": @cantidad,
			"almacenId": @almacenId,
			"grupoProveedor": 4,

			#Esto depende del profesor
			"aceptado": true,
			"despachado": true
		}

		render json: res


	end

	def destroy
	end

	def update
	end


end
