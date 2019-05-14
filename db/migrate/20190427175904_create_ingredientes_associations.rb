class CreateIngredientesAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :ingredientes_associations do |t|
      t.string :producto_id
      t.string :ingrediente_id
      t.float :cantidad
      t.integer :lote_produccion
      t.float :cantidad_lote
      t.float :unidades_bodega

      t.timestamps
    end
  end
end
