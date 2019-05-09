class AddCostoProdLoteToProductos < ActiveRecord::Migration[5.2]
  def change
    add_column :productos, :costo_prod_lote, :integer
  end
end
