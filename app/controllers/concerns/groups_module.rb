require 'httparty'
require 'json'

module GroupsModule

  # Obtener el inventario total de un grupo
  def get_inventario_grupo(grupo)
    
    group_url = Grupo.find(grupo).url
    response = HTTParty.get("http://#{group_url}/inventories")
    
    return response
  end

  # Obtener stock de un producto determinado de otro grupo
  def get_stock_producto_grupo(grupo, sku)

    inventario = get_inventario_grupo(grupo).to_a
    producto = nil
    inventario.each do |item|
      if item["sku"] == sku
        producto = {"sku" => item["sku"], "cantidad" => item["total"]}
      end
    end

    return producto.to_json
  end

  # Pedir un producto a los grupos productores
  def get_producto_grupo(sku, cantidad)
  
    grupos_productores = Producto.find(sku).grupos
    
    # iterar en orden random sobre los grupos productores
    grupos_productores.shuffle.each do |grupo|
      url = "http://#{grupo.url}/orders"
      grupo_solicitante = '4'
      req = HTTParty.post(url,
        headers:{
          "Content-Type": "application/json",
          "Group": grupo_solicitante
        }, 
        body:{
          "sku": sku, 
          "cantidad": cantidad, 
          "almacenId": @@id_recepcion
        }.to_json) 
      if req['aceptado']
        break
      end
    end
  
    return req
  end
  
end
