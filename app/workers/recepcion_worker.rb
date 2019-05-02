require 'json'

class RecepcionWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		
	end

end
