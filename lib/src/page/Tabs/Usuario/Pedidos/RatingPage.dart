import 'dart:io';

import 'package:bufi/src/api/pedidos/Pedido_api.dart';
import 'package:bufi/src/models/PedidosModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:bufi/src/utils/responsive.dart';
import 'package:bufi/src/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class RatingProductosPage extends StatefulWidget {
  RatingProductosPage({Key key}) : super(key: key);

  @override
  _RatingProductosPageState createState() => _RatingProductosPageState();
}

class _RatingProductosPageState extends State<RatingProductosPage> {
  double valueRating = 0.0;
  //widget para el cargando
  final _cargando = ValueNotifier<bool>(false);
  TextEditingController comentarioController = TextEditingController();

  //Para acceder a la galeria o tomar una foto
  File foto;
  //Usar en cropper
  bool _inProcess = false;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final PedidosModel pedido = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Valorar",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder(
        valueListenable: _cargando,
        builder: (BuildContext context, bool value, Widget child) {
          return Stack(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: responsive.ip(4),
                      left: responsive.ip(2),
                      right: responsive.ip(2)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Califica el producto",
                          style: TextStyle(fontSize: responsive.ip(2)),
                        ),
                        RatingBar.builder(
                          initialRating: 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            valueRating = rating;

                            print(rating);
                          },
                        ),
                        SizedBox(height: responsive.hp(2)),
                        Text("Puedes dejarnos un comentario (100 caracteres)",
                            style: TextStyle(fontSize: responsive.ip(2))),
                        SizedBox(height: responsive.hp(1)),
                        Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: TextField(
                            controller: comentarioController,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(height: responsive.hp(4)),
                        Row(
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                            ),
                            SizedBox(width: responsive.wp(2)),
                            RaisedButton(
                              onPressed: () {
                                _cargando.value = false;
                                _subirFoto(context);
                                //_cargando.value = true;
                              },
                              child: Text("Subir Fotos"),
                            )
                          ],
                        ),
                        SizedBox(height: responsive.hp(2)),
                        _mostrarFoto(responsive),
                        SizedBox(height: responsive.hp(2)),
                        Center(
                          child: SizedBox(
                            width: responsive.wp(80),
                            child: RaisedButton(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                              color: Colors.red,
                              child: Text("Calificar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: responsive.ip(2.2))),
                              onPressed: () async {
                                await _submit(
                                    pedido, comentarioController, context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              (value)
                  ? Container(
                      height: double.infinity,
                      color: Colors.white54,
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: responsive.wp(10)),
                          padding: EdgeInsets.symmetric(
                              horizontal: responsive.wp(10)),
                          width: double.infinity,
                          height: responsive.hp(13),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: responsive.wp(10),
                                vertical: responsive.wp(6)),
                            height: responsive.ip(4),
                            width: responsive.ip(4),
                            child: Image(
                                image: AssetImage('assets/cargando.gif'),
                                fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          );
        },
      ),
    );
  }

  Future _subirFoto(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Seleccione"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Galeria"),
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text("Camara"),
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future _submit(PedidosModel pedido,
      TextEditingController comentarioController, BuildContext context) async {
    final pedidoApi = PedidoApi();

    if (foto != null) {
      if (comentarioController.text != null) {
        if (valueRating != null) {
          _cargando.value = true;
          final int code = await pedidoApi.valoracion(
              foto,
              pedido.detallePedido[0].idProducto,
              pedido.idPedido,
              comentarioController.text,
              valueRating.toString());
          if (code == 1) {
            print("Producto Calificado");
            utils.showToast(context, 'Producto Calificado');
            Navigator.pop(context);
          } else {
            utils.showToast(context, 'Faltan ingresar datos');
          }

          _cargando.value = false;
        } else {
          utils.showToast(context, 'Debe ingresar su comentario');
        }
      } else {
        utils.showToast(context, 'Debe ingresar su comentario');
      }
    } else {
      utils.showToast(context, 'Debe seleccionar una foto');
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.ratio3x2,
              ]
            : [
                CropAspectRatioPreset.ratio3x2,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Recortar',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Imagen',
        ),

        // maxWidth: 20,
        // maxHeight: 30
      );

      setState(() {
        foto = cropped;
        _inProcess = false;
        print('FOTO null: ${foto.path}');
      });
    } else {
      setState(() {
        print('FOTO no null: ${foto.path}');
        _inProcess = false;
      });
    }
  }

  Widget _mostrarFoto(Responsive responsive) {
    if (foto != null) {
      print('FOTO: ${foto.path}');
      return Container(
        height: responsive.hp(10),
        width: responsive.wp(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image(
            image:
                AssetImage(foto?.path ?? AssetImage('assets/jar-loading.gif')),
            height: responsive.hp(38),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
          // child: Image(  image: AssetImage('assets/jar-loading.gif')),
          );
    }
  }
}
