class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents, id:false, primary_key: :order_id do |t|
      t.integer :order_id, null: false
      t.string :cliente
      t.string :proveedor
      t.integer :sku
      t.date :fechaEntrega
      t.integer :cantidad
      t.integer :cantidadDespachada
      t.integer :precioUnitario
      t.string :canal
      t.string :estado
      t.string :notas
      t.string :rechazo
      t.string :anulacion
      t.string :urlNotificacion

      t.timestamps
    end
    execute "ALTER TABLE documents ADD PRIMARY KEY (order_id);"
  end
end

