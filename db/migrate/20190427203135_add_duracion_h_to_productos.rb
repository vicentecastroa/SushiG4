class AddDuracionHToProductos < ActiveRecord::Migration[5.1]
  def change
    add_column :productos, :duracion_h, :float
  end
end
