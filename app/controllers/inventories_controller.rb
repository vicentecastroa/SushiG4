require 'httparty'
require 'hmac-sha1'
require 'json'

class InventoriesController < ApplicationController

	def show
	end

	def init_check_inventory
		SchedulerWorker.perform_async unless SchedulerWorker.new.scheduled?
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
