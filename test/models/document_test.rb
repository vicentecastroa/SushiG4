# == Schema Information
#
# Table name: documents
#
#  order_id           :string           not null, primary key
#  cliente            :string
#  proveedor          :string
#  sku                :integer
#  fechaEntrega       :date
#  cantidad           :integer
#  cantidadDespachada :integer
#  precioUnitario     :integer
#  canal              :string
#  estado             :string
#  notas              :string
#  rechazo            :string
#  anulacion          :string
#  urlNotificacion    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  all                :string
#

require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
