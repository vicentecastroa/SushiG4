Rails.application.routes.draw do
  
  resources :documents
require "sidekiq/web"
require "sidekiq/cron/web"
mount Sidekiq::Web => "/sidekiq"

resources :inventories, :productos, :orders, :group

get '/totalproducts', to: 'inventories#total_products'
get '/getskustock', to: 'inventories#sku_stock'
get '/checkin_init', to: 'inventories#init_check_inventory'
get 'ftp', to: 'ftp_ordenes#index'
get 'stock', to: 'inventories#allstock'
post '/documents/:order_id/notification', to: 'documents#notificaciones'

get '/pedir_todo', to: 'inventories#pedir_todo'
# hola
end
