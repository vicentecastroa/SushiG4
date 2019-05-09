class AddLugarFabricacionToProductos < ActiveRecord::Migration[5.2]
  def change
    add_column :productos, :lugar_fabricacion, :string
  end
end
