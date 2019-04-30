Rails.application.routes.draw do
  
resources :inventories, :productos :orders
get '/inventories', to: 'inventories#show_inventory'
end
