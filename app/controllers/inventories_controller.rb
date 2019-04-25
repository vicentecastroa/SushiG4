require 'httparty'
require 'hmac-sha1'
require 'json'

module InventoriesHelper

	# Funcion que hay que editar
	def hmac_sha1(data, api_key)
		hmac = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), api_key.encode("ASCII"), data.encode("ASCII"))
		signature = Base64.encode64(hmac).chomp
		return signature
	end

	def get_almacenes(api_key)
		data = "GET"
		hash_almacenes = hmac_sha1(data, api_key)
		almacenes = HTTParty.get('https://integracion-2019-dev.herokuapp.com/bodega/almacenes', 
		  headers:{
		    "Authorization": "INTEGRACION grupo4:#{hash_almacenes}",
		    "Content-Type": "application/json"
		  })
		puts JSON.pretty_generate(almacenes)
		return almacenes
	end
end


class InventoriesController < ApplicationController
	include InventoriesHelper

	def show
	end

	def index
		api_key = "o5bQnMbk@:BxrE"
		@almacenes = get_almacenes(api_key)
	end

	def create
	end

	def destroy
	end

	def update
	end



end

