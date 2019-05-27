Rails.application.routes.draw do
require "sidekiq/web"
require "sidekiq/cron/web"
mount Sidekiq::Web => "/sidekiq"

resources :inventories, :productos, :orders, :group
get '/inventories', to: 'inventories#show_inventory'
get '/init_inventory', to: 'inventories#init_inventory_worker'
get '/test_worker', to: 'inventories#init_test_worker'

end


