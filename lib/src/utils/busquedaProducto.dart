import 'package:bufi/src/bloc/provider_bloc.dart';
import 'package:bufi/src/models/productoModel.dart';
import 'package:bufi/src/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BusquedaProductos extends SearchDelegate {
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
    return Container(child: Text("Resultados"));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //Sugerencias de busqueda


    final busquedaBloc = ProviderBloc.busqueda(context);
    busquedaBloc.obtenerResultadosBusquedaPorQuery('$query');
    if (query.isEmpty) {
      //return Container();
      return StreamBuilder(
        stream: busquedaBloc.busquedaGeneralStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductoModel>> snapshot) {
          if (snapshot.hasData) {
            final resultBusqueda = snapshot.data;

            if (snapshot.data.length > 0) {
              return ListView.builder(
                itemCount: resultBusqueda.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(resultBusqueda[index].productoName);
                },
              );
            } else {
              return Text("Algo está mal");
            }
          } else {
            return Center(child: CupertinoActivityIndicator());
          }
        },
      );
    } else {
      return StreamBuilder(
        stream: busquedaBloc.busquedaGeneralStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductoModel>> snapshot) {
          if (snapshot.hasData) {
            final resultBusqueda = snapshot.data;

            if (snapshot.data.length > 0) {
              return ListView.builder(
                itemCount: resultBusqueda.length,
                itemBuilder: (BuildContext context, int index) {
                  return
                      //bienesWidget(context, snapshot.data[index], responsive);
                      ListTile(
                    leading: FadeInImage(
                      placeholder: AssetImage('assets/no-image.png'),
                      image: NetworkImage(
                        '$apiBaseURL/${resultBusqueda[index].productoImage}',
                      ),
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                    title: Text(resultBusqueda[index].productoName),
                    subtitle: Text('${resultBusqueda[index].productoCurrency}'
                        '${resultBusqueda[index].productoPrice}'),
                    onTap: () {
                      close(context, null);
                      Navigator.pushNamed(context, 'detalleProducto',
                          arguments: resultBusqueda[index].idProducto);
                    },
                  );
                  
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

    // return Container(child: Text("Sugerencias"));
  }
}
