Rails.application.routes.draw do
resources :inventories, :productos
get '/inventories', to: 'inventories#show_inventory'
end
