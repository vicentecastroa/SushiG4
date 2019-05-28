# == Schema Information
#
# Table name: grupos
#
#  group_id   :integer          not null, primary key
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Grupo < ApplicationRecord
  self.primary_key = 'group_id'
  has_and_belongs_to_many :productos
end
