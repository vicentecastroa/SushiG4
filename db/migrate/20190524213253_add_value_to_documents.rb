class AddValueToDocuments < ActiveRecord::Migration[5.2]
  def change
  	add_column :documents, :all, :string
  end
end
