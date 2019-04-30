require 'csv'

## Seeds Grupos
csv_text = File.read(Rails.root.join('lib', 'seeds', 'group_seeds.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
csv.each do |row|
  Grupo.create! do |grupo|
    grupo.group_id = row['GroupID']
    grupo.url = row['URL']
    #puts "Grupo #{grupo.GroupId}: #{grupo.URL} saved!"
  end
end
puts "Grupos creados"


## Seeds Productos
csv_text = File.read(Rails.root.join('lib', 'seeds', 'product_seeds.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
csv.each do |row|
  Producto.create! do |producto|
    producto.sku = row['SKU']
    producto.nombre = row['Nombre']
    producto.precio_venta = row['PrecioVenta']
    producto.duracion_h = row['Duracion']
    producto.equivalencia_un_bodega = row['EqBodega']
    producto.lote_produccion = row['Lote Produccion']
    producto.tiempo_produccion_min = row['Tiempo Produccion']
    producto.espacio_produccion = row['Espacio Produccion']
    producto.espacio_recepcion = row['Espacio Recepcion']
    producto.stock_minimo = row['Stock Minimo']
  end
end
puts "Productos creados"

## Asignar relacion grupos-productos
csv_text = File.read(Rails.root.join('lib', 'seeds', 'grupo_producto_seeds.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
csv.each do |row|
  Producto.find(row['SKU']).grupos << Grupo.find(row['Grupo'])
end
puts "Grupos productores asignados"

## Asignar ingredientes a productos
csv_text = File.read(Rails.root.join('lib', 'seeds', 'producto_ingrediente_seeds.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'UTF-8')
csv.each do |row|
  IngredientesAssociation.create! do |association|
    association.producto_id = row['SKU Producto']
    association.ingrediente_id = row['SKU Ingrediente']
    association.cantidad = row['Cantidad']
    association.lote_produccion = row['Lote producción']
    association.cantidad_lote = row['Cantidad para lote']
    association.unidades_bodega = row['Unidades bodega']
  end
end
puts "Ingredientes asignados"


