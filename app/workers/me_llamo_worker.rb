class MeLlamoWorker < ApplicationController

	include Sidekiq::Worker
	# sidekiq_options retry: false

	def perform

		puts "\nmi api key es #{@@api_key}\n"
		print_start()
		# render text: "FUNCIONA"

	end

end