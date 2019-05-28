# == Schema Information
#
# Table name: productos
#
#  sku                    :string           not null, primary key
#  nombre                 :string
#  precio_venta           :integer
#  equivalencia_un_bodega :float
#  lote_produccion        :integer
#  espacio_produccion     :integer
#  espacio_recepcion      :integer
#  stock_minimo           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  duracion_h             :float
#  tiempo_produccion_min  :float
#  lugar_fabricacion      :string
#  costo_prod_lote        :integer
#

require 'test_helper'

class ProductoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
