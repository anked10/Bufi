import 'package:bufi/src/database/carrito_db.dart';
import 'package:bufi/src/database/producto_bd.dart';
import 'package:bufi/src/database/subsidiary_db.dart';
import 'package:bufi/src/models/carritoGeneralModel..dart';
import 'package:bufi/src/models/carritoModel.dart';
import 'package:rxdart/rxdart.dart';

class CarritoBloc {
  final carritoDb = CarritoDb();
  final productoDatabase = ProductoDatabase();
  final _carritoGeneralController =
      BehaviorSubject<List<CarritoGeneralModel>>();
  final _carritoSeleccionaController =
      BehaviorSubject<List<CarritoGeneralModel>>();

  Stream<List<CarritoGeneralModel>> get carritoGeneralStream =>
      _carritoGeneralController.stream;
  Stream<List<CarritoGeneralModel>> get carritoSeleccionadoStream =>
      _carritoSeleccionaController.stream;

  void dispose() {
    _carritoGeneralController?.close();
    _carritoSeleccionaController?.close();
  }

  void obtenerCarrito() async {
    _carritoGeneralController.sink.add(await carritoPorSucursal());
  }

  void obtenerCarritoConfirmacion(String idSubsidiary) async {
    _carritoSeleccionaController.sink .add(await carritoPorSucursalSeleccionado(idSubsidiary));
  }

  Future<List<CarritoGeneralModel>> carritoPorSucursal() async {
    final listaGeneral = List<CarritoGeneralModel>();
    final carritoDb = CarritoDb();
    final listaDeStringDeIds = List<String>();
    final subsidiary = SubsidiaryDatabase();

    double cantidadTotal = 0;

    //funcion que trae los datos del carrito agrupados por iDSubsidiary para que no se repitan los IDSubsidiary
    final listCarritoAgrupados = await carritoDb.obtenerProductosAgrupados();

    //llenamos la lista de String(listaDeStringDeIds) con los datos agrupados que llegan (listCarritoAgrupados)
    for (var i = 0; i < listCarritoAgrupados.length; i++) {
      var id = listCarritoAgrupados[i].idSubsidiary;
      listaDeStringDeIds.add(id);
    }

    //obtenemos todos los elementos del carrito
    final listCarrito = await carritoDb.obtenerProductoXCarrito();
    for (var x = 0; x < listaDeStringDeIds.length; x++) {
      //función para obtener los datos de la sucursal para despues usar el nombre
      final sucursal =
          await subsidiary.obtenerSubsidiaryPorId(listaDeStringDeIds[x]);

      final listCarritoModel = List<CarritoModel>();

      CarritoGeneralModel carritoGeneralModel = CarritoGeneralModel();

      //agregamos el nombre de la sucursal con los datos antes obtenidos (sucursal)
      carritoGeneralModel.nombre = sucursal[0].subsidiaryName;
      carritoGeneralModel.idSubsidiary = sucursal[0].idSubsidiary;
      for (var y = 0; y < listCarrito.length; y++) {
        //cuando hay coincidencia de id's procede a agregar los datos a la lista
        if (listaDeStringDeIds[x] == listCarrito[y].idSubsidiary) {
          if (listCarrito[y].estadoSeleccionado == '1') {
            double precio = double.parse(listCarrito[y].precio);
            int cant = int.parse(listCarrito[y].cantidad);

            cantidadTotal = cantidadTotal + (precio * cant);

            print('tamare $cantidadTotal');
          }

          CarritoModel c = CarritoModel();

          c.precio = listCarrito[y].precio;
          c.idSubsidiary = listCarrito[y].idSubsidiary;
          c.idSubsidiaryGood = listCarrito[y].idSubsidiaryGood;
          c.nombre = listCarrito[y].nombre;
          c.marca = listCarrito[y].marca;
          c.image = listCarrito[y].image;
          c.moneda = listCarrito[y].moneda;
          c.size = listCarrito[y].size;
          c.caracteristicas = listCarrito[y].caracteristicas;
          c.estadoSeleccionado = listCarrito[y].estadoSeleccionado;
          c.cantidad = listCarrito[y].cantidad;

          listCarritoModel.add(c);
        }
      }

      carritoGeneralModel.carrito = listCarritoModel;
      carritoGeneralModel.monto = cantidadTotal.toString();

      cantidadTotal = 0.0;

      listaGeneral.add(carritoGeneralModel);
    }

    return listaGeneral;
  }

  Future<List<CarritoGeneralModel>> carritoPorSucursalSeleccionado(
      String idSubsidiary) async {
    final listaGeneral = List<CarritoGeneralModel>();
    final carritoDb = CarritoDb();
    final subsidiaryDatabase = SubsidiaryDatabase();
    final listCarritoModel = List<CarritoModel>();

    double cantidadTotal = 0;

    //obtenemos los datos de la sucursal
    final listSubsidiary = await subsidiaryDatabase.obtenerSubsidiaryPorId(idSubsidiary);

    //obtenemos los datos del carrito por sucursal y seleccionados
    final listCarrito = await carritoDb.obtenerCarritoPorSucursalSeleccionado(idSubsidiary);

    //validamos que exista la sucursal y el carrito tenga productos
    if (listSubsidiary.length > 0) {
      if (listCarrito.length > 0) {
        CarritoGeneralModel carritoGeneralModel = CarritoGeneralModel();
        carritoGeneralModel.nombre = listSubsidiary[0].subsidiaryName;
        carritoGeneralModel.idSubsidiary = listSubsidiary[0].idSubsidiary;

        for (var y = 0; y < listCarrito.length; y++) {
          double precio = double.parse(listCarrito[y].precio);
          int cant = int.parse(listCarrito[y].cantidad);

          cantidadTotal = cantidadTotal + (precio * cant);


          CarritoModel c = CarritoModel();
          c.precio = listCarrito[y].precio;
          c.idSubsidiary = listCarrito[y].idSubsidiary;
          c.idSubsidiaryGood = listCarrito[y].idSubsidiaryGood;
          c.nombre = listCarrito[y].nombre;
          c.marca = listCarrito[y].marca;
          c.image = listCarrito[y].image;
          c.moneda = listCarrito[y].moneda;
          c.size = listCarrito[y].size;
          c.caracteristicas = listCarrito[y].caracteristicas;
          c.estadoSeleccionado = listCarrito[y].estadoSeleccionado;
          c.cantidad = listCarrito[y].cantidad;

          listCarritoModel.add(c);
        }

        carritoGeneralModel.carrito = listCarritoModel;
        carritoGeneralModel.monto = cantidadTotal.toString();
        listaGeneral.add(carritoGeneralModel);


      }
    }

    return listaGeneral;
  }
}
