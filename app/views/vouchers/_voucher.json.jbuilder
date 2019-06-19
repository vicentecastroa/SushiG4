json.extract! voucher, :id, :id, :nombre, :monto_neto, :iva_pagado, :monto_final, :productos, :ubicacion, :hora_entrega, :hora_pedido, :created_at, :updated_at
json.url voucher_url(voucher, format: :json)
