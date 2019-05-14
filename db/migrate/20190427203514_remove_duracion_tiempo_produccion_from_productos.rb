class RemoveDuracionTiempoProduccionFromProductos < ActiveRecord::Migration[5.1]
  def change
    remove_column :productos, :duracion, :time
    remove_column :productos, :tiempo_produccion, :time
  end
end
