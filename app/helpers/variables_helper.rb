module VariablesHelper
	@@api_key = "o5bQnMbk@:BxrE"
	@@estado = "prod"
	@@print_valores = false
	@@host = 'fierro.ing.puc.cl'
	@@port = 22
	@@debug_mode = false

	# Capacidades Bodegas
	@@tamaño_cocina = 1122
	@@tamaño_recepcion = 133
	@@tamaño_despacho = 80
	@@tamaño_pulmon = 99999999

	@@status_of_work = false

	#IDs Grupos
	if @@estado == 'prod'

		#IDs Producción
		@@id_recepcion = '5cc7b139a823b10004d8e6df'
		@@id_despacho = "5cc7b139a823b10004d8e6e0"
		@@id_pulmon = "5cc7b139a823b10004d8e6e3"
		@@id_cocina = "5cc7b139a823b10004d8e6e4"
		@@url = "http://integracion-2019-prod.herokuapp.com/bodega"
		@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]

		@@IDs_Grupos = {"1"=>"5cc66e378820160004a4c3bc",
					"2"=>"5cc66e378820160004a4c3bd",
					"3"=>"5cc66e378820160004a4c3be",
					"4"=>"5cc66e378820160004a4c3bf",
					"5"=>"5cc66e378820160004a4c3c0",
					"6"=>"5cc66e378820160004a4c3c1",
					"7"=>"5cc66e378820160004a4c3c2",
					"8"=>"5cc66e378820160004a4c3c3",
					"9"=>"5cc66e378820160004a4c3c4",
					"10"=>"5cc66e378820160004a4c3c5",
					"11"=>"5cc66e378820160004a4c3c6",
					"12"=>"5cc66e378820160004a4c3c7",
					"13"=>"5cc66e378820160004a4c3c8",
					"14"=>"5cc66e378820160004a4c3c9"}

		@@id_produccion = "5cc66e378820160004a4c3bf"
		@@user = "grupo4"
		@@password = 'p6FByxRf5QYbrDC80'
	else
		#IDs Desarrollo
		@@id_recepcion = "5cbd3ce444f67600049431c5"
		@@id_despacho = "5cbd3ce444f67600049431c6"
		@@id_pulmon = "5cbd3ce444f67600049431c9"
		@@id_cocina = "5cbd3ce444f67600049431ca"
		@@url = "https://integracion-2019-dev.herokuapp.com/bodega"
		@@id_almacenes = [@@id_cocina, @@id_recepcion, @@id_pulmon]

		@@IDs_Grupos = {"1"=>"5cbd31b7c445af0004739be3",
					"2"=>"5cbd31b7c445af0004739be4",
					"3"=>"5cbd31b7c445af0004739be5",
					"4"=>"5cbd31b7c445af0004739be6",
					"5"=>"5cbd31b7c445af0004739be7",
					"6"=>"5cbd31b7c445af0004739be8",
					"7"=>"5cbd31b7c445af0004739be9",
					"8"=>"5cbd31b7c445af0004739bea",
					"9"=>"5cbd31b7c445af0004739beb",
					"10"=>"5cbd31b7c445af0004739bec",
					"11"=>"5cbd31b7c445af0004739bed",
					"12"=>"5cbd31b7c445af0004739bee",
					"13"=>"5cbd31b7c445af0004739bef",
					"14"=>"5cbd31b7c445af0004739bf0"}

		@@user = 'grupo4_dev'
		@@password = '1ccWcVkAmJyrOfA'
	end

	# Productos
	@@nuestros_productos = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	# Materias primas
	@@materias_primas_totales = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016", "1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]
	# Materias primas producidas por nosotros
	@@materias_primas_propias = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	# Materias primas producidas por otros grupos
	@@materias_primas_ajenas = ["1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]
	# Productos procesados
	@@productos_procesados = ["1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1114", "1115", "1116", "1201", "1207", "1209", "1210", "1211", "1215", "1216", "1301", "1307", "1309", "1310", "1407"]

	@@minimos = {
		"1013"=>["Masago", 300],
		"1101"=>["Arroz cocido", 335],
		"1001"=>["Arroz grano corto", 240],
		"1003"=>["Azúcar", 90],
		"1004"=>["Sal", 60],
		"1002"=>["Vinagre de arroz", 120],
		"1105"=>["Kanikama para roll", 50],
		"1005"=>["Kanikama entero", 5],
		"1106"=>["Camarón cocido", 400],
		"1006"=>["Camarón", 4],
		"1107"=>["Salmón cortado para roll", 50],
		"1007"=>["Filete de salmón", 26],
		"1108"=>["Salmón ahumado cortado para roll", 10],
		"1008"=>["Filete de salmón ahumado", 2],
		"1109"=>["Atún cortado para roll", 50],
		"1009"=>["Filete de atún", 23],
		"1110"=>["Palta cortada para envoltura", 80],
		"1010"=>["Palta", 33],
		"1111"=>["Sésamo tostado", 16],
		"1011"=>["Sésamo", 10],
		"1112"=>["Queso crema para roll", 130],
		"1012"=>["Queso crema", 7],
		"1114"=>["Cebollín cortado para roll", 50],
		"1014"=>["Cebollín entero", 13],
		"1115"=>["Ciboulette picado para roll", 30],
		"1015"=>["Ciboulette entero", 20],
		"1116"=>["Nori entero cortado para roll", 250],
		"1016"=>["Nori entero", 285],
		"1201"=>["Arroz cocido para roll", 250],
		"1207"=>["Salmón cortado para nigiri", 20],
		"1209"=>["Atún cortado para nigiri", 20],
		"1210"=>["Palta cortada para roll", 150],
		"1211"=>["Sésamo tostado para envoltura", 60],
		"1215"=>["Ciboulette picado para envoltura", 20],
		"1216"=>["Nori entero cortado para nigiri", 50],
		"1301"=>["Arroz cocido para nigiri", 50],
		"1307"=>["Salmón cortado para sashimi", 170],
		"1309"=>["Atún cortado para sashimi", 170],
		"1310"=>["Palta cortada para nigiri", 20],
		"1407"=>["Salmón cortado para envoltura", 40]
	}
end
