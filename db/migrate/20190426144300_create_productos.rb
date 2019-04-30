class CreateProductos < ActiveRecord::Migration[5.1]
  def change
    create_table :productos, id:false, primary_key: :sku do |t|
      t.string :sku, null: false
      t.string :nombre
      t.integer :precio_venta
      t.time :duracion
      t.float :equivalencia_un_bodega
      t.integer :lote_produccion
      t.time :tiempo_produccion
      t.integer :espacio_produccion
      t.integer :espacio_recepcion
      t.integer :stock_minimo

      t.timestamps
    end
    execute "ALTER TABLE productos ADD PRIMARY KEY (sku);"
  end
end
