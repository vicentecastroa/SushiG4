Rails.application.routes.draw do
	resources :inventories
	resources :orders
	resources :productos

	get '/inventories', to: 'inventories#show_inventory'
end
