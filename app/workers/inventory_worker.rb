class InventoryWorker

	include Sidekiq::Worker
	sidekiq_options retry: false

	def perform
		puts "\nInventory worker checkeando inventario\n"
	end

end