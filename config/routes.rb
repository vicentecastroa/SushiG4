Rails.application.routes.draw do
require "sidekiq/web"
mount Sidekiq::Web => "/sidekiq"

resources :inventories, :productos, :orders
get '/inventories', to: 'inventories#show_inventory'
get '/checkin_init', to: 'inventories#init_check_inventory'

end
