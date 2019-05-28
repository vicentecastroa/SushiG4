# == Schema Information
#
# Table name: ingredientes_associations
#
#  id              :bigint           not null, primary key
#  producto_id     :string
#  ingrediente_id  :string
#  cantidad        :float
#  lote_produccion :integer
#  cantidad_lote   :float
#  unidades_bodega :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class IngredientesAssociation < ApplicationRecord
  belongs_to :producto, :class_name => "Producto"
  belongs_to :ingrediente, :class_name => "Producto"
end
