class Producto < ApplicationRecord
  self.primary_key = 'sku'
  has_and_belongs_to_many :grupos #, :foreign_key => :group_id

  has_many :ingredientes_associations, :foreign_key => :producto_id
  has_many :ingredientes, :through => :ingredientes_associations, :source => :ingrediente
end
