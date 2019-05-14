class Grupo < ApplicationRecord
  self.primary_key = 'group_id'
  has_and_belongs_to_many :productos
end
