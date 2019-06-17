class AddValueToDocuments < ActiveRecord::Migration[5.1]
  def change
  	add_column :documents, :all, :string
  end
end
