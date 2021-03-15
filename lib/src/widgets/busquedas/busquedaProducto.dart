import 'package:bufi/src/bloc/busquedaBloc.dart';
import 'package:bufi/src/bloc/provider_bloc.dart';
import 'package:bufi/src/models/busquedaModel.dart';
import 'package:bufi/src/models/productoModel.dart';
import 'package:bufi/src/page/Tabs/Negocios/producto/detalleProducto.dart';
import 'package:bufi/src/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BusquedaProductosPage extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    //Icono o acciones a la derecha, recibe una lista de widgets
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            print("click");
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //Iconos que van a la izquierda
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //Resultados que se mostraran una vez realizada la busqueda

    final busquedaBloc = ProviderBloc.busqueda(context);
    busquedaBloc.obtenerBusquedaProducto('$query');

    return streamProducto(busquedaBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //Sugerencias de busqueda
    final busquedaBloc = ProviderBloc.busqueda(context);
    busquedaBloc.obtenerBusquedaProducto('$query');

    if (query.isEmpty) {
      return Container(
        child: Text("Ingrese una palabra para realizar la búsqueda"),
      );
    } else {
      return streamProducto(busquedaBloc);
    }

    // return Container(child: Text("Sugerencias"));
  }

  StreamBuilder<List<BusquedaProductoModel>> streamProducto(
      BusquedaBloc busquedaBloc) {
    return StreamBuilder(
      stream: busquedaBloc.busquedaProductoStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<BusquedaProductoModel>> snapshot) {
        final resultBusqueda = snapshot.data;
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: resultBusqueda.length,
              itemBuilder: (BuildContext context, int index) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: resultBusqueda[index].listProducto.length,
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        leading: FadeInImage(
                          placeholder: AssetImage('assets/no-image.png'),
                          image: NetworkImage(
                            '$apiBaseURL/${resultBusqueda[index].listProducto[i].productoImage}',
                          ),
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                        title: Text(
                            '${resultBusqueda[index].listProducto[i].productoName}'),
                        subtitle: Text(
                            '${resultBusqueda[index].listProducto[i].productoCurrency}'),
                        onTap: () {
                          close(context, null);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetalleProductos(
                                        producto: resultBusqueda[index]
                                            .listProducto[i],
                                      )));
                        },
                      );
                    });
              },
            );
          } else {
            return Text("No hay resultados para la búsqueda");
          }
        } else {
          return Center(child: CupertinoActivityIndicator());
        }
      },
    );
  }
}
