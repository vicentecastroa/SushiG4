require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def init_inventory_worker
		InventoryWorker.perform_async
		# SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
	end

	def init_test_worker
		MeLlamoWorker.perform_async
		# render text: "El worker esta funcionanto"
	end

	def index
		start
	end

	def create
	end

	def destroy
	end

	def update
	end

end
