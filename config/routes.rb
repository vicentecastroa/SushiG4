Rails.application.routes.draw do
  
  resources :documents
require "sidekiq/web"
require "sidekiq/cron/web"
mount Sidekiq::Web => "/sidekiq"

resources :inventories, :productos, :orders, :group

get '/totalproducts', to: 'inventories#total_products'
get '/getskustock', to: 'inventories#sku_stock'

#Jobs
get '/vaciar_pulmon', to: 'inventories#init_vaciar_pulmon'
get '/arrocero', to: 'inventories#arrocero_init'
get '/checkin_init', to: 'inventories#init_check_inventory'
get '/review_init', to: 'inventories#init_review'
get '/delivery_init', to: 'inventories#init_delivery'
get '/vaciar_despacho', to: 'inventories#vaciar_despacho'
get 'ftp', to: 'ftp_ordenes#index'
get 'stock', to: 'inventories#allstock'
get 'cocina', to: 'inventories#cocina'
post '/documents/:order_id/notification', to: 'documents#notificaciones'

get '/pedir_todo', to: 'inventories#pedir_todo'

end
