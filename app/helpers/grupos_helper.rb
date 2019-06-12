require 'httparty'
require 'json'

# Este helper contiene todas las funciones que interactuan con las apis de los otros grupos.
module GruposHelper
  
  # Obtener el inventario total de un grupo
  def get_inventario_grupo(grupo_id)
    
		begin
			inventario_grupo = HTTParty.get("http://tuerca#{grupo_id}.ing.puc.cl/inventories", timeout: 90)
		rescue Net::OpenTimeout
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		rescue Timeout::Error
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		rescue Net::ReadTimeout
			puts "Grupo sin conexion. Imposible acceder al inventario\n"
			inventario_grupo = {"sku" => "9999", "nombre" => "No Stock", "total" => 0}
		else	
			return inventario_grupo
		end
		
		if @@print_valores
			puts "\nInventario de Grupo " + grupo_id.to_s + ": \n" + inventario_grupo.to_s + "\n"
		end
		
		return false
  end

  # Obtener stock de un producto determinado de otro grupo
  def get_stock_producto_grupo(grupo, sku)
    puts "Get stock de sku: #{sku} de grupo #{grupo}"

    inventario = get_inventario_grupo(grupo).to_a
    producto = nil
    inventario.each do |item|
      if item["sku"] == sku
        producto = {"sku" => item["sku"], "cantidad" => item["total"]}
        return producto
      end
    end

    return nil
  end

  # Pedir un producto a un determinado grupo. Retorna la cantidad pedida. 
  def pedir_producto_grupo(grupo_id, sku, cantidad)
    puts "Pedir #{cantidad} de #{sku} a grupo #{grupo_id}"

    stock_disponible = get_stock_producto_grupo(grupo_id, sku)["cantidad"]
    cantidad_a_pedir = cantidad
    
    if stock_disponible >= cantidad_a_pedir
      puts "Hay stock. Pedir #{cantidad_a_pedir}"
      if solicitar_OC(sku, cantidad_a_pedir.to_i, grupo_id)
        return cantidad_a_pedir
      end
    else
      puts "No hay suficiente. Pedir #{stock_disponible}"
      if solicitar_OC(sku, stock_disponible.to_i, grupo_id)
        cantidad_pedida = stock_disponible
        return cantidad_pedida
      end
    end
  end

  
end
