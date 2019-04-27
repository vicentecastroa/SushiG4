class IngredientesAssociation < ApplicationRecord
  belongs_to :producto, :class_name => "Producto"
  belongs_to :ingrediente, :class_name => "Producto"
end
