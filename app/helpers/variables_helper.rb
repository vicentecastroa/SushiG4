module VariablesHelper
	@@api_key = "o5bQnMbk@:BxrE"
	@@estado = "dev"
	@@print_valores = false
	@@host = 'fierro.ing.puc.cl'
	@@port = 22
	@@debug_mode = true

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
	# Materia primas producidas por nosotros
	@@materias_primas_propias = ["1001", "1004", "1005", "1006", "1009", "1014", "1015", "1016"]
	# Materias primas prodcidas por otros grupos
	@@materias_primas_ajenas = ["1002", "1003", "1007", "1008", "1010", "1011", "1012", "1013"]
	# Productos procesados
	@@productos_procesados = ["1105", "1106", "1107", "1108", "1109", "1110", "1111", "1112", "1114", "1115", "1116", "1201", "1207", "1209", "1210", "1211", "1215", "1216", "1301", "1307", "1309", "1310", "1407"]

end
