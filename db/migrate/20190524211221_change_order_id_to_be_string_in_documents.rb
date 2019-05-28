class ChangeOrderIdToBeStringInDocuments < ActiveRecord::Migration[5.2]
  def change
  	change_column :documents, :order_id, :string
  end
end
