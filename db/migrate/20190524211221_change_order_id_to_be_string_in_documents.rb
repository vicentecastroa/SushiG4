class ChangeOrderIdToBeStringInDocuments < ActiveRecord::Migration[5.1]
  def change
  	change_column :documents, :order_id, :string
  end
end
