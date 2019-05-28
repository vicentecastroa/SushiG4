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

class Producto < ApplicationRecord
  self.primary_key = 'sku'
  has_and_belongs_to_many :grupos #, :foreign_key => :group_id

  has_many :ingredientes_associations, :foreign_key => :producto_id
  has_many :ingredientes, :through => :ingredientes_associations, :source => :ingrediente
end
