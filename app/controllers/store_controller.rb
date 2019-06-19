class StoreController < ApplicationController
	
	include PerformHelper

	def index
		@stock = getPrintStock()
	end
end
