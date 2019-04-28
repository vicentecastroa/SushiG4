Rails.application.routes.draw do
	scope "/inventories"
		resources :inventories
		get action: show_inventory, controller: 'inventories'

end
