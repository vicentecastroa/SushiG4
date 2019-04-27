class AddTiempoProduccionMinToProductos < ActiveRecord::Migration[5.1]
  def change
    add_column :productos, :tiempo_produccion_min, :float
  end
end
