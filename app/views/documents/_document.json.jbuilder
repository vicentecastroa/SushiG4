json.extract! document, :id, :order_id, :cliente, :proveedor, :sku, :fechaEntrega, :cantidad, :cantidadDespachada, :precioUnitario, :canal, :estado, :notas, :rechazo, :anulacion, :urlNotificacion, :created_at, :updated_at
json.url document_url(document, format: :json)
