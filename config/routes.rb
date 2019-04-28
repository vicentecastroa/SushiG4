Rails.application.routes.draw do
resources :inventories, :productos
get '/', to: 'inventories#show_inventory'
end
