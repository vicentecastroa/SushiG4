class CreateJoinTableGrupoProducto < ActiveRecord::Migration[5.1]
  def change
    create_join_table :grupos, :productos do |t|
       t.index [:producto_id, :grupo_id]
    end
  end
end
