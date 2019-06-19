class CreateVouchers < ActiveRecord::Migration[5.2]
  def change
    create_table :vouchers, id:false, primary_key: :id_voucher do |t|
      t.string :id_voucher
      t.string :nombre
      t.integer :monto_neto
      t.integer :iva_pagado
      t.integer :monto_final
      t.string :productos
      t.string :ubicacion
      t.date :hora_entrega
      t.date :hora_pedido

      t.timestamps
    end
    execute "ALTER TABLE vouchers ADD PRIMARY KEY (id_voucher);"
  end
end
