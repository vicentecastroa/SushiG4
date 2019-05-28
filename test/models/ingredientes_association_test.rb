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

require 'test_helper'

class IngredientesAssociationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
