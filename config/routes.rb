Rails.application.routes.draw do
  resources :documents
require "sidekiq/web"
require "sidekiq/cron/web"
mount Sidekiq::Web => "/sidekiq"

resources :inventories, :productos, :orders, :group
get '/inventories', to: 'inventories#show_inventory'
get '/totalproducts', to: 'inventories#total_products'
get '/getskustock', to: 'inventories#sku_stock'
get '/checkin_init', to: 'inventories#init_check_inventory'
post '/documents/:order_id/notification', to: 'documents#notificaciones'
end
