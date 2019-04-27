class CreateGrupos < ActiveRecord::Migration[5.1]
  def change
    create_table :grupos, id:false, primary_key: :group_id do |t|
      t.integer :group_id, null: false
      t.string :url

      t.timestamps
    end
    execute "ALTER TABLE grupos ADD PRIMARY KEY (group_id);"
  end
end
# 
