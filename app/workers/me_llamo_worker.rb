class MeLlamoWorker < ApplicationController

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		puts "\nmi api key es #{@@api_key}\n"
	end

end